// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blob_chunk.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetBlobChunkCollection on Isar {
  IsarCollection<BlobChunk> get blobChunks => this.collection();
}

const BlobChunkSchema = CollectionSchema(
  name: r'BlobChunk',
  id: 1008557919498635912,
  properties: {
    r'blobUuid': PropertySchema(
      id: 0,
      name: r'blobUuid',
      type: IsarType.string,
    ),
    r'bytes': PropertySchema(id: 1, name: r'bytes', type: IsarType.byteList),
    r'seq': PropertySchema(id: 2, name: r'seq', type: IsarType.long),
  },

  estimateSize: _blobChunkEstimateSize,
  serialize: _blobChunkSerialize,
  deserialize: _blobChunkDeserialize,
  deserializeProp: _blobChunkDeserializeProp,
  idName: r'id',
  indexes: {
    r'blobUuid_seq': IndexSchema(
      id: 4713564430888585509,
      name: r'blobUuid_seq',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'blobUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'seq',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _blobChunkGetId,
  getLinks: _blobChunkGetLinks,
  attach: _blobChunkAttach,
  version: '3.4.1',
);

int _blobChunkEstimateSize(
  BlobChunk object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blobUuid.length * 3;
  bytesCount += 3 + object.bytes.length;
  return bytesCount;
}

void _blobChunkSerialize(
  BlobChunk object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.blobUuid);
  writer.writeByteList(offsets[1], object.bytes);
  writer.writeLong(offsets[2], object.seq);
}

BlobChunk _blobChunkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BlobChunk();
  object.blobUuid = reader.readString(offsets[0]);
  object.bytes = reader.readByteList(offsets[1]) ?? [];
  object.id = id;
  object.seq = reader.readLong(offsets[2]);
  return object;
}

P _blobChunkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readByteList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _blobChunkGetId(BlobChunk object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _blobChunkGetLinks(BlobChunk object) {
  return [];
}

void _blobChunkAttach(IsarCollection<dynamic> col, Id id, BlobChunk object) {
  object.id = id;
}

extension BlobChunkQueryWhereSort
    on QueryBuilder<BlobChunk, BlobChunk, QWhere> {
  QueryBuilder<BlobChunk, BlobChunk, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BlobChunkQueryWhere
    on QueryBuilder<BlobChunk, BlobChunk, QWhereClause> {
  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> blobUuidEqualToAnySeq(
    String blobUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'blobUuid_seq', value: [blobUuid]),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause>
  blobUuidNotEqualToAnySeq(String blobUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [],
                upper: [blobUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [],
                upper: [blobUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause> blobUuidSeqEqualTo(
    String blobUuid,
    int seq,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'blobUuid_seq',
          value: [blobUuid, seq],
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause>
  blobUuidEqualToSeqNotEqualTo(String blobUuid, int seq) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid],
                upper: [blobUuid, seq],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid, seq],
                includeLower: false,
                upper: [blobUuid],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid, seq],
                includeLower: false,
                upper: [blobUuid],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'blobUuid_seq',
                lower: [blobUuid],
                upper: [blobUuid, seq],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause>
  blobUuidEqualToSeqGreaterThan(
    String blobUuid,
    int seq, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'blobUuid_seq',
          lower: [blobUuid, seq],
          includeLower: include,
          upper: [blobUuid],
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause>
  blobUuidEqualToSeqLessThan(String blobUuid, int seq, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'blobUuid_seq',
          lower: [blobUuid],
          upper: [blobUuid, seq],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterWhereClause>
  blobUuidEqualToSeqBetween(
    String blobUuid,
    int lowerSeq,
    int upperSeq, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'blobUuid_seq',
          lower: [blobUuid, lowerSeq],
          includeLower: includeLower,
          upper: [blobUuid, upperSeq],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BlobChunkQueryFilter
    on QueryBuilder<BlobChunk, BlobChunk, QFilterCondition> {
  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'blobUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'blobUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'blobUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> blobUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'blobUuid', value: ''),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition>
  blobUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'blobUuid', value: ''),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bytes', value: value),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition>
  bytesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition>
  bytesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bytes', length, true, length, true);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bytes', 0, true, 0, true);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bytes', 0, false, 999999, true);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bytes', 0, true, length, include);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition>
  bytesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bytes', length, include, 999999, true);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> bytesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> seqEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seq', value: value),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> seqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seq',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> seqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seq',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterFilterCondition> seqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seq',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BlobChunkQueryObject
    on QueryBuilder<BlobChunk, BlobChunk, QFilterCondition> {}

extension BlobChunkQueryLinks
    on QueryBuilder<BlobChunk, BlobChunk, QFilterCondition> {}

extension BlobChunkQuerySortBy on QueryBuilder<BlobChunk, BlobChunk, QSortBy> {
  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> sortByBlobUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blobUuid', Sort.asc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> sortByBlobUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blobUuid', Sort.desc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> sortBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> sortBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }
}

extension BlobChunkQuerySortThenBy
    on QueryBuilder<BlobChunk, BlobChunk, QSortThenBy> {
  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenByBlobUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blobUuid', Sort.asc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenByBlobUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blobUuid', Sort.desc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QAfterSortBy> thenBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }
}

extension BlobChunkQueryWhereDistinct
    on QueryBuilder<BlobChunk, BlobChunk, QDistinct> {
  QueryBuilder<BlobChunk, BlobChunk, QDistinct> distinctByBlobUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blobUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QDistinct> distinctByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bytes');
    });
  }

  QueryBuilder<BlobChunk, BlobChunk, QDistinct> distinctBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seq');
    });
  }
}

extension BlobChunkQueryProperty
    on QueryBuilder<BlobChunk, BlobChunk, QQueryProperty> {
  QueryBuilder<BlobChunk, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BlobChunk, String, QQueryOperations> blobUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blobUuid');
    });
  }

  QueryBuilder<BlobChunk, List<int>, QQueryOperations> bytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bytes');
    });
  }

  QueryBuilder<BlobChunk, int, QQueryOperations> seqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seq');
    });
  }
}
