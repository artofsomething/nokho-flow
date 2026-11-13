import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'bench.dart';
import 'isolate_blob_test.dart';

/// Which spike test to run: `bench` (default) or `isolate`.
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
      final isar = await Isar.open(schemas, directory: dir, name: dbName);
      final lines = switch (spikeTest) {
        'isolate' => await runIsolateBlobTest(isar, dir),
        _ => await runBench(isar),
      };
      for (final line in lines) {
        log(line.toString());
      }
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
