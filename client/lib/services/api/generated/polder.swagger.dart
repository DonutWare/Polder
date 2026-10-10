// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';

import 'polder.models.swagger.dart';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;

import 'polder.enums.swagger.dart' as enums;
import 'polder.metadata.swagger.dart';
export 'polder.enums.swagger.dart';
export 'polder.models.swagger.dart';

part 'polder.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Polder extends ChopperService {
  static Polder create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Polder(client);
    }

    final newClient = ChopperClient(
      services: [_$Polder()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl,
    );
    return _$Polder(newClient);
  }

  ///Choose the theme and accent color the apps use for the logged-in user
  Future<chopper.Response<User>> setAppearance({required Appearance? body}) {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _setAppearance(body: body);
  }

  ///Choose the theme and accent color the apps use for the logged-in user
  @PUT(path: '/api/v1/account/appearance', optionalBody: true)
  Future<chopper.Response<User>> _setAppearance({
    @Body() required Appearance? body,
    @chopper.Tag()
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
  });

  ///Go back to showing the logged-in user's initials
  Future<chopper.Response<User>> removeAvatar() {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _removeAvatar();
  }

  ///Go back to showing the logged-in user's initials
  @DELETE(path: '/api/v1/account/avatar')
  Future<chopper.Response<User>> _removeAvatar({
    @chopper.Tag()
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
  });

  ///Replace the logged-in user's icon with the image in the request body
  Future<chopper.Response<User>> setAvatar({required Object? body}) {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _setAvatar(body: body);
  }

  ///Replace the logged-in user's icon with the image in the request body
  @PUT(path: '/api/v1/account/avatar', optionalBody: true)
  Future<chopper.Response<User>> _setAvatar({
    @Body() required Object? body,
    @chopper.Tag()
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
  });

  ///Change the logged-in user's name and contact details
  Future<chopper.Response<User>> setProfile({required Profile? body}) {
    generatedMapping.putIfAbsent(User, () => User.fromJsonFactory);

    return _setProfile(body: body);
  }

  ///Change the logged-in user's name and contact details
  @PUT(path: '/api/v1/account/profile', optionalBody: true)
  Future<chopper.Response<User>> _setProfile({
    @Body() required Profile? body,
    @chopper.Tag()
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
  });

  ///Page through what happened to files and sessions, newest first
  ///@param user me, all, or a user id; anything but your own activity needs the administrator role
  ///@param before Cursor from the previous page; 0 starts at the newest
  ///@param limit Maximum number of entries to return; the server caps it
  Future<chopper.Response<LogPage>> listActivity({String? user, int? before, int? limit}) {
    generatedMapping.putIfAbsent(LogPage, () => LogPage.fromJsonFactory);

    return _listActivity(user: user, before: before, limit: limit);
  }

  ///Page through what happened to files and sessions, newest first
  ///@param user me, all, or a user id; anything but your own activity needs the administrator role
  ///@param before Cursor from the previous page; 0 starts at the newest
  ///@param limit Maximum number of entries to return; the server caps it
  @GET(path: '/api/v1/activity')
  Future<chopper.Response<LogPage>> _listActivity({
    @Query('user') String? user,
    @Query('before') int? before,
    @Query('limit') int? limit,
    @chopper.Tag()
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
  });

  ///Uploads and downloads in progress
  ///@param user me, all, or a user id; anything but your own transfers needs the administrator role
  Future<chopper.Response<LiveTransfers>> listLiveTransfers({String? user}) {
    generatedMapping.putIfAbsent(LiveTransfers, () => LiveTransfers.fromJsonFactory);

    return _listLiveTransfers(user: user);
  }

  ///Uploads and downloads in progress
  ///@param user me, all, or a user id; anything but your own transfers needs the administrator role
  @GET(path: '/api/v1/activity/live')
  Future<chopper.Response<LiveTransfers>> _listLiveTransfers({
    @Query('user') String? user,
    @chopper.Tag()
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
  });

  ///Add the image in the request body to the login screen's backgrounds
  Future<chopper.Response<Branding>> addBrandingBackground({required Object? body}) {
    generatedMapping.putIfAbsent(Branding, () => Branding.fromJsonFactory);

    return _addBrandingBackground(body: body);
  }

  ///Add the image in the request body to the login screen's backgrounds
  @POST(path: '/api/v1/admin/branding/backgrounds', optionalBody: true)
  Future<chopper.Response<Branding>> _addBrandingBackground({
    @Body() required Object? body,
    @chopper.Tag()
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
  });

  ///Remove one of the login screen's backgrounds
  ///@param imageID
  Future<chopper.Response> removeBrandingBackground({required String? imageID}) {
    return _removeBrandingBackground(imageID: imageID);
  }

  ///Remove one of the login screen's backgrounds
  ///@param imageID
  @DELETE(path: '/api/v1/admin/branding/backgrounds/{imageID}')
  Future<chopper.Response> _removeBrandingBackground({
    @Path('imageID') required String? imageID,
    @chopper.Tag()
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
  });

  ///Go back to the apps' own icon
  Future<chopper.Response> removeBrandingIcon() {
    return _removeBrandingIcon();
  }

  ///Go back to the apps' own icon
  @DELETE(path: '/api/v1/admin/branding/icon')
  Future<chopper.Response> _removeBrandingIcon({
    @chopper.Tag()
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
  });

  ///Replace the server's icon with the image in the request body
  Future<chopper.Response<Branding>> setBrandingIcon({required Object? body}) {
    generatedMapping.putIfAbsent(Branding, () => Branding.fromJsonFactory);

    return _setBrandingIcon(body: body);
  }

  ///Replace the server's icon with the image in the request body
  @PUT(path: '/api/v1/admin/branding/icon', optionalBody: true)
  Future<chopper.Response<Branding>> _setBrandingIcon({
    @Body() required Object? body,
    @chopper.Tag()
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
  });

  ///Page through the server log, newest first
  ///@param level Leave out entries below this level
  ///@param component Only entries from this part of the server
  ///@param q Only entries whose message or attributes contain this text, ignoring case
  ///@param before Cursor from the previous page; empty starts at the newest
  ///@param limit Maximum number of entries to return; the server caps it
  Future<chopper.Response<ServerLogPage>> listLogs({
    enums.ApiV1AdminLogsGetLevel? level,
    String? component,
    String? q,
    String? before,
    int? limit,
  }) {
    generatedMapping.putIfAbsent(ServerLogPage, () => ServerLogPage.fromJsonFactory);

    return _listLogs(level: level?.value?.toString(), component: component, q: q, before: before, limit: limit);
  }

  ///Page through the server log, newest first
  ///@param level Leave out entries below this level
  ///@param component Only entries from this part of the server
  ///@param q Only entries whose message or attributes contain this text, ignoring case
  ///@param before Cursor from the previous page; empty starts at the newest
  ///@param limit Maximum number of entries to return; the server caps it
  @GET(path: '/api/v1/admin/logs')
  Future<chopper.Response<ServerLogPage>> _listLogs({
    @Query('level') String? level,
    @Query('component') String? component,
    @Query('q') String? q,
    @Query('before') String? before,
    @Query('limit') int? limit,
    @chopper.Tag()
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
  });

  ///Parts of the server that appear in the log
  Future<chopper.Response<LogComponents>> listLogComponents() {
    generatedMapping.putIfAbsent(LogComponents, () => LogComponents.fromJsonFactory);

    return _listLogComponents();
  }

  ///Parts of the server that appear in the log
  @GET(path: '/api/v1/admin/logs/components')
  Future<chopper.Response<LogComponents>> _listLogComponents({
    @chopper.Tag()
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
  });

  ///The log files, one per day, newest first
  Future<chopper.Response<LogFiles>> listLogFiles() {
    generatedMapping.putIfAbsent(LogFiles, () => LogFiles.fromJsonFactory);

    return _listLogFiles();
  }

  ///The log files, one per day, newest first
  @GET(path: '/api/v1/admin/logs/files')
  Future<chopper.Response<LogFiles>> _listLogFiles({
    @chopper.Tag()
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
  });

  ///Download one day's log file as JSON lines
  ///@param name
  Future<chopper.Response<Stream<List<int>>>> downloadLogFile({required String? name}) {
    return _downloadLogFile(name: name);
  }

  ///Download one day's log file as JSON lines
  ///@param name
  @GET(path: '/api/v1/admin/logs/files/{name}')
  Future<chopper.Response<Stream<List<int>>>> _downloadLogFile({
    @Path('name') required String? name,
    @chopper.Tag()
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
  });

  ///State of the search index and of reading text from files
  Future<chopper.Response<SearchStatus>> getSearchStatus() {
    generatedMapping.putIfAbsent(SearchStatus, () => SearchStatus.fromJsonFactory);

    return _getSearchStatus();
  }

  ///State of the search index and of reading text from files
  @GET(path: '/api/v1/admin/search')
  Future<chopper.Response<SearchStatus>> _getSearchStatus({
    @chopper.Tag()
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
  });

  ///Rebuild the search index from scratch in the background
  Future<chopper.Response> rebuildSearchIndex() {
    return _rebuildSearchIndex();
  }

  ///Rebuild the search index from scratch in the background
  @POST(path: '/api/v1/admin/search/rebuild', optionalBody: true)
  Future<chopper.Response> _rebuildSearchIndex({
    @chopper.Tag()
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
  });

  ///Server-wide settings
  Future<chopper.Response<ServerSettings>> getServerSettings() {
    generatedMapping.putIfAbsent(ServerSettings, () => ServerSettings.fromJsonFactory);

    return _getServerSettings();
  }

  ///Server-wide settings
  @GET(path: '/api/v1/admin/settings')
  Future<chopper.Response<ServerSettings>> _getServerSettings({
    @chopper.Tag()
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
  });

  ///Change server-wide settings
  Future<chopper.Response<ServerSettings>> updateServerSettings({required ServerSettingsChanges? body}) {
    generatedMapping.putIfAbsent(ServerSettings, () => ServerSettings.fromJsonFactory);

    return _updateServerSettings(body: body);
  }

  ///Change server-wide settings
  @PATCH(path: '/api/v1/admin/settings', optionalBody: true)
  Future<chopper.Response<ServerSettings>> _updateServerSettings({
    @Body() required ServerSettingsChanges? body,
    @chopper.Tag()
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
  });

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

  ///How the apps present this server, shown before logging in
  Future<chopper.Response<Branding>> getBranding() {
    generatedMapping.putIfAbsent(Branding, () => Branding.fromJsonFactory);

    return _getBranding();
  }

  ///How the apps present this server, shown before logging in
  @GET(path: '/api/v1/branding')
  Future<chopper.Response<Branding>> _getBranding({
    @chopper.Tag()
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
  });

  ///One of the login screen's backgrounds
  ///@param imageID
  Future<chopper.Response<String>> getBrandingBackground({required String? imageID}) {
    return _getBrandingBackground(imageID: imageID);
  }

  ///One of the login screen's backgrounds
  ///@param imageID
  @GET(path: '/api/v1/branding/backgrounds/{imageID}')
  Future<chopper.Response<String>> _getBrandingBackground({
    @Path('imageID') required String? imageID,
    @chopper.Tag()
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
  });

  ///The server's icon
  ///@param imageID
  Future<chopper.Response<String>> getBrandingIcon({required String? imageID}) {
    return _getBrandingIcon(imageID: imageID);
  }

  ///The server's icon
  ///@param imageID
  @GET(path: '/api/v1/branding/icon/{imageID}')
  Future<chopper.Response<String>> _getBrandingIcon({
    @Path('imageID') required String? imageID,
    @chopper.Tag()
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
  });

  ///Live activity over a WebSocket
  Future<chopper.Response> events() {
    return _events();
  }

  ///Live activity over a WebSocket
  @GET(path: '/api/v1/events')
  Future<chopper.Response> _events({
    @chopper.Tag()
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
  ///@param X-Polder-Transfer-Id Any ID the client picks; live transfer events echo it back as clientId
  Future<chopper.Response<Entry>> uploadFile({
    String? path,
    int? baseRev,
    DateTime? mtime,
    String? xPolderTransferId,
    required Object? body,
  }) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _uploadFile(
      path: path,
      baseRev: baseRev,
      mtime: mtime,
      xPolderTransferId: xPolderTransferId?.toString(),
      body: body,
    );
  }

  ///Upload a whole file as the request body
  ///@param path Where to store the file, such as /Photos/cat.jpg
  ///@param baseRev Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there
  ///@param mtime Modification time to record, as RFC 3339; defaults to now
  ///@param X-Polder-Transfer-Id Any ID the client picks; live transfer events echo it back as clientId
  @PUT(path: '/api/v1/files/content', optionalBody: true)
  Future<chopper.Response<Entry>> _uploadFile({
    @Query('path') String? path,
    @Query('baseRev') int? baseRev,
    @Query('mtime') DateTime? mtime,
    @Header('X-Polder-Transfer-Id') String? xPolderTransferId,
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

  ///What a file links to and which files link to it
  ///@param id The file's id
  Future<chopper.Response<LinksResponse>> listFileLinks({int? id}) {
    generatedMapping.putIfAbsent(LinksResponse, () => LinksResponse.fromJsonFactory);

    return _listFileLinks(id: id);
  }

  ///What a file links to and which files link to it
  ///@param id The file's id
  @GET(path: '/api/v1/files/links')
  Future<chopper.Response<LinksResponse>> _listFileLinks({
    @Query('id') int? id,
    @chopper.Tag()
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

  ///Get a JPEG thumbnail of an image, video or document
  ///@param path
  ///@param size Thumbnail width and height in pixels
  Future<chopper.Response<Stream<List<int>>>> previewFile({String? path, enums.ApiV1FilesPreviewGetSize? size}) {
    return _previewFile(path: path, size: size?.value?.toString());
  }

  ///Get a JPEG thumbnail of an image, video or document
  ///@param path
  ///@param size Thumbnail width and height in pixels
  @GET(path: '/api/v1/files/preview')
  Future<chopper.Response<Stream<List<int>>>> _previewFile({
    @Query('path') String? path,
    @Query('size') String? size,
    @chopper.Tag()
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
  });

  ///Look files up by id, wherever they are now
  Future<chopper.Response<ResolveResponse>> resolveFiles({required ResolveRequest? body}) {
    generatedMapping.putIfAbsent(ResolveResponse, () => ResolveResponse.fromJsonFactory);

    return _resolveFiles(body: body);
  }

  ///Look files up by id, wherever they are now
  @POST(path: '/api/v1/files/resolve', optionalBody: true)
  Future<chopper.Response<ResolveResponse>> _resolveFiles({
    @Body() required ResolveRequest? body,
    @chopper.Tag()
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

  ///List a file's earlier versions, newest first
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  Future<chopper.Response<VersionListing>> listFileVersions({String? path}) {
    generatedMapping.putIfAbsent(VersionListing, () => VersionListing.fromJsonFactory);

    return _listFileVersions(path: path);
  }

  ///List a file's earlier versions, newest first
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  @GET(path: '/api/v1/files/versions')
  Future<chopper.Response<VersionListing>> _listFileVersions({
    @Query('path') String? path,
    @chopper.Tag()
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
  });

  ///Delete one earlier version permanently
  ///@param versionID
  Future<chopper.Response> deleteFileVersion({required int? versionID}) {
    return _deleteFileVersion(versionID: versionID);
  }

  ///Delete one earlier version permanently
  ///@param versionID
  @DELETE(path: '/api/v1/files/versions/{versionID}')
  Future<chopper.Response> _deleteFileVersion({
    @Path('versionID') required int? versionID,
    @chopper.Tag()
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
  });

  ///Download an earlier version of a file
  ///@param versionID
  Future<chopper.Response<Stream<List<int>>>> downloadFileVersion({required int? versionID}) {
    return _downloadFileVersion(versionID: versionID);
  }

  ///Download an earlier version of a file
  ///@param versionID
  @GET(path: '/api/v1/files/versions/{versionID}/content')
  Future<chopper.Response<Stream<List<int>>>> _downloadFileVersion({
    @Path('versionID') required int? versionID,
    @chopper.Tag()
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
  });

  ///Get a JPEG thumbnail of an earlier version
  ///@param versionID
  ///@param size Thumbnail width and height in pixels
  Future<chopper.Response<Stream<List<int>>>> previewFileVersion({
    required int? versionID,
    enums.ApiV1FilesVersionsVersionIDPreviewGetSize? size,
  }) {
    return _previewFileVersion(versionID: versionID, size: size?.value?.toString());
  }

  ///Get a JPEG thumbnail of an earlier version
  ///@param versionID
  ///@param size Thumbnail width and height in pixels
  @GET(path: '/api/v1/files/versions/{versionID}/preview')
  Future<chopper.Response<Stream<List<int>>>> _previewFileVersion({
    @Path('versionID') required int? versionID,
    @Query('size') String? size,
    @chopper.Tag()
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
  });

  ///Make an earlier version the current file; the current content is kept as a version
  ///@param versionID
  Future<chopper.Response<Entry>> restoreFileVersion({required int? versionID, required VersionRestoreRequest? body}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _restoreFileVersion(versionID: versionID, body: body);
  }

  ///Make an earlier version the current file; the current content is kept as a version
  ///@param versionID
  @POST(path: '/api/v1/files/versions/{versionID}/restore', optionalBody: true)
  Future<chopper.Response<Entry>> _restoreFileVersion({
    @Path('versionID') required int? versionID,
    @Body() required VersionRestoreRequest? body,
    @chopper.Tag()
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
  });

  ///List the folders and notes in a folder
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  Future<chopper.Response<NotesListing>> listNotes({String? path}) {
    generatedMapping.putIfAbsent(NotesListing, () => NotesListing.fromJsonFactory);

    return _listNotes(path: path);
  }

  ///List the folders and notes in a folder
  ///@param path Path inside the user's storage, such as /Photos/cat.jpg; empty means the root
  @GET(path: '/api/v1/notes/list')
  Future<chopper.Response<NotesListing>> _listNotes({
    @Query('path') String? path,
    @chopper.Tag()
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
  });

  ///Which folder holds the user's notes
  Future<chopper.Response<NotesSettings>> getNotesSettings() {
    generatedMapping.putIfAbsent(NotesSettings, () => NotesSettings.fromJsonFactory);

    return _getNotesSettings();
  }

  ///Which folder holds the user's notes
  @GET(path: '/api/v1/notes/settings')
  Future<chopper.Response<NotesSettings>> _getNotesSettings({
    @chopper.Tag()
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
  });

  ///Choose the folder that holds the user's notes; it must already exist
  Future<chopper.Response<NotesSettings>> setNotesSettings({required NotesSettings? body}) {
    generatedMapping.putIfAbsent(NotesSettings, () => NotesSettings.fromJsonFactory);

    return _setNotesSettings(body: body);
  }

  ///Choose the folder that holds the user's notes; it must already exist
  @PUT(path: '/api/v1/notes/settings', optionalBody: true)
  Future<chopper.Response<NotesSettings>> _setNotesSettings({
    @Body() required NotesSettings? body,
    @chopper.Tag()
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
  });

  ///Which files the document editor can open
  Future<chopper.Response<EditorCapabilities>> getOfficeCapabilities() {
    generatedMapping.putIfAbsent(EditorCapabilities, () => EditorCapabilities.fromJsonFactory);

    return _getOfficeCapabilities();
  }

  ///Which files the document editor can open
  @GET(path: '/api/v1/office/capabilities')
  Future<chopper.Response<EditorCapabilities>> _getOfficeCapabilities({
    @chopper.Tag()
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
  });

  ///Let the document editor open a file
  Future<chopper.Response<EditorSession>> startOfficeSession({required OfficeSessionRequest? body}) {
    generatedMapping.putIfAbsent(EditorSession, () => EditorSession.fromJsonFactory);

    return _startOfficeSession(body: body);
  }

  ///Let the document editor open a file
  @POST(path: '/api/v1/office/sessions', optionalBody: true)
  Future<chopper.Response<EditorSession>> _startOfficeSession({
    @Body() required OfficeSessionRequest? body,
    @chopper.Tag()
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
  });

  ///Find files and folders by name, text inside them, type, date and size
  ///@param q What to look for; see the operation description for tags
  ///@param limit
  ///@param offset
  Future<chopper.Response<Results>> searchFiles({String? q, int? limit, int? offset}) {
    generatedMapping.putIfAbsent(Results, () => Results.fromJsonFactory);

    return _searchFiles(q: q, limit: limit, offset: offset);
  }

  ///Find files and folders by name, text inside them, type, date and size
  ///@param q What to look for; see the operation description for tags
  ///@param limit
  ///@param offset
  @GET(path: '/api/v1/search')
  Future<chopper.Response<Results>> _searchFiles({
    @Query('q') String? q,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @chopper.Tag()
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
  });

  ///Complete the search tag under the cursor
  ///@param q
  ///@param cursor Caret position in the query, in UTF-16 code units
  Future<chopper.Response<Suggestions>> suggestSearch({String? q, int? cursor}) {
    generatedMapping.putIfAbsent(Suggestions, () => Suggestions.fromJsonFactory);

    return _suggestSearch(q: q, cursor: cursor);
  }

  ///Complete the search tag under the cursor
  ///@param q
  ///@param cursor Caret position in the query, in UTF-16 code units
  @GET(path: '/api/v1/search/suggest')
  Future<chopper.Response<Suggestions>> _suggestSearch({
    @Query('q') String? q,
    @Query('cursor') int? cursor,
    @chopper.Tag()
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
  });

  ///Version, commit and build of the server binary
  Future<chopper.Response<ServerInfo>> getServerInfo() {
    generatedMapping.putIfAbsent(ServerInfo, () => ServerInfo.fromJsonFactory);

    return _getServerInfo();
  }

  ///Version, commit and build of the server binary
  @GET(path: '/api/v1/server/info')
  Future<chopper.Response<ServerInfo>> _getServerInfo({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Version, commit and build of the server binary',
      operationId: 'getServerInfo',
      consumes: [],
      produces: [],
      security: ["bearer"],
      tags: ["server"],
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

  ///Delete everything in the trash permanently
  Future<chopper.Response> emptyTrash() {
    return _emptyTrash();
  }

  ///Delete everything in the trash permanently
  @DELETE(path: '/api/v1/trash')
  Future<chopper.Response> _emptyTrash({
    @chopper.Tag()
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
  });

  ///List deleted items, most recent first
  Future<chopper.Response<TrashListing>> listTrash() {
    generatedMapping.putIfAbsent(TrashListing, () => TrashListing.fromJsonFactory);

    return _listTrash();
  }

  ///List deleted items, most recent first
  @GET(path: '/api/v1/trash')
  Future<chopper.Response<TrashListing>> _listTrash({
    @chopper.Tag()
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
  });

  ///How long deleted items stay in the trash
  Future<chopper.Response<TrashRetention>> getTrashRetention() {
    generatedMapping.putIfAbsent(TrashRetention, () => TrashRetention.fromJsonFactory);

    return _getTrashRetention();
  }

  ///How long deleted items stay in the trash
  @GET(path: '/api/v1/trash/retention')
  Future<chopper.Response<TrashRetention>> _getTrashRetention({
    @chopper.Tag()
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
  });

  ///Choose how long deleted items stay in the trash
  Future<chopper.Response<TrashRetention>> setTrashRetention({required TrashPreferences? body}) {
    generatedMapping.putIfAbsent(TrashRetention, () => TrashRetention.fromJsonFactory);

    return _setTrashRetention(body: body);
  }

  ///Choose how long deleted items stay in the trash
  @PUT(path: '/api/v1/trash/retention', optionalBody: true)
  Future<chopper.Response<TrashRetention>> _setTrashRetention({
    @Body() required TrashPreferences? body,
    @chopper.Tag()
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
  });

  ///Delete one item in the trash permanently
  ///@param itemID
  Future<chopper.Response> deleteTrashItem({required int? itemID}) {
    return _deleteTrashItem(itemID: itemID);
  }

  ///Delete one item in the trash permanently
  ///@param itemID
  @DELETE(path: '/api/v1/trash/{itemID}')
  Future<chopper.Response> _deleteTrashItem({
    @Path('itemID') required int? itemID,
    @chopper.Tag()
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
  });

  ///Download a deleted item without restoring it; a directory comes as a zip
  ///@param itemID
  Future<chopper.Response<Stream<List<int>>>> downloadTrashItem({required int? itemID}) {
    return _downloadTrashItem(itemID: itemID);
  }

  ///Download a deleted item without restoring it; a directory comes as a zip
  ///@param itemID
  @GET(path: '/api/v1/trash/{itemID}/content')
  Future<chopper.Response<Stream<List<int>>>> _downloadTrashItem({
    @Path('itemID') required int? itemID,
    @chopper.Tag()
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
  });

  ///Get a JPEG thumbnail of a deleted image, video or document
  ///@param itemID
  ///@param size Thumbnail width and height in pixels
  Future<chopper.Response<Stream<List<int>>>> previewTrashItem({
    required int? itemID,
    enums.ApiV1TrashItemIDPreviewGetSize? size,
  }) {
    return _previewTrashItem(itemID: itemID, size: size?.value?.toString());
  }

  ///Get a JPEG thumbnail of a deleted image, video or document
  ///@param itemID
  ///@param size Thumbnail width and height in pixels
  @GET(path: '/api/v1/trash/{itemID}/preview')
  Future<chopper.Response<Stream<List<int>>>> _previewTrashItem({
    @Path('itemID') required int? itemID,
    @Query('size') String? size,
    @chopper.Tag()
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
  });

  ///Put a deleted item back where it was
  ///@param itemID
  Future<chopper.Response<Entry>> restoreTrashItem({required int? itemID, required RestoreRequest? body}) {
    generatedMapping.putIfAbsent(Entry, () => Entry.fromJsonFactory);

    return _restoreTrashItem(itemID: itemID, body: body);
  }

  ///Put a deleted item back where it was
  ///@param itemID
  @POST(path: '/api/v1/trash/{itemID}/restore', optionalBody: true)
  Future<chopper.Response<Entry>> _restoreTrashItem({
    @Path('itemID') required int? itemID,
    @Body() required RestoreRequest? body,
    @chopper.Tag()
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
  });

  ///A user's icon
  ///@param userID
  ///@param imageID
  Future<chopper.Response<String>> getUserAvatar({required int? userID, required String? imageID}) {
    return _getUserAvatar(userID: userID, imageID: imageID);
  }

  ///A user's icon
  ///@param userID
  ///@param imageID
  @GET(path: '/api/v1/users/{userID}/avatar/{imageID}')
  Future<chopper.Response<String>> _getUserAvatar({
    @Path('userID') required int? userID,
    @Path('imageID') required String? imageID,
    @chopper.Tag()
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
  });

  ///How long earlier versions of files are kept
  Future<chopper.Response<VersionRetention>> getVersionSettings() {
    generatedMapping.putIfAbsent(VersionRetention, () => VersionRetention.fromJsonFactory);

    return _getVersionSettings();
  }

  ///How long earlier versions of files are kept
  @GET(path: '/api/v1/versions/settings')
  Future<chopper.Response<VersionRetention>> _getVersionSettings({
    @chopper.Tag()
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
  });

  ///Choose how long earlier versions of files are kept, within the server's limits
  Future<chopper.Response<VersionRetention>> setVersionSettings({required VersionPreferences? body}) {
    generatedMapping.putIfAbsent(VersionRetention, () => VersionRetention.fromJsonFactory);

    return _setVersionSettings(body: body);
  }

  ///Choose how long earlier versions of files are kept, within the server's limits
  @PUT(path: '/api/v1/versions/settings', optionalBody: true)
  Future<chopper.Response<VersionRetention>> _setVersionSettings({
    @Body() required VersionPreferences? body,
    @chopper.Tag()
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
