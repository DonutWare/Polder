// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'polder.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Polder extends Polder {
  _$Polder([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Polder;

  @override
  Future<Response<LogPage>> _listActivity({
    String? user,
    int? before,
    int? limit,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Page through what happened to files and sessions, newest first',
      operationId: 'listActivity',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["activity"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/activity');
    final Map<String, dynamic> $params = <String, dynamic>{
      'user': user,
      'before': before,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<LogPage, LogPage>($request);
  }

  @override
  Future<Response<LiveTransfers>> _listLiveTransfers({
    String? user,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Uploads and downloads in progress',
      operationId: 'listLiveTransfers',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["activity"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/activity/live');
    final Map<String, dynamic> $params = <String, dynamic>{'user': user};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<LiveTransfers, LiveTransfers>($request);
  }

  @override
  Future<Response<Branding>> _addBrandingBackground({
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Add the image in the request body to the login screen\'s backgrounds',
      operationId: 'addBrandingBackground',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/branding/backgrounds');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Branding, Branding>($request);
  }

  @override
  Future<Response<dynamic>> _removeBrandingBackground({
    required String? imageID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Remove one of the login screen\'s backgrounds',
      operationId: 'removeBrandingBackground',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/branding/backgrounds/${imageID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _removeBrandingIcon({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Go back to the apps\' own icon',
      operationId: 'removeBrandingIcon',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/branding/icon');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Branding>> _setBrandingIcon({
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Replace the server\'s icon with the image in the request body',
      operationId: 'setBrandingIcon',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/branding/icon');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Branding, Branding>($request);
  }

  @override
  Future<Response<ServerLogPage>> _listLogs({
    String? level,
    String? component,
    String? q,
    String? before,
    int? limit,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Page through the server log, newest first',
      operationId: 'listLogs',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/logs');
    final Map<String, dynamic> $params = <String, dynamic>{
      'level': level,
      'component': component,
      'q': q,
      'before': before,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<ServerLogPage, ServerLogPage>($request);
  }

  @override
  Future<Response<LogComponents>> _listLogComponents({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Parts of the server that appear in the log',
      operationId: 'listLogComponents',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/logs/components');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<LogComponents, LogComponents>($request);
  }

  @override
  Future<Response<LogFiles>> _listLogFiles({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The log files, one per day, newest first',
      operationId: 'listLogFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/logs/files');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<LogFiles, LogFiles>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadLogFile({
    required String? name,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download one day\'s log file as JSON lines',
      operationId: 'downloadLogFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/logs/files/${name}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<SearchStatus>> _getSearchStatus({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'State of the search index and of reading text from files',
      operationId: 'getSearchStatus',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/search');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<SearchStatus, SearchStatus>($request);
  }

  @override
  Future<Response<dynamic>> _rebuildSearchIndex({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Rebuild the search index from scratch in the background',
      operationId: 'rebuildSearchIndex',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/search/rebuild');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ServerSettings>> _getServerSettings({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Server-wide settings',
      operationId: 'getServerSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/settings');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<ServerSettings, ServerSettings>($request);
  }

  @override
  Future<Response<ServerSettings>> _updateServerSettings({
    required ServerSettingsChanges? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change server-wide settings',
      operationId: 'updateServerSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/settings');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ServerSettings, ServerSettings>($request);
  }

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
  Future<Response<Branding>> _getBranding({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'How the apps present this server, shown before logging in',
      operationId: 'getBranding',
      consumes: [],
      produces: [],
      security: [],
      tags: ["branding"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/branding');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Branding, Branding>($request);
  }

  @override
  Future<Response<String>> _getBrandingBackground({
    required String? imageID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'One of the login screen\'s backgrounds',
      operationId: 'getBrandingBackground',
      consumes: [],
      produces: [],
      security: [],
      tags: ["branding"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/branding/backgrounds/${imageID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _getBrandingIcon({
    required String? imageID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The server\'s icon',
      operationId: 'getBrandingIcon',
      consumes: [],
      produces: [],
      security: [],
      tags: ["branding"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/branding/icon/${imageID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>> _events({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Open a WebSocket here and send an `auth` message within 10 seconds, and again whenever the token is renewed. The server answers `ready` and a `snapshot` of the transfers in progress. Administrators can `subscribe` to other users; every subscribe is answered with a new snapshot, and your own events always arrive. Messages are described by the ClientMessage and EventMessage schemas. The connection closes with code 4401 when authentication fails or the token expires without renewal.',
      summary: 'Live activity over a WebSocket',
      operationId: 'events',
      consumes: [],
      produces: [],
      security: [],
      tags: ["events"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/events');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
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
    String? xPolderTransferId,
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
    final Map<String, String> $headers = {
      if (xPolderTransferId != null) 'X-Polder-Transfer-Id': xPolderTransferId,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<Entry, Entry>($request);
  }

  @override
  Future<Response<LinksResponse>> _listFileLinks({
    int? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What a file links to and which files link to it',
      operationId: 'listFileLinks',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/links');
    final Map<String, dynamic> $params = <String, dynamic>{'id': id};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<LinksResponse, LinksResponse>($request);
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
      summary: 'Get a JPEG thumbnail of an image, video or document',
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
  Future<Response<ResolveResponse>> _resolveFiles({
    required ResolveRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Look files up by id, wherever they are now',
      operationId: 'resolveFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/resolve');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ResolveResponse, ResolveResponse>($request);
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
  Future<Response<VersionListing>> _listFileVersions({
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List a file\'s earlier versions, newest first',
      operationId: 'listFileVersions',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/versions');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<VersionListing, VersionListing>($request);
  }

  @override
  Future<Response<dynamic>> _deleteFileVersion({
    required int? versionID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete one earlier version permanently',
      operationId: 'deleteFileVersion',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/versions/${versionID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadFileVersion({
    required int? versionID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download an earlier version of a file',
      operationId: 'downloadFileVersion',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/versions/${versionID}/content');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _previewFileVersion({
    required int? versionID,
    String? size,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a JPEG thumbnail of an earlier version',
      operationId: 'previewFileVersion',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/versions/${versionID}/preview');
    final Map<String, dynamic> $params = <String, dynamic>{'size': size};
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
  Future<Response<Entry>> _restoreFileVersion({
    required int? versionID,
    required VersionRestoreRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Make an earlier version the current file; the current content is kept as a version',
      operationId: 'restoreFileVersion',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/versions/${versionID}/restore');
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
  Future<Response<NotesListing>> _listNotes({
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'List the folders and notes in a folder, with each note\'s title',
      operationId: 'listNotes',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notes/list');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<NotesListing, NotesListing>($request);
  }

  @override
  Future<Response<NotesSettings>> _getNotesSettings({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Which folder holds the user\'s notes',
      operationId: 'getNotesSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notes/settings');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<NotesSettings, NotesSettings>($request);
  }

  @override
  Future<Response<NotesSettings>> _setNotesSettings({
    required NotesSettings? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Choose the folder that holds the user\'s notes; it must already exist',
      operationId: 'setNotesSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notes/settings');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<NotesSettings, NotesSettings>($request);
  }

  @override
  Future<Response<EditorCapabilities>> _getOfficeCapabilities({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Which files the document editor can open',
      operationId: 'getOfficeCapabilities',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["office"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/office/capabilities');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<EditorCapabilities, EditorCapabilities>($request);
  }

  @override
  Future<Response<EditorSession>> _startOfficeSession({
    required OfficeSessionRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Let the document editor open a file',
      operationId: 'startOfficeSession',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["office"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/office/sessions');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EditorSession, EditorSession>($request);
  }

  @override
  Future<Response<Results>> _searchFiles({
    String? q,
    int? limit,
    int? offset,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Free text matches names fuzzily: substrings, abbreviations such as `invq3` for invoice_q3.pdf, and small typos. It also matches the text inside files when the server reads it, including text recognised in images and scans; every word must appear, and quotes match a phrase. Name matches come first. Tags narrow the results; they have the form `key<op>values`:

- `type` (also `kind`, `is`): `folder`, `file`, a top-level MIME type (`image`, `video`, `text`…), an extension, a MIME subtype or a whole MIME type, such as `type=image,pdf,md` or `type=application/zip`
- `ext`: extensions only
- `in`: a folder and everything below it, such as `in="/My Docs"`
- `modified` (also `date`): `2024`, `2024-06`, `2024-06-15`, `today`, `yesterday`, or a relative `7d`, `2w`, `3m`, `1y`
- `size`: such as `10mb`, `500kb`, `1.5gb`

Operators are `=` or `:` (is), `!=` or a leading `-` (is not), and `>`, `>=`, `<`, `<=` for modified and size. Commas separate alternatives, separate tags must all hold, and `modified=a..b` or `size=a..b` is a range. A relative date is a moment: `modified>7d` is newer than a week ago.''',
      summary: 'Find files and folders by name, text inside them, type, date and size',
      operationId: 'searchFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["search"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/search');
    final Map<String, dynamic> $params = <String, dynamic>{
      'q': q,
      'limit': limit,
      'offset': offset,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Results, Results>($request);
  }

  @override
  Future<Response<Suggestions>> _suggestSearch({
    String? q,
    int? cursor,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Complete the search tag under the cursor',
      operationId: 'suggestSearch',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["search"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/search/suggest');
    final Map<String, dynamic> $params = <String, dynamic>{
      'q': q,
      'cursor': cursor,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<Suggestions, Suggestions>($request);
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
  Future<Response<dynamic>> _emptyTrash({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete everything in the trash permanently',
      operationId: 'emptyTrash',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<TrashListing>> _listTrash({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List deleted items, most recent first',
      operationId: 'listTrash',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<TrashListing, TrashListing>($request);
  }

  @override
  Future<Response<TrashRetention>> _getTrashRetention({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'How long deleted items stay in the trash',
      operationId: 'getTrashRetention',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/retention');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<TrashRetention, TrashRetention>($request);
  }

  @override
  Future<Response<TrashRetention>> _setTrashRetention({
    required TrashPreferences? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Choose how long deleted items stay in the trash',
      operationId: 'setTrashRetention',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/retention');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TrashRetention, TrashRetention>($request);
  }

  @override
  Future<Response<dynamic>> _deleteTrashItem({
    required int? itemID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete one item in the trash permanently',
      operationId: 'deleteTrashItem',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/${itemID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadTrashItem({
    required int? itemID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a deleted item without restoring it; a directory comes as a zip',
      operationId: 'downloadTrashItem',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/${itemID}/content');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _previewTrashItem({
    required int? itemID,
    String? size,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a JPEG thumbnail of a deleted image, video or document',
      operationId: 'previewTrashItem',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/${itemID}/preview');
    final Map<String, dynamic> $params = <String, dynamic>{'size': size};
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
  Future<Response<Entry>> _restoreTrashItem({
    required int? itemID,
    required RestoreRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Put a deleted item back where it was',
      operationId: 'restoreTrashItem',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["trash"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/trash/${itemID}/restore');
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
  Future<Response<VersionRetention>> _getVersionSettings({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'How long earlier versions of files are kept',
      operationId: 'getVersionSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["versions"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/versions/settings');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<VersionRetention, VersionRetention>($request);
  }

  @override
  Future<Response<VersionRetention>> _setVersionSettings({
    required VersionPreferences? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Choose how long earlier versions of files are kept, within the server\'s limits',
      operationId: 'setVersionSettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["versions"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/versions/settings');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<VersionRetention, VersionRetention>($request);
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
