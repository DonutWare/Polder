// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum ChangeType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('upsert')
  upsert('upsert'),
  @JsonValue('delete')
  delete('delete'),
  @JsonValue('move')
  move('move');

  final String? value;

  const ChangeType(this.value);
}

enum ChangesRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('user')
  user('user');

  final String? value;

  const ChangesRole(this.value);
}

enum EntryPreviewState {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('pending')
  pending('pending'),
  @JsonValue('ready')
  ready('ready'),
  @JsonValue('failed')
  failed('failed');

  final String? value;

  const EntryPreviewState(this.value);
}

enum NewUserRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('user')
  user('user');

  final String? value;

  const NewUserRole(this.value);
}

enum RestoreRequestOnConflict {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('fail')
  fail('fail'),
  @JsonValue('overwrite')
  overwrite('overwrite'),
  @JsonValue('keepBoth')
  keepboth('keepBoth');

  final String? value;

  const RestoreRequestOnConflict(this.value);
}

enum TrashItemPreviewState {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('pending')
  pending('pending'),
  @JsonValue('ready')
  ready('ready'),
  @JsonValue('failed')
  failed('failed');

  final String? value;

  const TrashItemPreviewState(this.value);
}

enum TrashRetentionSource {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('default')
  $default('default'),
  @JsonValue('user')
  user('user'),
  @JsonValue('server')
  server('server'),
  @JsonValue('admin')
  admin('admin');

  final String? value;

  const TrashRetentionSource(this.value);
}

enum UserRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('user')
  user('user');

  final String? value;

  const UserRole(this.value);
}

enum ApiV1FilesPreviewGetSize {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(128)
  value_128(128),
  @JsonValue(256)
  value_256(256),
  @JsonValue(512)
  value_512(512);

  final int? value;

  const ApiV1FilesPreviewGetSize(this.value);
}

enum ApiV1TrashItemIDPreviewGetSize {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(128)
  value_128(128),
  @JsonValue(256)
  value_256(256),
  @JsonValue(512)
  value_512(512);

  final int? value;

  const ApiV1TrashItemIDPreviewGetSize(this.value);
}
