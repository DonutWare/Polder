// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutLegalese => 'Files, sync and auto-upload for your own server.';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentColor => 'Accent color';

  @override
  String get accentCustomHint => 'Status colors are tuned to match your accent.';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentNoSystemHint => 'This device has no accent color to follow, so the default is used.';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentRose => 'Rose';

  @override
  String get accentSlate => 'Slate';

  @override
  String get accentSystemHint => 'Follows your device\'s accent color.';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentViolet => 'Violet';

  @override
  String get account => 'Account';

  @override
  String get add => 'Add';

  @override
  String get addAutoUploadFolder => 'Add folder';

  @override
  String get addSyncFolder => 'Add sync folder';

  @override
  String get addUser => 'Add user';

  @override
  String get addUserHint => 'Create an account with its own storage';

  @override
  String adminAccountsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count administrators',
      one: '1 administrator',
    );
    return '$_temp0';
  }

  @override
  String get adminDisabledCaption => 'Can\'t sign in';

  @override
  String get administration => 'Administration';

  @override
  String get administrationHint => 'Users and server management';

  @override
  String get adminNearQuota => 'Near quota';

  @override
  String get adminNearQuotaCaption => 'Over 90% of their quota';

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminStorageCaption => 'Across all accounts';

  @override
  String get adminStorageUsed => 'Storage used';

  @override
  String get appearance => 'Appearance';

  @override
  String applyToAll(int count) {
    return 'Apply my choice to all $count conflicts';
  }

  @override
  String get appTitle => 'Nomad';

  @override
  String get autoUploadDescription => 'Upload new photos and files from the chosen folders automatically.';

  @override
  String get autoUploadEnabled => 'Auto-upload';

  @override
  String get backToFiles => 'Back to files';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get chargingOnly => 'Only while charging';

  @override
  String get choose => 'Choose';

  @override
  String get chooseServerFolder => 'Choose a server folder';

  @override
  String get chooseThisFolder => 'Choose this folder';

  @override
  String get clearFinished => 'Clear finished';

  @override
  String get collapseSidebar => 'Collapse sidebar';

  @override
  String get conflictBothCreated => 'A different file with this name was created on both sides.';

  @override
  String get conflictBothModified => 'Changed on this device and on the server.';

  @override
  String get conflictLocalDeletedRemoteModified => 'Deleted on this device but changed on the server.';

  @override
  String get conflictLocalModifiedRemoteDeleted => 'Changed on this device but deleted on the server.';

  @override
  String get conflicts => 'Conflicts';

  @override
  String conflictsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts need your decision',
      one: '1 conflict needs your decision',
    );
    return '$_temp0';
  }

  @override
  String get connect => 'Connect';

  @override
  String get create => 'Create';

  @override
  String get createAdmin => 'Create administrator';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String deletedCount(int count) {
    return '$count deleted';
  }

  @override
  String get deleteMessage => 'It will be moved to the trash on the server.';

  @override
  String deleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteUserMessage => 'The account is removed. Their files are kept on the server disk.';

  @override
  String deleteUserTitle(String username) {
    return 'Delete user \"$username\"?';
  }

  @override
  String dimensions(int width, int height) {
    return '$width × $height';
  }

  @override
  String get dimensionsLabel => 'Dimensions';

  @override
  String get disabled => 'Disabled';

  @override
  String get done => 'Done';

  @override
  String get download => 'Download';

  @override
  String downloadedCount(int count) {
    return '$count downloaded';
  }

  @override
  String get edit => 'Edit';

  @override
  String editUser(String username) {
    return 'Edit $username';
  }

  @override
  String get emptyFolder => 'This folder is empty';

  @override
  String get errorAlreadyExists => 'Something with that name already exists.';

  @override
  String get errorConflict => 'The item was changed by someone else. Refresh and try again.';

  @override
  String get errorForbidden => 'You are not allowed to do that.';

  @override
  String get errorInvalidRequest => 'The request was not valid.';

  @override
  String errorLocalFolderMissing(String path) {
    return 'The local folder $path is missing.';
  }

  @override
  String get errorNetwork => 'Could not reach the server.';

  @override
  String get errorNotFound => 'It no longer exists.';

  @override
  String get errorQuotaExceeded => 'Your storage quota is full.';

  @override
  String get errorUnauthorized => 'Your session has expired. Please sign in again.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get expandSidebar => 'Expand sidebar';

  @override
  String failedCount(int count) {
    return '$count failed';
  }

  @override
  String get folders => 'Folders';

  @override
  String get gridView => 'Grid view';

  @override
  String get keepBoth => 'Keep both';

  @override
  String get keepMine => 'Keep mine';

  @override
  String get keepServer => 'Keep server\'s';

  @override
  String lastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get listView => 'List view';

  @override
  String get localFolder => 'Folder on this device';

  @override
  String get loginErrorDisabled => 'This account is disabled.';

  @override
  String get loginErrorInvalidCredentials => 'Wrong username or password.';

  @override
  String get loginErrorSetupUnavailable => 'This server has already been set up.';

  @override
  String get loginErrorUnreachable => 'Could not reach a Nomad server at this address.';

  @override
  String get loginServerIntro => 'Enter the address of your Nomad server.';

  @override
  String get management => 'Management';

  @override
  String get manageUsersHint => 'Accounts, roles and quotas';

  @override
  String get modified => 'Modified';

  @override
  String get moreOptions => 'More options';

  @override
  String get move => 'Move';

  @override
  String get name => 'Name';

  @override
  String get navAutoUpload => 'Auto-upload';

  @override
  String get navFiles => 'Files';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSync => 'Sync';

  @override
  String get newFolder => 'New folder';

  @override
  String get newPasswordOptional => 'New password (leave empty to keep)';

  @override
  String get noConflicts => 'No conflicts. Everything is in sync.';

  @override
  String get noFolders => 'No folders yet.';

  @override
  String get notChosen => 'Not chosen';

  @override
  String get noUsers => 'No users yet.';

  @override
  String get password => 'Password';

  @override
  String get quota => 'Quota';

  @override
  String get quotaInvalid => 'Enter a number of 0 or more';

  @override
  String get quotaUnlimitedHint => '0 means unlimited';

  @override
  String quotaUsedOf(String used, String total) {
    return '$used of $total used';
  }

  @override
  String quotaUsedUnlimited(String used) {
    return '$used used';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get remove => 'Remove';

  @override
  String get removeSyncFolderMessage => 'The folder stops syncing. No files are deleted.';

  @override
  String get removeSyncFolderTitle => 'Remove this folder?';

  @override
  String get rename => 'Rename';

  @override
  String get resolve => 'Resolve';

  @override
  String get retry => 'Retry';

  @override
  String get revision => 'Revision';

  @override
  String revisionShort(int rev) {
    return 'Revision $rev';
  }

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUser => 'User';

  @override
  String get rootFolder => 'Files';

  @override
  String get save => 'Save';

  @override
  String get server => 'Server';

  @override
  String get serverFolder => 'Folder on the server';

  @override
  String get serverUrl => 'Server address';

  @override
  String get serverUrlHint => 'https://cloud.example.com';

  @override
  String get setupIntro => 'This server has no users yet. Create the first administrator account.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String signOutMessage(String username, String server) {
    return 'Sign out $username from $server?';
  }

  @override
  String get size => 'Size';

  @override
  String get storageByUser => 'Storage by user';

  @override
  String syncedWith(String remotePath) {
    return 'Synced with $remotePath';
  }

  @override
  String get syncError => 'Sync finished with errors';

  @override
  String get syncFolders => 'Sync folders';

  @override
  String get syncIdle => 'Up to date';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get syncUnsupported => 'Folder sync is not available on this platform.';

  @override
  String get systemAccentUnavailable => 'System (not available on this device)';

  @override
  String get takenAt => 'Taken';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get thisDevice => 'This device';

  @override
  String get transferDone => 'Done';

  @override
  String get transfers => 'Transfers';

  @override
  String get type => 'Type';

  @override
  String get unit => 'Unit';

  @override
  String uploadedCount(int count) {
    return '$count uploaded';
  }

  @override
  String get uploadFiles => 'Upload files';

  @override
  String get username => 'Username';

  @override
  String get users => 'Users';

  @override
  String usersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count users', one: '1 user');
    return '$_temp0';
  }

  @override
  String get wifiOnly => 'Only on Wi-Fi';
}
