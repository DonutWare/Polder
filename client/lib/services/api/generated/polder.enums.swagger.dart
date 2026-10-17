// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum AppearanceTheme {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('light')
  light('light'),
  @JsonValue('dark')
  dark('dark');

  final String? value;

  const AppearanceTheme(this.value);
}

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

enum ClientMessageScope {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('me')
  me('me'),
  @JsonValue('all')
  all('all'),
  @JsonValue('user')
  user('user');

  final String? value;

  const ClientMessageScope(this.value);
}

enum ClientMessageType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('auth')
  auth('auth'),
  @JsonValue('subscribe')
  subscribe('subscribe');

  final String? value;

  const ClientMessageType(this.value);
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

enum EventMessageStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ok')
  ok('ok'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  final String? value;

  const EventMessageStatus(this.value);
}

enum EventMessageType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ready')
  ready('ready'),
  @JsonValue('snapshot')
  snapshot('snapshot'),
  @JsonValue('error')
  error('error'),
  @JsonValue('transfer.started')
  transferStarted('transfer.started'),
  @JsonValue('transfer.progress')
  transferProgress('transfer.progress'),
  @JsonValue('transfer.finished')
  transferFinished('transfer.finished'),
  @JsonValue('activity.created')
  activityCreated('activity.created'),
  @JsonValue('files.changed')
  filesChanged('files.changed');

  final String? value;

  const EventMessageType(this.value);
}

enum ExtractionStatusOcr {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('off')
  off('off'),
  @JsonValue('ready')
  ready('ready'),
  @JsonValue('unavailable')
  unavailable('unavailable');

  final String? value;

  const ExtractionStatusOcr(this.value);
}

enum GroupMyRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('member')
  member('member'),
  @JsonValue('viewer')
  viewer('viewer');

  final String? value;

  const GroupMyRole(this.value);
}

enum LiveTransferDirection {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('upload')
  upload('upload'),
  @JsonValue('download')
  download('download');

  final String? value;

  const LiveTransferDirection(this.value);
}

enum LogEntryKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('upload')
  upload('upload'),
  @JsonValue('download')
  download('download'),
  @JsonValue('mkdir')
  mkdir('mkdir'),
  @JsonValue('move')
  move('move'),
  @JsonValue('delete')
  delete('delete'),
  @JsonValue('restore')
  restore('restore'),
  @JsonValue('trashDelete')
  trashdelete('trashDelete'),
  @JsonValue('trashEmpty')
  trashempty('trashEmpty'),
  @JsonValue('trashExpire')
  trashexpire('trashExpire'),
  @JsonValue('rescan')
  rescan('rescan'),
  @JsonValue('login')
  login('login'),
  @JsonValue('logout')
  logout('logout');

  final String? value;

  const LogEntryKind(this.value);
}

enum LogEntryStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ok')
  ok('ok'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  final String? value;

  const LogEntryStatus(this.value);
}

enum MemberRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('member')
  member('member'),
  @JsonValue('viewer')
  viewer('viewer');

  final String? value;

  const MemberRole(this.value);
}

enum NewMemberRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('member')
  member('member'),
  @JsonValue('viewer')
  viewer('viewer');

  final String? value;

  const NewMemberRole(this.value);
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

enum QueryFilterKey {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('type')
  type('type'),
  @JsonValue('ext')
  ext('ext'),
  @JsonValue('in')
  $in('in'),
  @JsonValue('modified')
  modified('modified'),
  @JsonValue('size')
  size('size');

  final String? value;

  const QueryFilterKey(this.value);
}

enum QueryFilterOp {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('is')
  $is('is'),
  @JsonValue('isNot')
  isnot('isNot'),
  @JsonValue('gt')
  gt('gt'),
  @JsonValue('gte')
  gte('gte'),
  @JsonValue('lt')
  lt('lt'),
  @JsonValue('lte')
  lte('lte'),
  @JsonValue('between')
  between('between');

  final String? value;

  const QueryFilterOp(this.value);
}

enum RecipientKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('user')
  user('user'),
  @JsonValue('group')
  group('group');

  final String? value;

  const RecipientKind(this.value);
}

enum RecipientRefKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('user')
  user('user'),
  @JsonValue('group')
  group('group');

  final String? value;

  const RecipientRefKind(this.value);
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

enum RoleChangeRole {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('admin')
  admin('admin'),
  @JsonValue('member')
  member('member'),
  @JsonValue('viewer')
  viewer('viewer');

  final String? value;

  const RoleChangeRole(this.value);
}

enum SuggestionKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('key')
  key('key'),
  @JsonValue('value')
  $value('value');

  final String? value;

  const SuggestionKind(this.value);
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
  user('user');

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

enum VersionRetentionSource {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('default')
  $default('default'),
  @JsonValue('user')
  user('user');

  final String? value;

  const VersionRetentionSource(this.value);
}

enum ApiV1AdminLogsGetLevel {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('debug')
  debug('debug'),
  @JsonValue('info')
  info('info'),
  @JsonValue('warn')
  warn('warn'),
  @JsonValue('error')
  error('error');

  final String? value;

  const ApiV1AdminLogsGetLevel(this.value);
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

enum ApiV1FilesVersionsVersionIDPreviewGetSize {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(128)
  value_128(128),
  @JsonValue(256)
  value_256(256),
  @JsonValue(512)
  value_512(512);

  final int? value;

  const ApiV1FilesVersionsVersionIDPreviewGetSize(this.value);
}

enum ApiV1GroupsGetScope {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('mine')
  mine('mine'),
  @JsonValue('all')
  all('all');

  final String? value;

  const ApiV1GroupsGetScope(this.value);
}

enum ApiV1PublicLinksCodePreviewGetSize {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(128)
  value_128(128),
  @JsonValue(256)
  value_256(256),
  @JsonValue(512)
  value_512(512);

  final int? value;

  const ApiV1PublicLinksCodePreviewGetSize(this.value);
}

enum ApiV1SharesShareIDPreviewGetSize {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(128)
  value_128(128),
  @JsonValue(256)
  value_256(256),
  @JsonValue(512)
  value_512(512);

  final int? value;

  const ApiV1SharesShareIDPreviewGetSize(this.value);
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
