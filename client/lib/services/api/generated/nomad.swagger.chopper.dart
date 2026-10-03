// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'nomad.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Nomad extends Nomad {
  _$Nomad([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Nomad;

  @override
  Future<Response<List<User>>> _listUsers({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/users');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<User>, User>($request);
  }

  @override
  Future<Response<User>> _createUser({
    required NewUser? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/users');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<dynamic>> _deleteUser({
    required int? userID,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/users/${userID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<User>> _updateUser({
    required int? userID,
    required Changes? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/users/${userID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<TokenPair>> _login({
    required CredentialsRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TokenPair, TokenPair>($request);
  }

  @override
  Future<Response<dynamic>> _logout({
    required RefreshRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/logout');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<User>> _getMe({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/me');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<TokenPair>> _refresh({
    required RefreshRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/refresh');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TokenPair, TokenPair>($request);
  }

  @override
  Future<Response<dynamic>> _deleteFile({
    String? path,
    int? baseRev,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'baseRev': baseRev,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadFile({
    String? path,
    String? range,
    String? ifMatch,
    String? ifNoneMatch,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/content');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Map<String, String> $headers = {
      if (range != null) 'Range': range,
      if (ifMatch != null) 'If-Match': ifMatch,
      if (ifNoneMatch != null) 'If-None-Match': ifNoneMatch,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<Entry>> _uploadFile({
    String? path,
    int? baseRev,
    DateTime? mtime,
    required Object? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/content');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'baseRev': baseRev,
      'mtime': mtime,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<ListResponse>> _listFiles({
    String? path,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/list');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<ListResponse, ListResponse>($request);
  }

  @override
  Future<Response<Entry>> _makeDirectory({
    required PathRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/mkdir');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<Entry>> _moveFile({
    required MoveRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/move');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _previewFile({
    String? path,
    String? size,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/preview');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'size': size,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<Entry>> _statFile({
    String? path,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/files/stat');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<SetupStatus>> _getSetupStatus({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/setup');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<SetupStatus, SetupStatus>($request);
  }

  @override
  Future<Response<TokenPair>> _setup({
    required CredentialsRequest? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/setup');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TokenPair, TokenPair>($request);
  }

  @override
  Future<Response<ChangePage>> _listChanges({
    int? cursor,
    int? limit,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/changes');
    final Map<String, dynamic> $params = <String, dynamic>{
      'cursor': cursor,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<ChangePage, ChangePage>($request);
  }

  @override
  Future<Response<Manifest>> _getManifest({
    String? path,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/manifest');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Manifest, Manifest>($request);
  }

  @override
  Future<Response<UploadStatus>> _createUpload({
    required UploadRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Start a chunked upload; returns the chunks the server is missing',
      operationId: 'createUpload',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/uploads');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UploadStatus, UploadStatus>($request);
  }

  @override
  Future<Response<dynamic>> _abortUpload({
    required String? uploadID,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/uploads/${uploadID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<UploadStatus>> _getUpload({
    required String? uploadID,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/uploads/${uploadID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<UploadStatus, UploadStatus>($request);
  }

  @override
  Future<Response<dynamic>> _putChunk({
    required String? uploadID,
    required String? chunkHash,
    required Object? body,
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
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/sync/uploads/${uploadID}/chunks/${chunkHash}',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Entry>> _commitUpload({
    required String? uploadID,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/uploads/${uploadID}/commit');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<HealthStatus>> _health({
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
  }) {
    final Uri $url = Uri.parse('/healthz');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<HealthStatus, HealthStatus>($request);
  }
}
