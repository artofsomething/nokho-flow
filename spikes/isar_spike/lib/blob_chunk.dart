import 'package:isar_community/isar.dart';

part 'blob_chunk.g.dart';

/// Spike stand-in for the planned `BlobStore` (docs/PLAN.md 3.4): a large
/// response body, either as one object or split into ordered chunks.
@collection
class BlobChunk {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('seq')])
  late String blobUuid;

  late int seq;

  late List<byte> bytes;
}
