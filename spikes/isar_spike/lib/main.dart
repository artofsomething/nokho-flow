import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'request_record.dart';

Future<Isar> openSpikeDb() async {
  // Isar ignores the directory on web, where it uses IndexedDB.
  final dir = kIsWeb ? '' : (await getApplicationSupportDirectory()).path;
  return Isar.open([RequestRecordSchema], directory: dir, name: 'spike');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openSpikeDb();
  final count = await isar.requestRecords.count();
  debugPrint('SPIKE_DB_OPEN records=$count');
  runApp(MainApp(recordCount: count));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.recordCount});

  final int recordCount;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Isar open. Records: $recordCount')),
      ),
    );
  }
}
