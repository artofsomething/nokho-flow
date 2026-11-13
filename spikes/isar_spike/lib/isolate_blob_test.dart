import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import 'bench.dart';
import 'blob_chunk.dart';
import 'request_record.dart';

const schemas = [RequestRecordSchema, BlobChunkSchema];
const dbName = 'spike';
const blobSize = 20 * 1024 * 1024;
const chunkSize = 1024 * 1024;

/// Measures how long the UI isolate was blocked while [work] ran, as the
/// largest gap between ticks of a 4 ms timer.
Future<(T, int)> _withJankProbe<T>(Future<T> Function() work) async {
  final sw = Stopwatch()..start();
  var last = sw.elapsedMilliseconds;
  var maxGap = 0;
  final timer = Timer.periodic(const Duration(milliseconds: 4), (_) {
    final now = sw.elapsedMilliseconds;
    if (now - last > maxGap) maxGap = now - last;
    last = now;
  });
  final result = await work();
  timer.cancel();
  return (result, maxGap);
}

Uint8List _makeBlob() {
  final bytes = Uint8List(blobSize);
  for (var i = 0; i < blobSize; i++) {
    bytes[i] = (i * 31 + (i >> 8)) & 0xff;
  }
  return bytes;
}

int _checksum(List<int> bytes, [int seed = 0]) {
  var sum = seed;
  for (final b in bytes) {
    sum = (sum * 31 + b) & 0x3fffffff;
  }
  return sum;
}

// ---- Code below this line runs inside background isolates. ----

Future<Isar> _openInIsolate(String dir) =>
    Isar.open(schemas, directory: dir, name: dbName, inspector: false);

Future<String> _isolateWriteRecords(String dir) async {
  final isar = await _openInIsolate(dir);
  final now = DateTime.utc(2026, 1, 1);
  final batch = [for (var i = 0; i < recordCount; i++) makeRecord(i, now)];
  final sw = Stopwatch()..start();
  await isar.writeTxn(() async {
    await isar.requestRecords.clear();
    await isar.requestRecords.putAll(batch);
  });
  final count = await isar.requestRecords.count();
  await isar.close();
  return 'count=$count writeMs=${sw.elapsedMilliseconds}';
}

Future<String> _isolateWriteSingleBlob(String dir) async {
  final isar = await _openInIsolate(dir);
  final blob = _makeBlob();
  final sw = Stopwatch()..start();
  try {
    await isar.writeTxn(() async {
      await isar.blobChunks.where().blobUuidEqualToAnySeq('single').deleteAll();
      await isar.blobChunks.put(
        BlobChunk()
          ..blobUuid = 'single'
          ..seq = 0
          ..bytes = blob,
      );
    });
    final back = await isar.blobChunks
        .where()
        .blobUuidEqualToAnySeq('single')
        .findFirst();
    final ok =
        back != null &&
        back.bytes.length == blobSize &&
        _checksum(back.bytes) == _checksum(blob);
    return 'stored=${back?.bytes.length} intact=$ok ms=${sw.elapsedMilliseconds}';
  } catch (e) {
    return 'REJECTED ${e.runtimeType}: ${'$e'.split('\n').first}';
  } finally {
    await isar.close();
  }
}

Future<String> _isolateWriteChunkedBlob(String dir) async {
  final isar = await _openInIsolate(dir);
  final blob = _makeBlob();
  final expected = _checksum(blob);
  final sw = Stopwatch()..start();
  await isar.writeTxn(() async {
    await isar.blobChunks.where().blobUuidEqualToAnySeq('chunked').deleteAll();
    await isar.blobChunks.putAll([
      for (var off = 0, seq = 0; off < blobSize; off += chunkSize, seq++)
        BlobChunk()
          ..blobUuid = 'chunked'
          ..seq = seq
          ..bytes = Uint8List.sublistView(blob, off, off + chunkSize),
    ]);
  });
  final writeMs = sw.elapsedMilliseconds;
  sw
    ..reset()
    ..start();
  final chunks = await isar.blobChunks
      .where()
      .blobUuidEqualToAnySeq('chunked')
      .sortBySeq()
      .findAll();
  var sum = 0;
  var total = 0;
  for (final c in chunks) {
    sum = _checksum(c.bytes, sum);
    total += c.bytes.length;
  }
  final readMs = sw.elapsedMilliseconds;
  await isar.close();
  return 'chunks=${chunks.length} bytes=$total intact=${sum == expected} '
      'writeMs=$writeMs readMs=$readMs';
}

