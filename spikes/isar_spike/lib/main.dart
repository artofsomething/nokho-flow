import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'bench.dart';
import 'isolate_blob_test.dart';
import 'mig_record.dart';

/// Which spike test to run: `bench` (default), `isolate` or `mig`.
/// Pass with `--dart-define=SPIKE_TEST=isolate`.
const spikeTest = String.fromEnvironment('SPIKE_TEST', defaultValue: 'bench');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<String> _lines = ['Running…'];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<List<String>> _runTest(String dir) async {
    if (spikeTest == 'mig') {
      // Own database file, so schema changes here never touch the others.
      final isar = await Isar.open(
        [MigRecordSchema],
        directory: dir,
        name: 'mig',
      );
      return ['schemaVersion=$migVersion', ...await runMigStep(isar)];
    }
    final isar = await Isar.open(schemas, directory: dir, name: dbName);
    final lines = spikeTest == 'isolate'
        ? await runIsolateBlobTest(isar, dir)
        : await runBench(isar);
    return [for (final l in lines) l.toString()];
  }

  Future<void> _run() async {
    final out = <String>[];
    void log(String line) {
      out.add(line);
      // ignore: avoid_print
      print('SPIKE $line');
    }

    try {
      final mode = kReleaseMode ? 'release' : 'debug';
      log('platform=${defaultTargetPlatform.name} mode=$mode test=$spikeTest');
      final dir = (await getApplicationSupportDirectory()).path;
      (await _runTest(dir)).forEach(log);
      log('DONE');
    } catch (e, st) {
      log('ERROR $e');
      log(st.toString().split('\n').take(6).join(' / '));
    }
    if (mounted) setState(() => _lines = out);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [for (final l in _lines) SelectableText(l)],
        ),
      ),
    );
  }
}
