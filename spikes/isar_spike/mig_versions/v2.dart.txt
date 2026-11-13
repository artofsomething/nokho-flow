// Schema VERSION 2 of the migration spike. Copied to lib/mig_record.dart by
// mig_versions/use.sh; do not edit lib/mig_record.dart directly.
import 'package:isar_community/isar.dart';

part 'mig_record.g.dart';

const migVersion = 2;

@collection
class MigRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true) // index added to an existing field
  late String uuid;

  @Name('title') // Dart rename, stored name kept
  late String name;

  String? comment; // was `note`: renamed without @Name

  // legacyCount removed

  String? size; // was int: type changed

  String? description; // new, nullable
  late String status; // new, non-nullable, no default
  int priority = 3; // new, with a Dart default
  List<String> tags = []; // new list
}

String _show(MigRecord r) =>
    'uuid=${r.uuid} name=${r.name} comment=${r.comment} size=${r.size} '
    'description=${r.description} status="${r.status}" '
    'priority=${r.priority} tags=${r.tags}';

Future<List<String>> runMigStep(Isar isar) async {
  final out = <String>[];
  final c = isar.migRecords;
  out.add('v2 OPENED rows=${await c.count()}');

  final r1 = (await c.get(1))!;
  out.add('v2 old row 1: ${_show(r1)}');

  final namesKept = await c.filter().nameStartsWith('Title ').count();
  out.add('v2 renamed-with-@Name values kept: $namesKept of 1000');

  final commentsKept = await c.filter().commentIsNotNull().count();
  out.add('v2 renamed-without-@Name values kept: $commentsKept of 1000');

  final sizesKept = await c.filter().sizeIsNotNull().count();
  out.add('v2 type-changed values kept: $sizesKept of 1000');

  final byIndex = await c.getByUuid('mig-500');
  out.add('v2 new unique index finds old row: ${byIndex?.name}');

  final v2Rows = await c.filter().uuidStartsWith('v2-').count();
  if (v2Rows == 0) {
    await isar.writeTxn(
      () => c.putAll([
        for (var i = 1; i <= 10; i++)
          MigRecord()
            ..uuid = 'v2-$i'
            ..name = 'New $i'
            ..comment = 'Comment $i'
            ..size = 'big'
            ..description = 'Description $i'
            ..status = 'active'
            ..priority = 7
            ..tags = ['a', 'b'],
      ]),
    );
    out.add('v2 WROTE 10 new rows, total=${await c.count()}');

    // Updating an old row through the new schema.
    r1
      ..description = 'edited in v2'
      ..status = 'edited';
    await isar.writeTxn(() => c.put(r1));
    out.add('v2 updated old row 1: ${_show((await c.get(1))!)}');
  } else {
    // Second v2 run, after an older version opened the database in between.
    out.add('v2 REOPENED after downgrade, v2 rows=$v2Rows');
    out.add('v2 row 1001 now: ${_show((await c.get(1001))!)}');
    out.add('v2 row 1 now: ${_show((await c.get(1))!)}');
  }
  return out;
}