/// Runs [fn] in a fresh isolate. Kept top-level so the closure sent to the
/// isolate captures only [fn] and [dir], never the UI isolate's Isar instance.
Future<String> _inIsolate(Future<String> Function(String dir) fn, String dir) =>
    Isolate.run(() => fn(dir));

// ---- Runs on the UI isolate. ----

Future<List<BenchLine>> runIsolateBlobTest(Isar isar, String dir) async {
  final lines = <BenchLine>[];
  final total = Stopwatch();

  Future<void> step(
    String label,
    Future<String> Function() work,
    bool Function(String detail) ok,
  ) async {
    total
      ..reset()
      ..start();
    String detail;
    int maxGap;
    try {
      (detail, maxGap) = await _withJankProbe(work);
    } catch (e) {
      detail = 'THREW ${e.runtimeType}: ${'$e'.split('\n').first}';
      maxGap = -1;
    }
    lines.add(
      BenchLine(
        label,
        total.elapsedMilliseconds,
        '$detail | maxUiGap=${maxGap}ms',
        ok: ok(detail),
      ),
    );
  }

  // The UI isolate keeps its own instance open and watches it, to see
  // whether writes made by another isolate reach its watchers.
  var uiWatchEvents = 0;
  final sub = isar.requestRecords.watchLazy().listen((_) => uiWatchEvents++);

  await step(
    'isolate writes $recordCount records',
    () => _inIsolate(_isolateWriteRecords, dir),
    (d) => d.startsWith('count=$recordCount'),
  );

  await Future<void>.delayed(const Duration(milliseconds: 300));
  final seenByUi = await isar.requestRecords.count();
  lines.add(
    BenchLine(
      'UI isolate sees the isolate\'s writes',
      0,
      'count=$seenByUi watchEvents=$uiWatchEvents',
      ok: seenByUi == recordCount && uiWatchEvents >= 1,
    ),
  );
  await sub.cancel();

  await step(
    'isolate stores 20 MB as ONE object',
    () => _inIsolate(_isolateWriteSingleBlob, dir),
    // Informational: either outcome is a finding, so never a failure.
    (d) => true,
  );

  await step(
    'isolate stores 20 MB as 20 x 1 MB chunks',
    () => _inIsolate(_isolateWriteChunkedBlob, dir),
    (d) => d.contains('bytes=$blobSize') && d.contains('intact=true'),
  );

  await step(
    'UI isolate reads the 20 MB back (async API)',
    () async {
      final chunks = await isar.blobChunks
          .where()
          .blobUuidEqualToAnySeq('chunked')
          .sortBySeq()
          .findAll();
      final bytes = chunks.fold<int>(0, (n, c) => n + c.bytes.length);
      return 'chunks=${chunks.length} bytes=$bytes';
    },
    (d) => d.contains('bytes=$blobSize'),
  );

  await step(
    'UI isolate writes $recordCount records (async API)',
    () async {
      final now = DateTime.utc(2026, 1, 1);
      final batch = [for (var i = 0; i < recordCount; i++) makeRecord(i, now)];
      await isar.writeTxn(() async {
        await isar.requestRecords.clear();
        await isar.requestRecords.putAll(batch);
      });
      return 'count=${await isar.requestRecords.count()}';
    },
    (d) => d == 'count=$recordCount',
  );

  final size = await isar.getSize();
  lines.add(
    BenchLine(
      'database size',
      0,
      '${(size / 1024 / 1024).toStringAsFixed(1)} MB',
      ok: size > blobSize,
    ),
  );
  return lines;
}
