// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';

import 'nomad.models.swagger.dart';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;

import 'nomad.enums.swagger.dart' as enums;
import 'nomad.metadata.swagger.dart';
export 'nomad.enums.swagger.dart';
export 'nomad.models.swagger.dart';

part 'nomad.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Nomad extends ChopperService {
  static Nomad create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Nomad(client);
    }

    final newClient = ChopperClient(
      services: [_$Nomad()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl,
    );
    return _$Nomad(newClient);
  }

  ///List all users
  Future<chopper.Response<List<User>>> listUsers() {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _listUsers();
  }

  ///List all users
  @GET(path: '/api/v1/admin/users')
  Future<chopper.Response<List<User>>> _listUsers({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List all users',
      operationId: 'listUsers',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  });

  ///Create a user
  Future<chopper.Response<User>> createUser({required NewUser? body}) {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _createUser(body: body);
  }

  ///Create a user
  @POST(path: '/api/v1/admin/users', optionalBody: true)
  Future<chopper.Response<User>> _createUser({
    @Body() required NewUser? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a user',
      operationId: 'createUser',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  });

  ///Delete a user; their files are archived on the server
  ///@param userID
  Future<chopper.Response> deleteUser({required int? userID}) {
    return _deleteUser(userID: userID);
  }

  ///Delete a user; their files are archived on the server
  ///@param userID
  @DELETE(path: '/api/v1/admin/users/{userID}')
  Future<chopper.Response> _deleteUser({
    @Path('userID') required int? userID,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete a user; their files are archived on the server',
      operationId: 'deleteUser',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  });

  ///Change a user; password changes and disabling log the user out
  ///@param userID
  Future<chopper.Response<User>> updateUser({required int? userID, required Changes? body}) {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _updateUser(userID: userID, body: body);
  }

  ///Change a user; password changes and disabling log the user out
  ///@param userID
  @PATCH(path: '/api/v1/admin/users/{userID}', optionalBody: true)
  Future<chopper.Response<User>> _updateUser({
    @Path('userID') required int? userID,
    @Body() required Changes? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change a user; password changes and disabling log the user out',
      operationId: 'updateUser',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  });

  ///Log in and get a token pair
  Future<chopper.Response<TokenPair>> login({required CredentialsRequest? body}) {
    generatedMapping.putIfAbsent(TokenPair, () => TokenPair.fromJsonFactory);

    return _login(body: body);
  }

  ///Log in and get a token pair
  @POST(path: '/api/v1/auth/login', optionalBody: true)
  Future<chopper.Response<TokenPair>> _login({
    @Body() required CredentialsRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Log in and get a token pair',
      operationId: 'login',
      consumes: [],
      produces: [],
      security: [],
      tags: ["auth"],
      deprecated: false,
    ),
  });

  ///Revoke a refresh token
  Future<chopper.Response> logout({required RefreshRequest? body}) {
    return _logout(body: body);
  }

  ///Revoke a refresh token
  @POST(path: '/api/v1/auth/logout', optionalBody: true)
  Future<chopper.Response> _logout({
    @Body() required RefreshRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Revoke a refresh token',
      operationId: 'logout',
      consumes: [],
      produces: [],
      security: [],
      tags: ["auth"],
      deprecated: false,
    ),
  });

  ///The logged-in user
  Future<chopper.Response<User>> getMe() {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _getMe();
  }

  ///The logged-in user
  @GET(path: '/api/v1/auth/me')
  Future<chopper.Response<User>> _getMe({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The logged-in user',
      operationId: 'getMe',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["auth"],
      deprecated: false,
    ),
  });

  ///Exchange a refresh token for a new token pair
  Future<chopper.Response<TokenPair>> refresh({required RefreshRequest? body}) {
    generatedMapping.putIfAbsent(TokenPair, () => TokenPair.fromJsonFactory);

    return _refresh(body: body);
  }

  ///Exchange a refresh token for a new token pair
  @POST(path: '/api/v1/auth/refresh', optionalBody: true)
  Future<chopper.Response<TokenPair>> _refresh({
    @Body() required RefreshRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Exchange a refresh token for a new token pair',
      operationId: 'refresh',
      consumes: [],
      produces: [],
      security: [],
      tags: ["auth"],
      deprecated: false,
    ),
  });

  ///Delete a file or directory
  ///@param path
  ///@param baseRev Revision the client last saw; -1 deletes whatever is there
  Future<chopper.Response> deleteFile({String? path, int? baseRev}) {
    return _deleteFile(path: path, baseRev: baseRev);
  }

  ///Delete a file or directory
  ///@param path
  ///@param baseRev Revision the client last saw; -1 deletes whatever is there
  @DELETE(path: '/api/v1/files')
  Future<chopper.Response> _deleteFile({
    @Query('path') String? path,
    @Query('baseRev') int? baseRev,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete a file or directory',
      operationId: 'deleteFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Download a file; supports Range and conditional requests
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg
  ///@param Range Byte range to send, such as bytes=0-1023
  ///@param If-Match Fail with 412 unless the file still has this ETag
  ///@param If-None-Match Answer 304 if the file still has this ETag
  Future<chopper.Response<Stream<List<int>>>> downloadFile({
    String? path,
    String? range,
    String? ifMatch,
    String? ifNoneMatch,
  }) {
    return _downloadFile(
      path: path,
      range: range?.toString(),
      ifMatch: ifMatch?.toString(),
      ifNoneMatch: ifNoneMatch?.toString(),
    );
  }

  ///Download a file; supports Range and conditional requests
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg
  ///@param Range Byte range to send, such as bytes=0-1023
  ///@param If-Match Fail with 412 unless the file still has this ETag
  ///@param If-None-Match Answer 304 if the file still has this ETag
  @GET(path: '/api/v1/files/content')
  Future<chopper.Response<Stream<List<int>>>> _downloadFile({
    @Query('path') String? path,
    @Header('Range') String? range,
    @Header('If-Match') String? ifMatch,
    @Header('If-None-Match') String? ifNoneMatch,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a file; supports Range and conditional requests',
      operationId: 'downloadFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Upload a whole file as the request body
  ///@param path Where to store the file, such as /Photos/cat.jpg
  ///@param baseRev Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there
  ///@param mtime Modification time to record, as RFC 3339; defaults to now
  Future<chopper.Response<Entry>> uploadFile({String? path, int? baseRev, DateTime? mtime, required Object? body}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _uploadFile(path: path, baseRev: baseRev, mtime: mtime, body: body);
  }

  ///Upload a whole file as the request body
  ///@param path Where to store the file, such as /Photos/cat.jpg
  ///@param baseRev Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there
  ///@param mtime Modification time to record, as RFC 3339; defaults to now
  @PUT(path: '/api/v1/files/content', optionalBody: true)
  Future<chopper.Response<Entry>> _uploadFile({
    @Query('path') String? path,
    @Query('baseRev') int? baseRev,
    @Query('mtime') DateTime? mtime,
    @Body() required Object? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Upload a whole file as the request body',
      operationId: 'uploadFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///List a directory
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  Future<chopper.Response<ListResponse>> listFiles({String? path}) {
    generatedMapping.putIfAbsent(ListResponse, () => ListResponse.fromJsonFactory);

    return _listFiles(path: path);
  }

  ///List a directory
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  @GET(path: '/api/v1/files/list')
  Future<chopper.Response<ListResponse>> _listFiles({
    @Query('path') String? path,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List a directory',
      operationId: 'listFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Create a directory
  Future<chopper.Response<Entry>> makeDirectory({required PathRequest? body}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _makeDirectory(body: body);
  }

  ///Create a directory
  @POST(path: '/api/v1/files/mkdir', optionalBody: true)
  Future<chopper.Response<Entry>> _makeDirectory({
    @Body() required PathRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a directory',
      operationId: 'makeDirectory',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Move or rename a file or directory
  Future<chopper.Response<Entry>> moveFile({required MoveRequest? body}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _moveFile(body: body);
  }

  ///Move or rename a file or directory
  @POST(path: '/api/v1/files/move', optionalBody: true)
  Future<chopper.Response<Entry>> _moveFile({
    @Body() required MoveRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Move or rename a file or directory',
      operationId: 'moveFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Get a JPEG thumbnail of an image
  ///@param path
  ///@param size Thumbnail width and height in pixels
  Future<chopper.Response<Stream<List<int>>>> previewFile({String? path, enums.ApiV1FilesPreviewGetSize? size}) {
    return _previewFile(path: path, size: size?.value?.toString());
  }

  ///Get a JPEG thumbnail of an image
  ///@param path
  ///@param size Thumbnail width and height in pixels
  @GET(path: '/api/v1/files/preview')
  Future<chopper.Response<Stream<List<int>>>> _previewFile({
    @Query('path') String? path,
    @Query('size') String? size,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a JPEG thumbnail of an image',
      operationId: 'previewFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Get one file or directory
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  Future<chopper.Response<Entry>> statFile({String? path}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _statFile(path: path);
  }

  ///Get one file or directory
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  @GET(path: '/api/v1/files/stat')
  Future<chopper.Response<Entry>> _statFile({
    @Query('path') String? path,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get one file or directory',
      operationId: 'statFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  });

  ///Whether the server still needs its first account
  Future<chopper.Response<SetupStatus>> getSetupStatus() {
    generatedMapping.putIfAbsent(SetupStatus, () => SetupStatus.fromJsonFactory);

    return _getSetupStatus();
  }

  ///Whether the server still needs its first account
  @GET(path: '/api/v1/setup')
  Future<chopper.Response<SetupStatus>> _getSetupStatus({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Whether the server still needs its first account',
      operationId: 'getSetupStatus',
      consumes: [],
      produces: [],
      security: [],
      tags: ["setup"],
      deprecated: false,
    ),
  });

  ///Create the first administrator account
  Future<chopper.Response<TokenPair>> setup({required CredentialsRequest? body}) {
    generatedMapping.putIfAbsent(TokenPair, () => TokenPair.fromJsonFactory);

    return _setup(body: body);
  }

  ///Create the first administrator account
  @POST(path: '/api/v1/setup', optionalBody: true)
  Future<chopper.Response<TokenPair>> _setup({
    @Body() required CredentialsRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create the first administrator account',
      operationId: 'setup',
      consumes: [],
      produces: [],
      security: [],
      tags: ["setup"],
      deprecated: false,
    ),
  });

  ///Page through changes since a cursor
  ///@param cursor Cursor from the previous page; 0 starts from the beginning
  ///@param limit Maximum number of changes to return; the server caps it
  Future<chopper.Response<ChangePage>> listChanges({int? cursor, int? limit}) {
    generatedMapping.putIfAbsent(ChangePage, () => ChangePage.fromJsonFactory);

    return _listChanges(cursor: cursor, limit: limit);
  }

  ///Page through changes since a cursor
  ///@param cursor Cursor from the previous page; 0 starts from the beginning
  ///@param limit Maximum number of changes to return; the server caps it
  @GET(path: '/api/v1/sync/changes')
  Future<chopper.Response<ChangePage>> _listChanges({
    @Query('cursor') int? cursor,
    @Query('limit') int? limit,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Page through changes since a cursor',
      operationId: 'listChanges',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Get a file's chunk manifest for delta sync
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  Future<chopper.Response<Manifest>> getManifest({String? path}) {
    generatedMapping.putIfAbsent(Manifest, () => Manifest.fromJsonFactory);

    return _getManifest(path: path);
  }

  ///Get a file's chunk manifest for delta sync
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  @GET(path: '/api/v1/sync/manifest')
  Future<chopper.Response<Manifest>> _getManifest({
    @Query('path') String? path,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a file\'s chunk manifest for delta sync',
      operationId: 'getManifest',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Start a chunked upload; returns the chunks the server is missing
  Future<chopper.Response<UploadStatus>> createUpload({required UploadRequest? body}) {
    generatedMapping.putIfAbsent(UploadStatus, () => UploadStatus.fromJsonFactory);

    return _createUpload(body: body);
  }

  ///Start a chunked upload; returns the chunks the server is missing
  @POST(path: '/api/v1/sync/uploads', optionalBody: true)
  Future<chopper.Response<UploadStatus>> _createUpload({
    @Body() required UploadRequest? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Start a chunked upload; returns the chunks the server is missing',
      operationId: 'createUpload',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Cancel an upload
  ///@param uploadID
  Future<chopper.Response> abortUpload({required String? uploadID}) {
    return _abortUpload(uploadID: uploadID);
  }

  ///Cancel an upload
  ///@param uploadID
  @DELETE(path: '/api/v1/sync/uploads/{uploadID}')
  Future<chopper.Response> _abortUpload({
    @Path('uploadID') required String? uploadID,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Cancel an upload',
      operationId: 'abortUpload',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Get the chunks an upload is still missing
  ///@param uploadID
  Future<chopper.Response<UploadStatus>> getUpload({required String? uploadID}) {
    generatedMapping.putIfAbsent(UploadStatus, () => UploadStatus.fromJsonFactory);

    return _getUpload(uploadID: uploadID);
  }

  ///Get the chunks an upload is still missing
  ///@param uploadID
  @GET(path: '/api/v1/sync/uploads/{uploadID}')
  Future<chopper.Response<UploadStatus>> _getUpload({
    @Path('uploadID') required String? uploadID,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get the chunks an upload is still missing',
      operationId: 'getUpload',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Send one chunk as the request body
  ///@param uploadID
  ///@param chunkHash Lowercase hex SHA-256 of the chunk
  Future<chopper.Response> putChunk({required String? uploadID, required String? chunkHash, required Object? body}) {
    return _putChunk(uploadID: uploadID, chunkHash: chunkHash, body: body);
  }

  ///Send one chunk as the request body
  ///@param uploadID
  ///@param chunkHash Lowercase hex SHA-256 of the chunk
  @PUT(path: '/api/v1/sync/uploads/{uploadID}/chunks/{chunkHash}', optionalBody: true)
  Future<chopper.Response> _putChunk({
    @Path('uploadID') required String? uploadID,
    @Path('chunkHash') required String? chunkHash,
    @Body() required Object? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Send one chunk as the request body',
      operationId: 'putChunk',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Assemble the uploaded chunks into the file
  ///@param uploadID
  Future<chopper.Response<Entry>> commitUpload({required String? uploadID}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _commitUpload(uploadID: uploadID);
  }

  ///Assemble the uploaded chunks into the file
  ///@param uploadID
  @POST(path: '/api/v1/sync/uploads/{uploadID}/commit', optionalBody: true)
  Future<chopper.Response<Entry>> _commitUpload({
    @Path('uploadID') required String? uploadID,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Assemble the uploaded chunks into the file',
      operationId: 'commitUpload',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  });

  ///Health check
  Future<chopper.Response<HealthStatus>> health() {
    generatedMapping.putIfAbsent(HealthStatus, () => HealthStatus.fromJsonFactory);

    return _health();
  }

  ///Health check
  @GET(path: '/healthz')
  Future<chopper.Response<HealthStatus>> _health({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Health check',
      operationId: 'health',
      consumes: [],
      produces: [],
      security: [],
      tags: ["server"],
      deprecated: false,
    ),
  });
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) => values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(body: DateTime.parse((response.body as String).replaceAll('"', '')) as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
