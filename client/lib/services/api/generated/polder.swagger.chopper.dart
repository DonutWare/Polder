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
  Future<Response<List<AppPassword>>> _listAppPasswords({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The logged-in user\'s app passwords, for WebDAV and other apps',
      operationId: 'listAppPasswords',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/app-passwords');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<AppPassword>, AppPassword>($request);
  }

  @override
  Future<Response<NewAppPassword>> _createAppPassword({
    required AppPasswordRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create an app password; needs the account password and returns the new password once',
      operationId: 'createAppPassword',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/app-passwords');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<NewAppPassword, NewAppPassword>($request);
  }

  @override
  Future<Response<dynamic>> _deleteAppPassword({
    required int? appPasswordID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Revoke an app password; it stops working at once',
      operationId: 'deleteAppPassword',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/account/app-passwords/${appPasswordID}',
    );
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<User>> _setAppearance({
    required Appearance? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Choose the theme and accent color the apps use for the logged-in user',
      operationId: 'setAppearance',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/appearance');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<User>> _removeAvatar({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Go back to showing the logged-in user\'s initials',
      operationId: 'removeAvatar',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/avatar');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<User>> _setAvatar({
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Replace the logged-in user\'s icon with the image in the request body',
      operationId: 'setAvatar',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/avatar');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<dynamic>> _changePassword({
    required PasswordChange? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change the logged-in user\'s password; their other sessions are logged out',
      operationId: 'changePassword',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/password');
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
  Future<Response<User>> _setProfile({
    required Profile? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change the logged-in user\'s name and contact details',
      operationId: 'setProfile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["account"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/account/profile');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<User, User>($request);
  }

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
  Future<Response<List<Server>>> _listTrustedServers({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Servers this server federates with',
      operationId: 'listTrustedServers',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/federation/servers');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<Server>, Server>($request);
  }

  @override
  Future<Response<Server>> _addTrustedServer({
    required TrustedServerRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Trust a server for federated sharing; its signing key is pinned',
      operationId: 'addTrustedServer',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/federation/servers');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Server, Server>($request);
  }

  @override
  Future<Response<dynamic>> _removeTrustedServer({
    required int? serverID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Stop trusting a server; every share with it ends',
      operationId: 'removeTrustedServer',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/federation/servers/${serverID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Server>> _updateTrustedServer({
    required int? serverID,
    required ServerOptions? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change how a trusted server is reached and checked',
      operationId: 'updateTrustedServer',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/federation/servers/${serverID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Server, Server>($request);
  }

  @override
  Future<Response<Server>> _refreshTrustedServer({
    required int? serverID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Discover a trusted server again and pin its current signing key',
      operationId: 'refreshTrustedServer',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/admin/federation/servers/${serverID}/refresh',
    );
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Server, Server>($request);
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
  Future<Response<PreviewRegeneration>> _regeneratePreviews({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Make every file\'s preview again in the background',
      operationId: 'regeneratePreviews',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["admin"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/previews/regenerate');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<PreviewRegeneration, PreviewRegeneration>($request);
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
  Future<Response<TokenPair>> _startSession({
    required SessionRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Start another session for the logged-in user, such as for a file provider on this device',
      operationId: 'startSession',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/sessions');
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
  Future<Response<DirectoryResponse>> _searchDirectory({
    String? q,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Find users and groups to share with',
      operationId: 'searchDirectory',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["directory"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/directory');
    final Map<String, dynamic> $params = <String, dynamic>{'q': q};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<DirectoryResponse, DirectoryResponse>($request);
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
  Future<Response<List<Contact>>> _listFederationContacts({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'People on other servers who exchanged an invite with the logged-in user',
      operationId: 'listFederationContacts',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/contacts');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<Contact>, Contact>($request);
  }

  @override
  Future<Response<dynamic>> _removeFederationContact({
    required int? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Remove a contact',
      operationId: 'removeFederationContact',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/contacts/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Invite>>> _listFederationInvites({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The logged-in user\'s open invites for people on other servers',
      operationId: 'listFederationInvites',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/invites');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<Invite>, Invite>($request);
  }

  @override
  Future<Response<Invite>> _createFederationInvite({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Create an invite token that someone on another server can accept',
      operationId: 'createFederationInvite',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/invites');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Invite, Invite>($request);
  }

  @override
  Future<Response<Contact>> _acceptFederationInvite({
    required AcceptInviteRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Accept an invite from someone on a trusted server; they become a contact',
      operationId: 'acceptFederationInvite',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/invites/accept');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Contact, Contact>($request);
  }

  @override
  Future<Response<dynamic>> _revokeFederationInvite({
    required int? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Revoke an open invite',
      operationId: 'revokeFederationInvite',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/invites/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<IncomingFederatedShare>>> _listIncomingFederatedShares({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What people on other servers share with the logged-in user',
      operationId: 'listIncomingFederatedShares',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/incoming');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<IncomingFederatedShare>, IncomingFederatedShare>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _removeIncomingFederatedShare({
    required int? shareID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Decline or remove a share from another server',
      operationId: 'removeIncomingFederatedShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/incoming/${shareID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<IncomingFederatedShare>> _acceptFederatedShare({
    required int? shareID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Accept a share from another server',
      operationId: 'acceptFederatedShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/accept',
    );
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<IncomingFederatedShare, IncomingFederatedShare>(
      $request,
    );
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadFederatedShareFile({
    required int? shareID,
    String? path,
    String? range,
    String? ifNoneMatch,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Download a file inside a share from another server; supports Range',
      operationId: 'downloadFederatedShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/content',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Map<String, String> $headers = {
      if (range != null) 'Range': range,
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
  Future<Response<dynamic>> _uploadFederatedShareFile({
    required int? shareID,
    String? path,
    bool? mustNotExist,
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Upload a file into a share from another server that allows changes',
      operationId: 'uploadFederatedShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/content',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'mustNotExist': mustNotExist,
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
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _copyFederatedShareFile({
    required int? shareID,
    required CopyRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Copy inside a share from another server',
      operationId: 'copyFederatedShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/copy',
    );
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
  Future<Response<dynamic>> _deleteFederatedShareFile({
    required int? shareID,
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete inside a share from another server',
      operationId: 'deleteFederatedShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/files',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
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
  Future<Response<RemoteListResponse>> _listFederatedShareFiles({
    required int? shareID,
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List a folder inside a share from another server',
      operationId: 'listFederatedShareFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/list',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<RemoteListResponse, RemoteListResponse>($request);
  }

  @override
  Future<Response<dynamic>> _makeFederatedShareDirectory({
    required int? shareID,
    required PathRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a folder inside a share from another server',
      operationId: 'makeFederatedShareDirectory',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/mkdir',
    );
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
  Future<Response<dynamic>> _moveFederatedShareFile({
    required int? shareID,
    required CopyRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Move or rename inside a share from another server',
      operationId: 'moveFederatedShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/federation/shares/incoming/${shareID}/move',
    );
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
  Future<Response<List<OutgoingShare>>> _listOutgoingFederatedShares({
    int? fileId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What the logged-in user shares with people on other servers',
      operationId: 'listOutgoingFederatedShares',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/outgoing');
    final Map<String, dynamic> $params = <String, dynamic>{'fileId': fileId};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<OutgoingShare>, OutgoingShare>($request);
  }

  @override
  Future<Response<OutgoingShare>> _createFederatedShare({
    required NewOutgoingShare? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Share a file or folder with someone on a trusted server',
      operationId: 'createFederatedShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/outgoing');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<OutgoingShare, OutgoingShare>($request);
  }

  @override
  Future<Response<dynamic>> _deleteFederatedShare({
    required int? shareID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Stop sharing with a federated recipient; their access ends at once',
      operationId: 'deleteFederatedShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/outgoing/${shareID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<OutgoingShare>> _updateFederatedShare({
    required int? shareID,
    required OutgoingShareChanges? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change what a federated recipient may do',
      operationId: 'updateFederatedShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/shares/outgoing/${shareID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<OutgoingShare, OutgoingShare>($request);
  }

  @override
  Future<Response<FederationStatus>> _getFederationStatus({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Whether federated sharing is available, and the logged-in user\'s cloud ID',
      operationId: 'getFederationStatus',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["federation"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/federation/status');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<FederationStatus, FederationStatus>($request);
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
  Future<Response<Entry>> _copyFile({
    required CopyRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Copy a file, or a directory with everything in it',
      operationId: 'copyFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["files"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/files/copy');
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
      summary: 'Get a thumbnail (JPEG, or PNG when it has transparency) of an image, video or document',
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
      summary: 'Get a thumbnail (JPEG, or PNG when it has transparency) of an earlier version',
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
  Future<Response<List<Group>>> _listGroups({
    String? scope,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Groups the logged-in user is in or created, or every group for administrators',
      operationId: 'listGroups',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups');
    final Map<String, dynamic> $params = <String, dynamic>{'scope': scope};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<Group>, Group>($request);
  }

  @override
  Future<Response<Group>> _createGroup({
    required GroupNameRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a group; the creator becomes its admin',
      operationId: 'createGroup',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Group, Group>($request);
  }

  @override
  Future<Response<dynamic>> _deleteGroup({
    required int? groupID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete a group; what was shared with it is no longer shared',
      operationId: 'deleteGroup',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<GroupDetails>> _getGroup({
    required int? groupID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'A group and its members',
      operationId: 'getGroup',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<GroupDetails, GroupDetails>($request);
  }

  @override
  Future<Response<Group>> _renameGroup({
    required int? groupID,
    required GroupNameRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Rename a group; group admins only',
      operationId: 'renameGroup',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Group, Group>($request);
  }

  @override
  Future<Response<GroupDetails>> _addGroupMember({
    required int? groupID,
    required NewMember? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Add someone to a group; group admins only',
      operationId: 'addGroupMember',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}/members');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<GroupDetails, GroupDetails>($request);
  }

  @override
  Future<Response<dynamic>> _removeGroupMember({
    required int? groupID,
    required int? userID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Remove someone from a group, or leave it yourself',
      operationId: 'removeGroupMember',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}/members/${userID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<GroupDetails>> _setGroupMemberRole({
    required int? groupID,
    required int? userID,
    required RoleChange? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change a member\'s role; group admins only',
      operationId: 'setGroupMemberRole',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}/members/${userID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<GroupDetails, GroupDetails>($request);
  }

  @override
  Future<Response<List<Share>>> _listGroupShares({
    required int? groupID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What is shared with a group',
      operationId: 'listGroupShares',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["groups"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/groups/${groupID}/shares');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<Share>, Share>($request);
  }

  @override
  Future<Response<LinkPreview>> _getLinkPreview({
    required String? url,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Describe a web link with its title, summary and site, as the server sees it',
      operationId: 'getLinkPreview',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["link-previews"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/link-previews');
    final Map<String, dynamic> $params = <String, dynamic>{'url': url};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<LinkPreview, LinkPreview>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _getLinkPreviewImage({
    required String? url,
    String? kind,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Get a web link\'s preview image or site icon, fetched by the server',
      operationId: 'getLinkPreviewImage',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["link-previews"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/link-previews/image');
    final Map<String, dynamic> $params = <String, dynamic>{
      'url': url,
      'kind': kind,
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
  Future<Response<List<ShareLink>>> _listShareLinks({
    int? fileId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'The logged-in user\'s share links',
      operationId: 'listShareLinks',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["links"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/links');
    final Map<String, dynamic> $params = <String, dynamic>{'fileId': fileId};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<ShareLink>, ShareLink>($request);
  }

  @override
  Future<Response<ShareLink>> _createShareLink({
    required NewShareLink? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a share link to a file or folder',
      operationId: 'createShareLink',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["links"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/links');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShareLink, ShareLink>($request);
  }

  @override
  Future<Response<LinkMatch>> _matchShareLink({
    required String? code,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Find where a share link\'s item is for the logged-in user: their own file or inside a share',
      operationId: 'matchShareLink',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["links"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/links/match/${code}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<LinkMatch, LinkMatch>($request);
  }

  @override
  Future<Response<dynamic>> _deleteShareLink({
    required int? linkID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete a share link; it stops working at once',
      operationId: 'deleteShareLink',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["links"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/links/${linkID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ShareLink>> _updateShareLink({
    required int? linkID,
    required LinkChanges? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change a share link\'s access, password or expiry',
      operationId: 'updateShareLink',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["links"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/links/${linkID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShareLink, ShareLink>($request);
  }

  @override
  Future<Response<NotesListing>> _listNotes({
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List the folders and notes in a folder',
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
  Future<Response<LinkInfo>> _getPublicLink({
    required String? code,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What a share link points to; hidden while it needs a password',
      operationId: 'getPublicLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<LinkInfo, LinkInfo>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadPublicLinkArchive({
    required String? code,
    String? path,
    String? token,
    String? xPolderShareToken,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a folder inside a share link as a zip',
      operationId: 'downloadPublicLinkArchive',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/archive');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'token': token,
    };
    final Map<String, String> $headers = {
      if (xPolderShareToken != null) 'X-Polder-Share-Token': xPolderShareToken,
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
  Future<Response<Stream<List<int>>>> _downloadPublicLinkFile({
    required String? code,
    String? path,
    String? token,
    String? xPolderShareToken,
    String? range,
    bool? download,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a file inside a share link; supports Range',
      operationId: 'downloadPublicLinkFile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/content');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'token': token,
      'download': download,
    };
    final Map<String, String> $headers = {
      if (xPolderShareToken != null) 'X-Polder-Share-Token': xPolderShareToken,
      if (range != null) 'Range': range,
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
  Future<Response<Entry>> _uploadPublicLinkFile({
    required String? code,
    String? path,
    DateTime? mtime,
    String? xPolderShareToken,
    String? xPolderTransferId,
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Upload a file into a share link that accepts uploads; it never replaces an existing file',
      operationId: 'uploadPublicLinkFile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/content');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'mtime': mtime,
    };
    final Map<String, String> $headers = {
      if (xPolderShareToken != null) 'X-Polder-Share-Token': xPolderShareToken,
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
  Future<Response<ListResponse>> _listPublicLinkFiles({
    required String? code,
    String? path,
    String? token,
    String? xPolderShareToken,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List a folder inside a share link',
      operationId: 'listPublicLinkFiles',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/list');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'token': token,
    };
    final Map<String, String> $headers = {
      if (xPolderShareToken != null) 'X-Polder-Share-Token': xPolderShareToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<ListResponse, ListResponse>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _previewPublicLinkFile({
    required String? code,
    String? path,
    String? token,
    String? xPolderShareToken,
    String? size,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a thumbnail (JPEG, or PNG when it has transparency) of a file inside a share link',
      operationId: 'previewPublicLinkFile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/preview');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'token': token,
      'size': size,
    };
    final Map<String, String> $headers = {
      if (xPolderShareToken != null) 'X-Polder-Share-Token': xPolderShareToken,
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
  Future<Response<LinkUnlock>> _unlockPublicLink({
    required String? code,
    required UnlockRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Enter a share link\'s password, or open a link without one, to get a token for its contents',
      operationId: 'unlockPublicLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/public/links/${code}/unlock');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LinkUnlock, LinkUnlock>($request);
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
  Future<Response<ServerInfo>> _getServerInfo({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Version, commit and build of the server binary',
      operationId: 'getServerInfo',
      consumes: [],
      produces: [],
      security: [],
      tags: ["server"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/server/info');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<ServerInfo, ServerInfo>($request);
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
  Future<Response<Share>> _createShare({
    required NewShare? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Share a file or folder with a user or group',
      operationId: 'createShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Share, Share>($request);
  }

  @override
  Future<Response<List<IncomingShare>>> _listIncomingShares({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What others share with the logged-in user, directly or through a group',
      operationId: 'listIncomingShares',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/incoming');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<IncomingShare>, IncomingShare>($request);
  }

  @override
  Future<Response<List<Share>>> _listOutgoingShares({
    int? fileId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'What the logged-in user shares with others',
      operationId: 'listOutgoingShares',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/outgoing');
    final Map<String, dynamic> $params = <String, dynamic>{'fileId': fileId};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<Share>, Share>($request);
  }

  @override
  Future<Response<ShareDisplaySettings>> _getShareDisplaySettings({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Whether shares appear in the logged-in user\'s files',
      operationId: 'getShareDisplaySettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/settings');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<ShareDisplaySettings, ShareDisplaySettings>($request);
  }

  @override
  Future<Response<ShareDisplaySettings>> _setShareDisplaySettings({
    required ShareDisplaySettings? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Show or hide shares at the root of the logged-in user\'s files',
      operationId: 'setShareDisplaySettings',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/settings');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShareDisplaySettings, ShareDisplaySettings>($request);
  }

  @override
  Future<Response<dynamic>> _deleteShare({
    required int? shareID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Stop sharing; recipients of a direct share may also remove it',
      operationId: 'deleteShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Share>> _updateShare({
    required int? shareID,
    required ShareChanges? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Change what a share\'s recipients may do',
      operationId: 'updateShare',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Share, Share>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> _downloadShareArchive({
    required int? shareID,
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a folder inside a share as a zip',
      operationId: 'downloadShareArchive',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/archive');
    final Map<String, dynamic> $params = <String, dynamic>{'path': path};
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
  Future<Response<Stream<List<int>>>> _downloadShareFile({
    required int? shareID,
    String? path,
    String? range,
    bool? download,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Download a file inside a share; supports Range',
      operationId: 'downloadShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/content');
    final Map<String, dynamic> $params = <String, dynamic>{
      'path': path,
      'download': download,
    };
    final Map<String, String> $headers = {if (range != null) 'Range': range};
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
  Future<Response<Entry>> _uploadShareFile({
    required int? shareID,
    String? path,
    int? baseRev,
    DateTime? mtime,
    String? xPolderTransferId,
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Upload a file into a share that allows changes',
      operationId: 'uploadShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/content');
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
  Future<Response<Entry>> _copyShareFile({
    required int? shareID,
    required CopyRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Copy inside a share that allows changes',
      operationId: 'copyShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/copy');
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
  Future<Response<dynamic>> _deleteShareFile({
    required int? shareID,
    String? path,
    int? baseRev,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Delete inside a share that allows changes; it goes to the owner\'s trash',
      operationId: 'deleteShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/files');
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
  Future<Response<ListResponse>> _listShareFiles({
    required int? shareID,
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List a folder inside a share',
      operationId: 'listShareFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/list');
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
  Future<Response<Entry>> _makeShareDirectory({
    required int? shareID,
    required PathRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create a folder inside a share that allows changes',
      operationId: 'makeShareDirectory',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/mkdir');
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
  Future<Response<Entry>> _moveShareFile({
    required int? shareID,
    required MoveRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Move or rename inside a share that allows changes',
      operationId: 'moveShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/move');
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
  Future<Response<Stream<List<int>>>> _previewShareFile({
    required int? shareID,
    String? path,
    String? size,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get a thumbnail (JPEG, or PNG when it has transparency) of a file inside a share',
      operationId: 'previewShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/preview');
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
  Future<Response<Entry>> _statShareFile({
    required int? shareID,
    String? path,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get one file or folder inside a share',
      operationId: 'statShareFile',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["shares"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/shares/${shareID}/stat');
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
  Future<Response<BatchStatus>> _createUploadBatch({
    required BatchRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Start uploading a batch of files; returns the chunks the server is missing',
      operationId: 'createUploadBatch',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/batches');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<BatchStatus, BatchStatus>($request);
  }

  @override
  Future<Response<dynamic>> _abortUploadBatch({
    required String? batchID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Cancel a batch; files already stored stay',
      operationId: 'abortUploadBatch',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/batches/${batchID}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<BatchStatus>> _getUploadBatch({
    required String? batchID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Get the chunks a batch is still missing and the files that are done',
      operationId: 'getUploadBatch',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/batches/${batchID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<BatchStatus, BatchStatus>($request);
  }

  @override
  Future<Response<BatchStatus>> _streamUploadBatch({
    required String? batchID,
    required Object? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Send the missing chunks back to back as one body; each file is stored once it is complete',
      operationId: 'streamUploadBatch',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/batches/${batchID}/stream');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<BatchStatus, BatchStatus>($request);
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
  Future<Response<Stream<List<int>>>> _downloadSyncFiles({
    required DownloadRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Send several files in one response: per file a JSON header line, then exactly size bytes of content',
      operationId: 'downloadSyncFiles',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/sync/downloads');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Stream<List<int>>, int>($request);
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
      summary: 'Get a thumbnail (JPEG, or PNG when it has transparency) of a deleted image, video or document',
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
  Future<Response<String>> _getUserAvatar({
    required int? userID,
    required String? imageID,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'A user\'s icon',
      operationId: 'getUserAvatar',
      consumes: [],
      produces: [],
      security: [],
      tags: ["users"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/users/${userID}/avatar/${imageID}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
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
