import 'dart:async';

import 'package:isar_community/isar.dart';

import 'request_record.dart';

const recordCount = 10000;
const collectionCount = 10;

/// One measured line of the spike report.
class BenchLine {
  BenchLine(this.label, this.ms, this.detail, {required this.ok});

  final String label;
  final int ms;
  final String detail;
  final bool ok;

  @override
  String toString() => '${ok ? 'PASS' : 'FAIL'} | $label | ${ms}ms | $detail';
}

RequestRecord _record(int i, DateTime now) => RequestRecord()
  ..uuid = 'req-$i'
  ..collectionUuid = 'col-${i % collectionCount}'
  ..name = 'Request $i'
  ..method = i.isEven ? 'GET' : 'POST'
  ..url = 'https://api.example.test/v1/items/$i?page=${i % 50}'
  ..headers = [
    HeaderEntry()
      ..name = 'Authorization'
      ..value = 'Bearer token-$i',
    HeaderEntry()
      ..name = 'Accept'
      ..value = 'application/json',
  ]
  ..body = i.isEven ? null : '{"index": $i, "name": "item $i"}'
  ..updatedAt = now.add(Duration(seconds: i));

Future<List<BenchLine>> runBench(Isar isar) async {
  final lines = <BenchLine>[];
  final sw = Stopwatch();
  final records = isar.requestRecords;

  Future<void> measure(
    String label,
    Future<(String, bool)> Function() body,
  ) async {
    sw
      ..reset()
      ..start();
    final (detail, ok) = await body();
    sw.stop();
    lines.add(BenchLine(label, sw.elapsedMilliseconds, detail, ok: ok));
  }

  await isar.writeTxn(() => records.clear());

  // Watchers: one on the whole collection, one on a query.
  var collectionEvents = 0;
  var queryEvents = 0;
  var lastQueryLength = -1;
  final collectionSub = records.watchLazy().listen((_) => collectionEvents++);
  final querySub = records
      .where()
      .collectionUuidEqualTo('col-3')
      .watch()
      .listen((items) {
        queryEvents++;
        lastQueryLength = items.length;
      });

  final now = DateTime.utc(2026, 1, 1);
  final batch = [for (var i = 0; i < recordCount; i++) _record(i, now)];

  await measure('write $recordCount in one transaction', () async {
    await isar.writeTxn(() => records.putAll(batch));
    final count = await records.count();
    return ('count=$count', count == recordCount);
  });

  await measure('read all', () async {
    final all = await records.where().findAll();
    final headersOk = all.every((r) => r.headers.length == 2);
    return (
      'rows=${all.length} headersIntact=$headersOk',
      all.length == recordCount && headersOk,
    );
  });

  await measure('indexed query (one collection)', () async {
    final rows = await records.where().collectionUuidEqualTo('col-3').findAll();
    return (
      'rows=${rows.length}',
      rows.length == recordCount ~/ collectionCount,
    );
  });

  await measure('unique index lookup x1000', () async {
    var found = 0;
    for (var i = 0; i < 1000; i++) {
      final r = await records.getByUuid('req-${i * 10}');
      if (r != null && r.name == 'Request ${i * 10}') found++;
    }
    return ('found=$found', found == 1000);
  });

  await measure('unindexed filter (method == POST)', () async {
    final n = await records.filter().methodEqualTo('POST').count();
    return ('rows=$n', n == recordCount ~/ 2);
  });

  await measure('sorted page (latest 50 by updatedAt)', () async {
    final rows = await records
        .where()
        .sortByUpdatedAtDesc()
        .limit(50)
        .findAll();
    final ok = rows.length == 50 && rows.first.uuid == 'req-${recordCount - 1}';
    return ('rows=${rows.length} first=${rows.first.uuid}', ok);
  });

  await measure('100 single-record transactions (autosave)', () async {
    for (var i = 0; i < 100; i++) {
      final r = (await records.getByUuid('req-$i'))!..name = 'Edited $i';
      await isar.writeTxn(() => records.put(r));
    }
    final edited = await records.filter().nameStartsWith('Edited ').count();
    return ('edited=$edited', edited == 100);
  });

  await measure('duplicate uuid rejected', () async {
    final dup = _record(5, now);
    try {
      await isar.writeTxn(() => records.put(dup));
      return ('no error thrown', false);
    } on IsarError catch (e) {
      final count = await records.count();
      return ('${e.runtimeType} count=$count', count == recordCount);
    }
  });

  await measure('delete one collection (1000 rows)', () async {
    late int deleted;
    await isar.writeTxn(() async {
      deleted = await records
          .where()
          .collectionUuidEqualTo('col-3')
          .deleteAll();
    });
    final count = await records.count();
    return (
      'deleted=$deleted remaining=$count',
      deleted == 1000 && count == recordCount - 1000,
    );
  });

  // Give watchers a moment to deliver their last events.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  await collectionSub.cancel();
  await querySub.cancel();
  lines.add(
    BenchLine(
      'watchers',
      0,
      'collectionEvents=$collectionEvents queryEvents=$queryEvents '
          'lastQueryLength=$lastQueryLength',
      ok: collectionEvents >= 3 && queryEvents >= 2 && lastQueryLength == 0,
    ),
  );

  final size = await isar.getSize();
  lines.add(
    BenchLine(
      'database size',
      0,
      '${(size / 1024 / 1024).toStringAsFixed(1)} MB',
      ok: size > 0,
    ),
  );

  return lines;
}
