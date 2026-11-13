import 'package:isar_community/isar.dart';

part 'request_record.g.dart';

/// Spike stand-in for the planned `RequestDef` collection (docs/PLAN.md 3.4).
@collection
class RequestRecord {
  Id id = Isar.autoIncrement;

  /// Portable identity used for export/import and future sync.
  @Index(unique: true)
  late String uuid;

  @Index()
  late String collectionUuid;

  late String name;
  late String method;
  late String url;

  List<HeaderEntry> headers = [];

  String? body;

  @Index()
  late DateTime updatedAt;
}

@embedded
class HeaderEntry {
  String name = '';
  String value = '';
  bool enabled = true;
}
