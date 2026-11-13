import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'bench.dart';
import 'request_record.dart';

Future<Isar> openSpikeDb() async {
  // Isar ignores the directory on web, where it uses IndexedDB.
  final dir = kIsWeb ? '' : (await getApplicationSupportDirectory()).path;
  return Isar.open([RequestRecordSchema], directory: dir, name: 'spike');
}

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
      log('platform=${kIsWeb ? 'web' : defaultTargetPlatform.name} mode=$mode');
      final isar = await openSpikeDb();
      for (final line in await runBench(isar)) {
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
