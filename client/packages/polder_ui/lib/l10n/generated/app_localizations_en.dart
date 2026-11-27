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
  String get aboutCreatedBy => 'Created by DonutWare';

  @override
  String get aboutHint => 'Version, licenses and supporting the project';

  @override
  String get aboutLegalese => 'Create your own private polder and sync your files.';

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutSocials => 'Socials';

  @override
  String aboutVersion(String version) {
    return 'Application version $version';
  }

  @override
  String aboutServerInfo(String version, String buildNumber) {
    return 'Server version $version ($buildNumber)';
  }

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
  String get accentPolder => 'Polder';

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
  String get adminOverviewHint => 'Storage and usage at a glance';

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
  String get appTitle => 'Polder';

  @override
  String get autoUploadDescription => 'Upload new photos and files from the chosen folders automatically.';

  @override
  String get autoUploadEnabled => 'Auto-upload';

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
  String get deletePermanently => 'Delete permanently';

  @override
  String get deletePermanentlyMessage => 'It can\'t be restored afterwards.';

  @override
  String deletePermanentlyTitle(String name) {
    return 'Delete \"$name\" permanently?';
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
  String get edit => 'Edit';

  @override
  String editUser(String username) {
    return 'Edit $username';
  }

  @override
  String get emptyFolder => 'This folder is empty';

  @override
  String get emptyTrash => 'Empty trash';

  @override
  String get emptyTrashMessage => 'Everything in the trash is deleted permanently. This can\'t be undone.';

  @override
  String get emptyTrashTitle => 'Empty the trash?';

  @override
  String get errorAlreadyExists => 'Something with that name already exists.';

  @override
  String get errorConflict => 'It changed since it was last loaded. Refresh and try again.';

  @override
  String get errorForbidden => 'You are not allowed to do that.';

  @override
  String get errorReauthenticationRequired => 'For your security, sign out and sign in again, then try once more.';

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
  String get errorRateLimited => 'Too many attempts. Wait a moment and try again.';

  @override
  String get errorUnauthorized => 'Your session has expired. Please sign in again.';

  @override
  String get errorUnavailable => 'The server is busy. Try again shortly.';

  @override
  String get errorPreconditionFailed => 'It changed on the server while this was in progress.';

  @override
  String errorServer(String status) {
    return 'The server ran into an error (HTTP $status).';
  }

  @override
  String get errorUnknown => 'The app ran into an unexpected error.';

  @override
  String get expandSidebar => 'Expand sidebar';

  @override
  String get folders => 'Folders';

  @override
  String get generalSettings => 'General';

  @override
  String get generalSettingsHint => 'Trash and file versions';

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
  String get loginErrorUnreachable => 'Could not reach a Polder server at this address.';

  @override
  String get loginServerIntro => 'Enter the address of your Polder server.';

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
  String get navTrash => 'Trash';

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
  String get ocrLanguagesLabel => 'Tesseract models, comma-separated, like eng, jpn or script/Latin';

  @override
  String get ocrLanguagesSetting => 'Languages and scripts';

  @override
  String ocrMaxPagesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'OCR reads at most $count pages of each PDF',
      one: 'OCR reads at most 1 page of each PDF',
    );
    return '$_temp0';
  }

  @override
  String get ocrMaxPagesLabel => 'Pages';

  @override
  String get ocrMaxPagesSetting => 'Pages per PDF';

  @override
  String get ocrSetting => 'Recognise text in images and scans';

  @override
  String get ocrSettingHint => 'Reads photos and scanned PDF pages with OCR. This is slow and runs in the background.';

  @override
  String ocrUnavailable(String reason) {
    return 'OCR is unavailable: $reason';
  }

  @override
  String get overwrite => 'Overwrite';

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
  String get restore => 'Restore';

  @override
  String restoreConflictMessage(String path) {
    return 'There is already something at $path. Overwrite moves it to the trash, Keep both restores this item next to it under a new name.';
  }

  @override
  String restoreConflictTitle(String name) {
    return '\"$name\" already exists';
  }

  @override
  String restoredTo(String path) {
    return 'Restored to $path';
  }

  @override
  String get retry => 'Retry';

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
  String get searchAddFilterButton => 'Filter';

  @override
  String get searchChooseFolder => 'Choose folder';

  @override
  String get searchClear => 'Clear';

  @override
  String searchContentPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files still to read',
      one: '1 file still to read',
    );
    return '$_temp0';
  }

  @override
  String get searchContentSetting => 'Search inside files';

  @override
  String get searchContentSettingHint => 'Reads the text in documents, PDFs and images so search can find it.';

  @override
  String get searchCustomSize => 'Another size, like 250mb';

  @override
  String get searchCustomType => 'Another type or extension, like heic';

  @override
  String searchDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days ago', one: '1 day ago');
    return '$_temp0';
  }

  @override
  String get searchFieldFolder => 'Folder';

  @override
  String get searchFieldModified => 'Modified';

  @override
  String get searchFieldSize => 'Size';

  @override
  String get searchFieldType => 'Type';

  @override
  String searchEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count events', one: '1 event');
    return '$_temp0';
  }

  @override
  String get searchMoreEvents => 'Show more events';

  @override
  String get searchFieldCalendar => 'Calendar';

  @override
  String get searchFieldRepeats => 'Repeats';

  @override
  String get searchFieldWhen => 'When';

  @override
  String get searchRepeatYes => 'repeating';

  @override
  String get searchRepeatNo => 'one-off';

  @override
  String get searchRepeatDaily => 'daily';

  @override
  String get searchRepeatWeekly => 'weekly';

  @override
  String get searchRepeatMonthly => 'monthly';

  @override
  String get searchRepeatYearly => 'yearly';

  @override
  String get searchWhenUpcoming => 'upcoming';

  @override
  String get searchWhenPast => 'past';

  @override
  String get searchEventPast => 'Past';

  @override
  String get searchOpenInCalendar => 'Open in calendar';

  @override
  String searchFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '1 file');
    return '$_temp0';
  }

  @override
  String get searchFilterAdd => 'Add filter';

  @override
  String get searchFilterValues => 'Values';

  @override
  String get searchGoTo => 'Go to';

  @override
  String get searchHint => 'Search files, folders and pages';

  @override
  String get searchKeywordsAbout => 'version, licenses, info';

  @override
  String get searchKeywordsActivity => 'history, log, uploads, downloads, transfers, sessions, devices';

  @override
  String get searchKeywordsAdmin => 'admin, server, administration, retention, storage, ocr, text recognition, search';

  @override
  String get searchKeywordsAdminUsers => 'accounts, people, members, quota';

  @override
  String get searchKeywordsAutoUpload => 'camera, photos, backup, gallery';

  @override
  String get searchKeywordsConflicts => 'conflict, resolve, versions';

  @override
  String get searchKeywordsFiles => 'browse, documents, home, storage';

  @override
  String get searchKeywordsSettings => 'preferences, appearance, theme, account, language, password';

  @override
  String get searchKeywordsSync => 'folders, desktop, mirror';

  @override
  String get searchKeywordsTrash => 'deleted, recycle bin, restore, bin';

  @override
  String searchMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count months ago', one: '1 month ago');
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'Nothing matches your search';

  @override
  String get searchOpAfter => 'after';

  @override
  String get searchOpAtLeast => 'at least';

  @override
  String get searchOpAtMost => 'at most';

  @override
  String get searchOpBefore => 'before';

  @override
  String get searchOpBetween => 'between';

  @override
  String get searchOpFrom => 'from';

  @override
  String get searchOpIs => 'is';

  @override
  String get searchOpIsNot => 'is not';

  @override
  String get searchOpLarger => 'larger than';

  @override
  String get searchOpOn => 'on';

  @override
  String get searchOpSmaller => 'smaller than';

  @override
  String get searchOpUntil => 'until';

  @override
  String get searchPickDate => 'Pick a date';

  @override
  String get searchPickRange => 'Pick dates';

  @override
  String get searchPresetToday => 'today';

  @override
  String get searchPresetYesterday => 'yesterday';

  @override
  String searchRange(String from, String to) {
    return '$from and $to';
  }

  @override
  String get searchShowInFolder => 'Show in folder';

  @override
  String get searchSizeFrom => 'From';

  @override
  String get searchSizeTo => 'To';

  @override
  String get searchSyncConflicts => 'Sync conflicts';

  @override
  String get searchTipsBody =>
      'Type part of a name, even with typos. Add tags like type=pdf, modified>7d or size>100mb, use != to leave things out, or pick one with Filter. type=event searches your calendar, with repeats=no or when=upcoming to narrow it.';

  @override
  String get searchTipsTitle => 'Narrow it down';

  @override
  String searchTooltip(String shortcut) {
    return 'Search ($shortcut)';
  }

  @override
  String searchWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count weeks ago', one: '1 week ago');
    return '$_temp0';
  }

  @override
  String searchYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count years ago', one: '1 year ago');
    return '$_temp0';
  }

  @override
  String get server => 'Server';

  @override
  String get serverFolder => 'Folder on the server';

  @override
  String get serverSearchGroup => 'Search';

  @override
  String get serverSettings => 'Server settings';

  @override
  String get serverSettingsHint => 'Trash, versions, search, previews and federation';

  @override
  String get serverTrashRetention => 'Trash retention';

  @override
  String serverTrashRetentionHint(String duration) {
    return 'Default and upper limit for every user: $duration';
  }

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
  String get sponsor => 'Sponsor';

  @override
  String get sponsorMessage =>
      'If you enjoy using Polder, consider sponsoring the project to support ongoing development and improvements. Thank you for your support!';

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
  String get trashEmpty => 'The trash is empty';

  @override
  String trashItemDeleted(String date) {
    return 'Deleted $date';
  }

  @override
  String trashItemExpires(String date) {
    return 'Deleted permanently on $date';
  }

  @override
  String trashItemFrom(String folder) {
    return 'From $folder';
  }

  @override
  String get trashRetention => 'Keep deleted items';

  @override
  String trashRetentionDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days', one: '1 day');
    return '$_temp0';
  }

  @override
  String get trashRetentionForever => 'Forever';

  @override
  String get trashRetentionForeverHint => 'Items stay in the trash until you delete them.';

  @override
  String trashRetentionHint(String duration) {
    return 'Items in the trash are deleted permanently after $duration.';
  }

  @override
  String trashRetentionServerDefault(String duration) {
    return 'Server default ($duration)';
  }

  @override
  String trashSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0 · $size';
  }

  @override
  String get type => 'Type';

  @override
  String get unit => 'Unit';

  @override
  String get uploadFiles => 'Upload files';

  @override
  String get uploadHere => 'Upload here';

  @override
  String uploadSharedFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upload $count shared files',
      one: 'Upload shared file',
    );
    return '$_temp0';
  }

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

  @override
  String get navActivity => 'Activity';

  @override
  String get activityNow => 'Now';

  @override
  String get activityHistory => 'History';

  @override
  String get activityEmpty => 'Nothing has happened yet.';

  @override
  String get nothingTransferring => 'Nothing is transferring right now.';

  @override
  String get activityScopeMe => 'Only me';

  @override
  String get activityScopeAll => 'All users';

  @override
  String get activityScopeChooseUser => 'Choose a user…';

  @override
  String get activityScopeTooltip => 'Whose activity to show';

  @override
  String get chooseUserTitle => 'Show activity of';

  @override
  String get activityAllFiles => 'All files';

  @override
  String get activityKindUpload => 'Uploaded';

  @override
  String get activityKindDownload => 'Downloaded';

  @override
  String get activityKindMkdir => 'Created folder';

  @override
  String get activityKindMove => 'Moved';

  @override
  String get activityKindDelete => 'Moved to trash';

  @override
  String get activityKindRestore => 'Restored from trash';

  @override
  String get activityKindTrashDelete => 'Deleted permanently';

  @override
  String get activityKindTrashEmpty => 'Emptied the trash';

  @override
  String get activityKindTrashExpire => 'Old items removed from trash';

  @override
  String get activityKindLogin => 'Signed in';

  @override
  String get activityKindLogout => 'Signed out';

  @override
  String get activityKindUnknown => 'Something happened';

  @override
  String get activityRescanAdded => 'Added on the server';

  @override
  String get activityRescanChanged => 'Changed on the server';

  @override
  String get activityRescanRemoved => 'Removed on the server';

  @override
  String activityRescanSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count changes', one: '1 change');
    return '$_temp0 found on the server';
  }

  @override
  String activityMovedFrom(String path) {
    return 'from $path';
  }

  @override
  String activityItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0';
  }

  @override
  String get activityFailed => 'Failed';

  @override
  String get activityCancelled => 'Cancelled';

  @override
  String durationSeconds(int count) {
    return '$count s';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get transferUploading => 'Uploading';

  @override
  String get transferDownloading => 'Downloading';

  @override
  String transferProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String get folderUploading => 'Uploading…';

  @override
  String get folderDownloading => 'Downloading…';

  @override
  String get realtimeOffline => 'Live updates paused, reconnecting…';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get syncWaiting => 'Waiting to sync';

  @override
  String get syncPreparing => 'Preparing to sync';

  @override
  String get syncPaused => 'Sync paused';

  @override
  String get pauseSync => 'Pause sync';

  @override
  String get resumeSync => 'Resume sync';

  @override
  String get itemPaused => 'Paused';

  @override
  String nowGroupFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '1 file');
    return '$_temp0';
  }

  @override
  String nowGroupProgress(int done, int total) {
    return '$done of $total files';
  }

  @override
  String nowGroupUploading(int count) {
    return '$count uploading';
  }

  @override
  String nowGroupDownloading(int count) {
    return '$count downloading';
  }

  @override
  String nowGroupPreparing(int count) {
    return '$count preparing';
  }

  @override
  String nowGroupWaiting(int count) {
    return '$count waiting';
  }

  @override
  String get showFiles => 'Show files';

  @override
  String get hideFiles => 'Hide files';

  @override
  String get uploadExistingFiles => 'Upload existing files';

  @override
  String get uploadExistingFilesHint => 'Otherwise only files added from now on are uploaded';

  @override
  String get storageAccessDenied =>
      'Polder needs access to your files to upload this folder. Allow all files access, or at least photos and videos, in the app settings.';

  @override
  String get folderWillBeCreated => 'This folder doesn\'t exist yet. It will be created.';

  @override
  String get trayUpToDate => 'Up to date';

  @override
  String get traySyncing => 'Syncing…';

  @override
  String traySyncingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Syncing $count files',
      one: 'Syncing 1 file',
    );
    return '$_temp0';
  }

  @override
  String get traySyncPaused => 'Sync paused';

  @override
  String get traySyncFailed => 'Sync failed';

  @override
  String get traySignedOut => 'Not signed in';

  @override
  String get trayOpenApp => 'Open Polder';

  @override
  String get trayOpenSyncedFolders => 'Open synced folders';

  @override
  String get trayOpenFiles => 'Open files';

  @override
  String get trayOpenCalendar => 'Open calendar';

  @override
  String get trayOpenNotes => 'Open notes';

  @override
  String get trayQuit => 'Quit Polder';

  @override
  String get trayNew => 'New';

  @override
  String get shortcutNewNote => 'New note';

  @override
  String get shortcutEvent => 'Event';

  @override
  String get shortcutChecklist => 'Checklist';

  @override
  String get shortcutSearch => 'Search';

  @override
  String get quit => 'Quit';

  @override
  String get quitWhileSyncingTitle => 'Quit while syncing?';

  @override
  String get quitWhileSyncingMessage =>
      'Polder is still syncing. Unfinished transfers continue the next time you open Polder.';

  @override
  String get newDocument => 'New document';

  @override
  String get reviewScan => 'Review scan';

  @override
  String get addPages => 'Add pages';

  @override
  String get removePage => 'Remove page';

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get scanFormatPdf => 'PDF';

  @override
  String get scanFormatImages => 'Images';

  @override
  String get scanSaveTo => 'Save to';

  @override
  String get discard => 'Discard';

  @override
  String get discardScanTitle => 'Discard this scan?';

  @override
  String get discardScanMessage => 'The scanned pages won\'t be saved.';

  @override
  String get scanFailed => 'Couldn\'t scan the document.';

  @override
  String get scanCameraDenied => 'Allow camera access to scan documents.';

  @override
  String get scanCameraOpenSettings => 'Open settings';

  @override
  String get pages => 'Pages';

  @override
  String get details => 'Details';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortFoldersFirst => 'Folders on top';

  @override
  String get indexingBanner => 'Indexing… folders fill in as files are found.';

  @override
  String get indexingEmptyFolder => 'Still indexing. Files appear here as they\'re found.';

  @override
  String get serverLogs => 'Server logs';

  @override
  String get serverLogsHint => 'What the server did and every error it ran into';

  @override
  String get logLevelDebug => 'Debug';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelWarn => 'Warnings';

  @override
  String get logLevelError => 'Errors';

  @override
  String get logMinimumLevel => 'Minimum level';

  @override
  String get logComponent => 'Component';

  @override
  String get logAllComponents => 'All components';

  @override
  String get logSearchHint => 'Search messages and details';

  @override
  String get logFollow => 'Follow new entries';

  @override
  String get logStopFollowing => 'Stop following';

  @override
  String get logDownload => 'Download log file';

  @override
  String get logNoFiles => 'No log files yet.';

  @override
  String get logsEmpty => 'No log entries match.';

  @override
  String get editorOpen => 'Open in editor';

  @override
  String get editorSaved => 'All changes saved';

  @override
  String get editorSaving => 'Saving…';

  @override
  String get editorUnsaved => 'Unsaved changes';

  @override
  String get editorReadOnly => 'Read only';

  @override
  String get editorSaveFailedTitle => 'Changes not saved';

  @override
  String get editorSaveFailedMessage => 'Your changes could not be saved to the server. Leave anyway and lose them?';

  @override
  String get editorLeave => 'Leave anyway';

  @override
  String get scanDocument => 'Scan document';

  @override
  String get documentKind => 'Document';

  @override
  String get spreadsheetKind => 'Spreadsheet';

  @override
  String get presentationKind => 'Presentation';

  @override
  String get newSpreadsheet => 'New spreadsheet';

  @override
  String get newPresentation => 'New presentation';

  @override
  String get pdfKind => 'PDF';

  @override
  String get newPdf => 'New PDF';

  @override
  String get brandingGroup => 'Branding';

  @override
  String get serverName => 'Server name';

  @override
  String get serverNameHint => 'Shown on the login screen, in the sidebar and as the window title';

  @override
  String brandingDefault(String value) {
    return '$value (default)';
  }

  @override
  String get welcomeMessage => 'Welcome message';

  @override
  String get welcomeMessageNone => 'Not shown';

  @override
  String get brandingAccent => 'Default accent color';

  @override
  String get brandingAccentHint => 'Used unless someone picks their own accent color';

  @override
  String get appDefault => 'App default';

  @override
  String get hexColorLabel => 'Color as #RRGGBB';

  @override
  String get serverIcon => 'Icon';

  @override
  String get serverIconHint => 'Shown on the login screen and in the sidebar';

  @override
  String get loginBackgrounds => 'Login backgrounds';

  @override
  String loginBackgroundsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images, shown in turn',
      one: '1 image',
      zero: 'None; images you add are shown in turn behind the login screen',
    );
    return '$_temp0';
  }

  @override
  String get brandingHint => 'Name, colors, icon and login screen';

  @override
  String get brandingIdentityGroup => 'Name and colors';

  @override
  String get brandingImagesGroup => 'Images';

  @override
  String get imageFromDevice => 'From this device';

  @override
  String get imageFromFiles => 'From your files';

  @override
  String get chooseImage => 'Choose an image';

  @override
  String get chooseImages => 'Choose images';

  @override
  String get noImagesInFolder => 'No images or folders here';

  @override
  String addSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Add $count', zero: 'Add');
    return '$_temp0';
  }

  @override
  String get versionHistory => 'Version history';

  @override
  String get versions => 'Versions';

  @override
  String versionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count earlier versions',
      one: '1 earlier version',
      zero: 'None yet',
    );
    return '$_temp0';
  }

  @override
  String get versionCurrent => 'Current version';

  @override
  String get versionHistoryEmpty =>
      'No earlier versions yet. When this file is saved over, the previous content is kept here.';

  @override
  String get versionHistoryOff => 'Version history is turned off, so earlier versions aren\'t kept.';

  @override
  String get versionView => 'View';

  @override
  String get versionRestore => 'Restore';

  @override
  String get versionRestoreTitle => 'Restore this version?';

  @override
  String get versionRestoreMessage => 'The current content is kept as a version, so you can go back to it.';

  @override
  String get versionRestored => 'Version restored';

  @override
  String get versionDeleteTitle => 'Delete this version?';

  @override
  String get versionDeleteMessage => 'This version is deleted permanently.';

  @override
  String versionViewing(String date) {
    return 'Version from $date, read only';
  }

  @override
  String get versionBackToCurrent => 'Back to current';

  @override
  String get versionsKeep => 'Keep earlier versions';

  @override
  String get versionsKeepHint =>
      'When a file is saved over, its previous content is kept. Versions count towards your storage.';

  @override
  String versionsPerFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count per file',
      one: '1 per file',
      zero: 'No limit per file',
    );
    return '$_temp0';
  }

  @override
  String get versionsMaxPerFile => 'Versions per file';

  @override
  String versionsMaxPerFileHint(String limit) {
    return 'The server allows at most $limit.';
  }

  @override
  String get versionsMaxAge => 'Keep versions for';

  @override
  String get versionsFollowServer => 'Follow the server';

  @override
  String get versionsTurnOffTitle => 'Turn off version history?';

  @override
  String get versionsTurnOffMessage => 'All earlier versions of your files are deleted permanently.';

  @override
  String get turnOff => 'Turn off';

  @override
  String get versionsTurnedOffByAdmin => 'Turned off by your administrator';

  @override
  String versionsKeepAllHint(String limit) {
    return 'The server allows at most $limit.';
  }

  @override
  String get trashKeep => 'Move deleted items to the trash';

  @override
  String get trashKeepHint => 'Deleted items can be restored until the trash is emptied. Off deletes them permanently.';

  @override
  String get trashTurnedOffByAdmin => 'Turned off by your administrator. Deleted items are removed permanently.';

  @override
  String get trashTurnOffTitle => 'Turn off the trash?';

  @override
  String get trashTurnOffMessage =>
      'Everything in your trash is deleted permanently, and from now on deleting can\'t be undone.';

  @override
  String get serverTrashEnabledHint => 'Turning this off empties every user\'s trash and makes deleting permanent.';

  @override
  String get serverTrashTurnOffMessage =>
      'Every user\'s trash is emptied permanently, and from now on deleting can\'t be undone.';

  @override
  String get serverVersionsEnabled => 'Keep earlier versions';

  @override
  String get serverVersionsEnabledHint =>
      'Only changes made through Polder are kept. Turning this off deletes all history.';

  @override
  String get serverVersionsTurnOffMessage =>
      'Earlier versions of every user\'s files are deleted permanently, and no new ones are kept.';

  @override
  String get versionsKeepAll => 'Keep every save for';

  @override
  String get serverVersionsKeepAllHint =>
      'After this, versions thin out: about one per hour after a day, fewer as they age.';

  @override
  String versionsHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
      zero: 'Don\'t keep every save',
    );
    return '$_temp0';
  }

  @override
  String get versionsHoursLabel => 'Hours';

  @override
  String get serverVersionsMaxAge => 'Keep versions for';

  @override
  String get serverVersionsMaxPerFile => 'Versions per file';

  @override
  String get serverVersionsLimitHint => 'Default and upper limit for every user';

  @override
  String quotaHistory(String size) {
    return '$size of that is version history';
  }

  @override
  String get navNotes => 'Notes';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get searchKeywordsCalendar => 'calendar, agenda, events, appointments, schedule, meetings';

  @override
  String get searchKeywordsNotes => 'notes, markdown, wiki, knowledge base, pages, journal';

  @override
  String get notesSetupTitle => 'Set up notes';

  @override
  String get notesSetupMessage =>
      'Notes are markdown files in a folder of your choice. Pick a name for the folder; it\'s created if it doesn\'t exist yet.';

  @override
  String get notesFolder => 'Notes folder';

  @override
  String get notesDefaultFolder => 'Notes';

  @override
  String get notesSetUp => 'Set up';

  @override
  String get notesFolderIsFile => 'That\'s a file, not a folder.';

  @override
  String get notesFolderExistsTitle => 'Folder already exists';

  @override
  String notesFolderExistsMessage(String path) {
    return '$path already exists. Use it as your notes folder? The markdown files in it become pages.';
  }

  @override
  String get notesUseExistingFolder => 'Use this folder';

  @override
  String get notesChooseAnotherName => 'Choose another name';

  @override
  String get notesChangeFolder => 'Change notes folder';

  @override
  String get notesEmptyFolder => 'No pages yet.';

  @override
  String get notesMoveToTop => 'Drop here to move to the top level';

  @override
  String get notesNothingOpenMessage => 'Pick a page on the left, or start a new one.';

  @override
  String get noteNewPage => 'New page';

  @override
  String get noteNewSubpage => 'New subpage';

  @override
  String get noteNewChecklist => 'New checklist';

  @override
  String get noteListItem => 'List item';

  @override
  String get noteRemoveItem => 'Remove item';

  @override
  String noteCheckedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count checked items',
      one: '1 checked item',
    );
    return '$_temp0';
  }

  @override
  String get noteShowCheckboxes => 'Show checkboxes';

  @override
  String get noteHideCheckboxes => 'Hide checkboxes';

  @override
  String get noteSubpages => 'Subpages';

  @override
  String get noteCollapse => 'Collapse';

  @override
  String get noteExpand => 'Expand';

  @override
  String get notesUpOneLevel => 'Up one level';

  @override
  String get noteNewNote => 'Note';

  @override
  String get noteDefaultName => 'Note';

  @override
  String get noteMove => 'Move';

  @override
  String get noteShowInFiles => 'Show in files';

  @override
  String noteDeleteTitle(String title) {
    return 'Delete $title?';
  }

  @override
  String get noteDeleteMessage => 'The page goes to the trash.';

  @override
  String get noteDeleteWithChildrenMessage => 'The page and its subpages go to the trash.';

  @override
  String noteDeleteManyTitle(int count) {
    return 'Delete $count pages?';
  }

  @override
  String get noteDeleteManyMessage => 'The pages and any subpages go to the trash.';

  @override
  String get noteSelect => 'Select';

  @override
  String get noteUnsaved => 'Unsaved changes; save now';

  @override
  String get noteSaving => 'Saving';

  @override
  String get noteLivePreview => 'Live preview';

  @override
  String get noteSourceMode => 'Source mode';

  @override
  String get noteLinks => 'Links';

  @override
  String get noteBack => 'Back';

  @override
  String get noteForward => 'Forward';

  @override
  String get noteLinkedFrom => 'Linked from';

  @override
  String get noteLinksTo => 'Links to';

  @override
  String get noteNoBacklinks => 'Nothing links here yet.';

  @override
  String get noteNoLinks => 'This note doesn\'t link to anything.';

  @override
  String noteBrokenLink(String path) {
    return 'Not found: $path';
  }

  @override
  String get noteLinkMissing => 'The linked file no longer exists.';

  @override
  String get noteLinkSearch => 'Search';

  @override
  String get noteLinkBrowse => 'Browse';

  @override
  String get noteLinkThisFolder => 'Link to this folder';

  @override
  String get noteNotText => 'This file isn\'t plain UTF-8 text, so it can\'t be edited here.';

  @override
  String noteDraftFound(String time) {
    return 'Unsaved changes from $time were found on this device.';
  }

  @override
  String noteDraftFoundChanged(String time) {
    return 'Unsaved changes from $time were found, but the note has changed since.';
  }

  @override
  String get noteRecoverDraft => 'Recover';

  @override
  String get noteDiscardDraft => 'Discard';

  @override
  String get noteConflict => 'This note was changed somewhere else.';

  @override
  String get noteConflictTheirs => 'Use theirs';

  @override
  String get noteConflictMine => 'Keep mine';

  @override
  String get noteConflictCopy => 'Save mine as copy';

  @override
  String get copySuffix => 'copy';

  @override
  String get noteUndo => 'Undo';

  @override
  String get noteRedo => 'Redo';

  @override
  String get noteHeading => 'Heading';

  @override
  String noteHeadingLevel(int level) {
    return 'Heading $level';
  }

  @override
  String get noteParagraph => 'Normal text';

  @override
  String get noteBold => 'Bold';

  @override
  String get noteItalic => 'Italic';

  @override
  String get noteStrikethrough => 'Strikethrough';

  @override
  String get noteInlineCode => 'Code';

  @override
  String get noteBulletList => 'Bulleted list';

  @override
  String get noteNumberedList => 'Numbered list';

  @override
  String get noteTaskList => 'Task list';

  @override
  String get noteQuote => 'Quote';

  @override
  String get noteCallout => 'Callout';

  @override
  String get noteCodeBlock => 'Code block';

  @override
  String get noteTable => 'Table';

  @override
  String get noteDivider => 'Divider';

  @override
  String get noteLinkFile => 'Link a file or note';

  @override
  String get noteAttachFiles => 'Attach files';

  @override
  String get profile => 'Profile';

  @override
  String get accountSettingsHint => 'Your name, picture and appearance';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'Shown instead of your first name';

  @override
  String get email => 'Email';

  @override
  String get age => 'Age';

  @override
  String get address => 'Address';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get userIcon => 'Picture';

  @override
  String get userIconHint => 'Without a picture, your initials are shown';

  @override
  String get open => 'Open';

  @override
  String deleteItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items?',
      one: 'Delete 1 item?',
    );
    return '$_temp0';
  }

  @override
  String deletePermanentlyItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items permanently?',
      one: 'Delete 1 item permanently?',
    );
    return '$_temp0';
  }

  @override
  String get copy => 'Copy';

  @override
  String moveEntryTitle(String name) {
    return 'Move \"$name\" to…';
  }

  @override
  String moveItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count items to…',
      one: 'Move 1 item to…',
    );
    return '$_temp0';
  }

  @override
  String get moveHere => 'Move here';

  @override
  String copyEntryTitle(String name) {
    return 'Copy \"$name\" to…';
  }

  @override
  String copyItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copy $count items to…',
      one: 'Copy 1 item to…',
    );
    return '$_temp0';
  }

  @override
  String get copyHere => 'Copy here';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get passwordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordHint => 'Your other devices are signed out after the change.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get usernameRequirements =>
      '2–32 characters: lowercase letters, digits, \'.\', \'_\' or \'-\', starting with a letter or digit';

  @override
  String passwordRequirements(int count) {
    return 'At least $count characters';
  }

  @override
  String get navShared => 'Shared';

  @override
  String get searchKeywordsShared => 'shared share links people groups';

  @override
  String get sharedWithMe => 'Shared with me';

  @override
  String get sharedByMe => 'Shared by me';

  @override
  String get shareLinks => 'Links';

  @override
  String get noIncomingShares => 'Nothing has been shared with you yet';

  @override
  String get noOutgoingShares => 'You haven\'t shared anything yet';

  @override
  String get noShareLinks => 'You haven\'t created any links yet';

  @override
  String get share => 'Share';

  @override
  String shareTitle(String name) {
    return 'Share $name';
  }

  @override
  String get shareRecipients => 'Shared with';

  @override
  String get shareSearchHint => 'Add people or groups';

  @override
  String get shareNoMatches => 'No people or groups found';

  @override
  String get sharePermissionRead => 'Can view';

  @override
  String get sharePermissionWrite => 'Can edit';

  @override
  String get shareNotSharedYet => 'Not shared with anyone yet';

  @override
  String sharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String get shareUnavailable => 'In the trash';

  @override
  String get shareLeave => 'Remove from my shared items';

  @override
  String get shareDetailsOwner => 'Shared by';

  @override
  String shareDetailsGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Groups', one: 'Group');
    return '$_temp0';
  }

  @override
  String get shareDetailsAccess => 'Access';

  @override
  String get shareDetailsNote => 'Note';

  @override
  String get shareStop => 'Stop sharing';

  @override
  String shareGroupMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count members', one: '1 member');
    return '$_temp0';
  }

  @override
  String get createLink => 'Create link';

  @override
  String get editLink => 'Edit link';

  @override
  String get linkAccess => 'Anyone with the link can';

  @override
  String get linkCanView => 'View';

  @override
  String get linkCanViewHint => 'Browse the files and see previews';

  @override
  String get linkCanDownload => 'Download';

  @override
  String get linkCanDownloadHint => 'Save files and folders to their device';

  @override
  String get linkCanUpload => 'Upload';

  @override
  String get linkCanUploadHint => 'Add files to this folder; existing files are never replaced';

  @override
  String get linkPassword => 'Password';

  @override
  String get linkPasswordHint => 'Leave empty for no password';

  @override
  String get linkPasswordKeep => 'Leave empty to keep the current password';

  @override
  String get linkPasswordSet => 'Password protected';

  @override
  String get linkRemovePassword => 'Remove password';

  @override
  String get linkExpiry => 'Expiry date';

  @override
  String get linkNoExpiry => 'Never expires';

  @override
  String linkExpiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get linkExpired => 'Expired';

  @override
  String get linkCopy => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get deleteLinkTitle => 'Delete link?';

  @override
  String get deleteLinkMessage => 'The link stops working right away for everyone who has it.';

  @override
  String get publicShareLocked => 'This link is password protected';

  @override
  String get publicShareUnlock => 'Open';

  @override
  String get publicShareWrongPassword => 'Wrong password';

  @override
  String get publicShareRateLimited => 'Too many attempts. Try again in a minute.';

  @override
  String get publicShareNotFound => 'This link doesn\'t exist or has expired';

  @override
  String publicShareUploadOnly(String name) {
    return 'Files you upload here go to $name. You can\'t see what\'s already there.';
  }

  @override
  String get downloadAll => 'Download all';

  @override
  String get openInApp => 'Open in app';

  @override
  String get openInPolder => 'Open in Polder';

  @override
  String get groups => 'Groups';

  @override
  String get groupName => 'Group name';

  @override
  String get renameGroup => 'Rename group';

  @override
  String get deleteGroupTitle => 'Delete group?';

  @override
  String deleteGroupMessage(String name) {
    return '$name is deleted and anything shared with it is no longer shared.';
  }

  @override
  String get groupMembers => 'Members';

  @override
  String get noGroups => 'No groups yet';

  @override
  String get filterUsers => 'Filter users';

  @override
  String get newGroup => 'New group';

  @override
  String get myGroups => 'My groups';

  @override
  String get allGroups => 'All groups';

  @override
  String get groupRoleAdmin => 'Admin';

  @override
  String get groupRoleMember => 'Member';

  @override
  String get groupRoleViewer => 'Viewer';

  @override
  String get groupRoleAdminHint => 'Manages members and can remove anything shared with the group';

  @override
  String get groupRoleMemberHint => 'Can share with the group';

  @override
  String get groupRoleViewerHint => 'Can only view what is shared with the group';

  @override
  String get addMember => 'Add member';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String leaveGroupTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get leaveGroupMessage =>
      'You will no longer see what is shared with this group, and what you shared with it is no longer shared.';

  @override
  String leaveGroupAloneMessage(String name) {
    return 'You are the only member of $name. Leaving deletes the group, and anything shared with it is no longer shared.';
  }

  @override
  String get leaveAndDeleteGroup => 'Leave and delete';

  @override
  String leaveGroupLastAdminMessage(String name) {
    return 'You are the last admin of $name. Make someone else an admin before you leave, or delete the group.';
  }

  @override
  String get removeMember => 'Remove from group';

  @override
  String get groupShared => 'Shared with this group';

  @override
  String get noGroupShares => 'Nothing is shared with this group yet';

  @override
  String get selectGroup => 'Select a group or create one';

  @override
  String get searchKeywordsGroups => 'groups teams members roles';

  @override
  String groupCreatedBy(String name) {
    return 'Created by $name';
  }

  @override
  String get sharePermissionCustom => 'Custom permissions';

  @override
  String get sharePermView => 'View';

  @override
  String get sharePermCreate => 'Create';

  @override
  String get sharePermEdit => 'Edit';

  @override
  String get sharePermDelete => 'Delete';

  @override
  String get shareNote => 'Note to recipient';

  @override
  String get shareNoteHint => 'Shown to them together with the share';

  @override
  String get nothingSelected => 'Choose something on the left';

  @override
  String sharedByWithPermission(String name, String permission) {
    return 'Shared by $name · $permission';
  }

  @override
  String shareWithName(String name) {
    return 'Share with $name';
  }

  @override
  String sharedWithName(String name) {
    return 'Shared with $name';
  }

  @override
  String get finderLocationDisabled =>
      'Turn on Polder in System Settings › General › Login Items & Extensions › File Providers to see your files in Finder.';

  @override
  String get openSystemSettings => 'Open System Settings';

  @override
  String get startup => 'Startup';

  @override
  String get launchAtLogin => 'Open at login';

  @override
  String get launchAtLoginHint => 'Start Polder automatically when you sign in to your computer';

  @override
  String get launchMinimized => 'Start minimized';

  @override
  String get launchMinimizedHint => 'Run in the background at login without opening the window';

  @override
  String get showInFinder => 'Show in Finder';

  @override
  String get showInFinderHint => 'Browse your files in Finder; they download when you open them';

  @override
  String get finderRemoveTitle => 'Remove from Finder?';

  @override
  String get finderRemoveMessage =>
      'Files downloaded for offline use are removed from this Mac. They stay on the server.';

  @override
  String get showInFilesApp => 'Show in Files';

  @override
  String get showInFilesAppHint => 'Open and save Polder files from other apps through the Files app';

  @override
  String get filesAppRemoveTitle => 'Remove from Files?';

  @override
  String get filesAppRemoveMessage =>
      'Other apps can no longer open or save files in Polder. Your files stay on the server.';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get appPasswords => 'App passwords';

  @override
  String get appPasswordsHint =>
      'WebDAV and CalDAV apps such as Finder, Explorer, rclone and Apple Calendar log in with your username and an app password. Your account password does not work there.';

  @override
  String get createAppPassword => 'Create app password';

  @override
  String get appPasswordNameHint => 'For example: Finder on my laptop';

  @override
  String get appPasswordReadOnly => 'Read-only';

  @override
  String get appPasswordReadOnlyHint => 'Apps using it can only read files';

  @override
  String get appPasswordConfirmHint => 'Enter your account password to confirm it is you';

  @override
  String get appPasswordCreatedTitle => 'App password created';

  @override
  String get appPasswordCreatedMessage => 'Copy this password now. It will not be shown again.';

  @override
  String get appPasswordCopied => 'App password copied';

  @override
  String get appPasswordNeverUsed => 'Never used';

  @override
  String appPasswordLastUsed(String date, String address) {
    return 'Last used $date from $address';
  }

  @override
  String get noAppPasswords => 'No app passwords yet';

  @override
  String get revokeAppPassword => 'Revoke';

  @override
  String revokeAppPasswordTitle(String name) {
    return 'Revoke $name?';
  }

  @override
  String get revokeAppPasswordMessage => 'Apps using this password stop working at once.';

  @override
  String get webdavAddress => 'WebDAV address';

  @override
  String get webdavAddressCopied => 'WebDAV address copied';

  @override
  String get caldavAddress => 'CalDAV address';

  @override
  String get caldavAddressCopied => 'CalDAV address copied';

  @override
  String get calendars => 'Calendars';

  @override
  String get calendarsHint =>
      'Apps such as Apple Calendar, Thunderbird and DAVx⁵ sync a calendar over CalDAV with your username and an app password. Apps such as Google Calendar and Outlook can instead subscribe to a secret link, which they refresh every few hours.';

  @override
  String get noCalendars => 'No calendars yet';

  @override
  String get calendarAddressCopied => 'Calendar address copied';

  @override
  String calendarSharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String get calendarSubscribedFeed => 'Subscribed feed';

  @override
  String get subscriptionLinks => 'Subscription links';

  @override
  String get noSubscriptionLinks => 'No subscription links yet';

  @override
  String get createSubscriptionLink => 'Create subscription link';

  @override
  String get subscriptionLinkModeFull => 'All details';

  @override
  String get subscriptionLinkModeFullHint => 'Titles, places, notes and attendees';

  @override
  String get subscriptionLinkModeBusy => 'Only busy times';

  @override
  String get subscriptionLinkModeBusyHint => 'Shows when you are busy and nothing else';

  @override
  String get subscriptionLinkNameHint => 'For example: Outlook at work';

  @override
  String get subscriptionLinkCreatedTitle => 'Subscription link created';

  @override
  String get subscriptionLinkCreatedMessage =>
      'Copy the link now. It will not be shown again, and anyone who has it can see this calendar.';

  @override
  String get subscriptionLinkWebcal => 'Link for calendar apps (webcal)';

  @override
  String get subscriptionLinkCopied => 'Subscription link copied';

  @override
  String subscriptionLinkLastUsed(String date) {
    return 'Last used $date';
  }

  @override
  String get revokeSubscriptionLink => 'Revoke';

  @override
  String get revokeSubscriptionLinkTitle => 'Revoke this subscription link?';

  @override
  String get revokeSubscriptionLinkMessage => 'Apps subscribed with it stop getting updates at once.';

  @override
  String get federation => 'Federation';

  @override
  String get federationEnabled => 'Share with other servers';

  @override
  String get federationEnabledHint => 'People can share with users on trusted servers that support Open Cloud Mesh';

  @override
  String get federationNeedsPublicUrl => 'Set publicUrl in the server config to turn this on';

  @override
  String get trustServer => 'Trust server';

  @override
  String get trustServerHint =>
      'Shares are only exchanged with servers you trust. The server\'s signing key is pinned when you add it.';

  @override
  String get serverAddress => 'Server address';

  @override
  String get allowPrivateNetwork => 'Allow private network';

  @override
  String get allowPrivateNetworkHint => 'Only for a server on your own network, such as at home';

  @override
  String get noTrustedServers => 'No trusted servers yet';

  @override
  String get noTrustedServersHint => 'Add a server to share with its users';

  @override
  String serverKey(String fingerprint) {
    return 'Key $fingerprint';
  }

  @override
  String get rediscoverServer => 'Fetch key again';

  @override
  String rediscoverServerTitle(String name) {
    return 'Fetch the key of $name again?';
  }

  @override
  String get rediscoverServerMessage =>
      'Only do this when the server\'s administrator tells you its key changed. The new key is trusted from now on.';

  @override
  String removeTrustedServerTitle(String name) {
    return 'Stop trusting $name?';
  }

  @override
  String get removeTrustedServerMessage => 'Every share with this server ends.';

  @override
  String get federatedRecipients => 'On other servers';

  @override
  String get federatedNotSharedYet =>
      'Type a cloud ID, such as alice@cloud.example.com, to share with someone on another server';

  @override
  String get federatedShareHint => 'They get a request on their own server and can open the item once they accept.';

  @override
  String get federatedSharePending => 'Waiting for them to accept.';

  @override
  String get federatedSharePendingShort => 'Pending';

  @override
  String get federatedShareAccepted => 'They accepted this share.';

  @override
  String get shareSearchFederatedHint => 'Name, group or cloud ID';

  @override
  String get shareWithFederated => 'Share with someone on another server';

  @override
  String get sharedFromOtherServers => 'From other servers';

  @override
  String get noFederatedShares => 'Nothing has been shared with you from other servers';

  @override
  String declineFederatedTitle(String name) {
    return 'Decline $name?';
  }

  @override
  String removeFederatedTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String removeFederatedMessage(String owner) {
    return '$owner is told you no longer want this share.';
  }

  @override
  String get acceptInvite => 'Accept invite';

  @override
  String get acceptInviteHint =>
      'Enter the invite token and server address you received. You become each other\'s contacts and can share with each other.';

  @override
  String get inviteSomeone => 'Invite someone';

  @override
  String get inviteToken => 'Invite token';

  @override
  String get inviteCreatedTitle => 'Invite created';

  @override
  String inviteCreatedMessage(String date) {
    return 'Send the token and this server\'s address to the other person. They accept it on their own server before $date.';
  }

  @override
  String inviteAccepted(String name) {
    return '$name is now a contact';
  }

  @override
  String get openInvite => 'Open invite';

  @override
  String get openInvites => 'Open invites';

  @override
  String get federationContacts => 'Contacts on other servers';

  @override
  String removeContactTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeContactMessage => 'Shares stay as they are; you can invite each other again later.';

  @override
  String get copied => 'Copied';

  @override
  String get checkSenderAddress => 'Check sender address';

  @override
  String get checkSenderAddressHint =>
      'For servers that do not sign requests: only accept them from addresses the server\'s name points to';

  @override
  String get serverUnsignedChecked => 'Does not sign requests; sender address checked';

  @override
  String get serverUnsignedAnyAddress => 'Does not sign requests; any sender address accepted';

  @override
  String get shareDetailsTitle => 'Share details';

  @override
  String get shareDetailsSoftware => 'Software';

  @override
  String get shareDetailsSharedOn => 'Shared on';

  @override
  String get sharedWithYou => 'Shared with you';

  @override
  String leaveShareMessage(String owner) {
    return 'It disappears from your files. $owner can share it with you again.';
  }

  @override
  String get showSharesInFiles => 'Show in Files';

  @override
  String get showSharesInFilesHint => 'Shares appear among your own files. When off, open them from here.';

  @override
  String get sharedByYou => 'Shared by you';

  @override
  String get serverPreviewsGroup => 'Previews';

  @override
  String get regeneratePreviews => 'Regenerate previews';

  @override
  String get regeneratePreviewsHint => 'Make every file\'s preview again in the background';

  @override
  String get regeneratePreviewsMessage =>
      'Every file gets a new preview in the background. Until its new preview is ready, a file shows its icon.';

  @override
  String get regenerate => 'Regenerate';

  @override
  String previewsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files queued for a new preview',
      one: '1 file queued for a new preview',
    );
    return '$_temp0';
  }

  @override
  String get searchFieldTag => 'Tag';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsAction => 'Tags…';

  @override
  String get tagPickerHint => 'Search or create a tag';

  @override
  String get tagInvalidName => 'Use letters, digits, -, _ or / without spaces';

  @override
  String get tagsEmpty => 'No tags yet. Type #name in a note, or add one from an item\'s menu.';

  @override
  String tagCreate(String name) {
    return 'Create #$name';
  }

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Not used',
    );
    return '$_temp0';
  }

  @override
  String get tagEditTitle => 'Edit tag';

  @override
  String get tagName => 'Name';

  @override
  String get tagColor => 'Color';

  @override
  String tagDeleteTitle(String name) {
    return 'Delete #$name?';
  }

  @override
  String tagDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It is removed from $count items, including the text of your notes.',
      one: 'It is removed from 1 item, including the text of your notes.',
      zero: 'The tag is not used anywhere.',
    );
    return '$_temp0';
  }

  @override
  String get tagSuggestionCreate => 'New tag';

  @override
  String get searchKeywordsTags => 'labels, hashtags, colors, categories';

  @override
  String get tagsDeleteUnused => 'Delete unused tags';

  @override
  String get tagsDeleteUnusedTitle => 'Delete unused tags?';

  @override
  String tagsDeleteUnusedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags are not on any item or in any of your notes. They will be deleted.',
      one: '1 tag is not on any item or in any of your notes. It will be deleted.',
    );
    return '$_temp0';
  }

  @override
  String tagsUnusedDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags deleted',
      one: '1 tag deleted',
      zero: 'No unused tags',
    );
    return '$_temp0';
  }

  @override
  String get recipeImportLink => 'Link to the recipe';

  @override
  String get recipeImportMessage =>
      'The ingredients, steps and images are copied into a new note. You can tidy it up afterwards.';

  @override
  String get recipeImportAction => 'Import';

  @override
  String get recipeStartCooking => 'Start cooking';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeServings => 'Servings';

  @override
  String get recipeFewerServings => 'Fewer servings';

  @override
  String get recipeMoreServings => 'More servings';

  @override
  String recipeStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get recipeYouNeed => 'You\'ll need';

  @override
  String get recipePrevious => 'Previous';

  @override
  String get recipeNext => 'Next';

  @override
  String get recipeBegin => 'Begin';

  @override
  String get recipeDone => 'Done';

  @override
  String get recipeNoSteps => 'This recipe has no steps yet.';

  @override
  String recipeStartTimer(String duration) {
    return 'Start a timer for $duration';
  }

  @override
  String get recipeStopTimer => 'Stop timer';

  @override
  String recipeTimerDone(String label) {
    return '$label is done';
  }

  @override
  String get recipeImportFromLink => 'Link';

  @override
  String get recipeImportFromPaste => 'Paste';

  @override
  String get recipeImportPasteMessage =>
      'Copy the recipe in your browser and paste it here. Select the text from the title to the last step, or copy the whole page source to get the images too.';

  @override
  String get recipeImportPasteButton => 'Paste from clipboard';

  @override
  String recipeImportPastedLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters pasted',
      one: '1 character pasted',
    );
    return '$_temp0';
  }

  @override
  String get recipeImportLinkOptional => 'Link to the recipe (optional)';

  @override
  String get recipeImportRefused =>
      'This site doesn\'t let Polder load the page. Open it in your browser, copy the recipe and paste it here.';

  @override
  String get recipeImportClipboardEmpty => 'The clipboard holds no text.';

  @override
  String get recipeAdd => 'Add recipe';

  @override
  String get recipeFromScratch => 'Custom';

  @override
  String get recipeFromScratchMessage => 'Start from an empty recipe with ingredients and steps to fill in yourself.';

  @override
  String get notesFilterByTag => 'Filter by tag';

  @override
  String get notesFilterClear => 'Clear';

  @override
  String get notesFilterNoTags => 'No tags yet. Create tags to filter your notes by them.';

  @override
  String get notesFilterNoMatches => 'No notes in your notes folder have these tags.';

  @override
  String get notesSearchHint => 'Filter notes';

  @override
  String get notesSearchNoResults => 'No notes match your search.';

  @override
  String get notesViewOptions => 'Sort and view options';

  @override
  String get notesExpandAll => 'Expand all';

  @override
  String get notesCollapseAll => 'Collapse all';

  @override
  String get notesRevealCurrent => 'Reveal open note';

  @override
  String get notesShowFamilyTree => 'Related pages';

  @override
  String get notesViewAll => 'All notes';

  @override
  String get notesViewUntagged => 'Untagged';

  @override
  String get notesViewUntaggedEmpty => 'Every note in your notes folder has a tag.';

  @override
  String get durationLabel => 'Duration';

  @override
  String get slideshow => 'Slideshow';

  @override
  String get previousItem => 'Previous';

  @override
  String get nextItem => 'Next';

  @override
  String mediaCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String get couldNotLoadMedia => 'This file couldn\'t be loaded';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get setAsWallpaper => 'Set as wallpaper';

  @override
  String get wallpaperSet => 'Wallpaper updated';

  @override
  String get setAs => 'Set as…';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get lensLabel => 'Lens';

  @override
  String get apertureLabel => 'Aperture';

  @override
  String get shutterSpeedLabel => 'Shutter speed';

  @override
  String get focalLengthLabel => 'Focal length';

  @override
  String get isoLabel => 'ISO';

  @override
  String get locationLabel => 'Location';

  @override
  String get videoCodecLabel => 'Video codec';

  @override
  String get frameRateLabel => 'Frame rate';

  @override
  String get audioCodecLabel => 'Audio codec';

  @override
  String get bitrateLabel => 'Bitrate';

  @override
  String get updates => 'Updates';

  @override
  String get updatesAutomatic => 'Install updates automatically';

  @override
  String get updatesAutomaticHint => 'Download new versions in the background and install them when Polder quits';

  @override
  String get updatesNightly => 'Receive nightly builds';

  @override
  String get updatesNightlyHint => 'Get the newest development builds early; they may contain bugs';

  @override
  String get updatesCheck => 'Check for updates';

  @override
  String get updatesChecking => 'Checking for updates…';

  @override
  String get updatesUpToDate => 'Polder is up to date';

  @override
  String get updatesFailed => 'Couldn\'t check for updates';

  @override
  String updatesInstallFailed(String version, int build) {
    return 'Couldn\'t install version $version ($build)';
  }

  @override
  String updatesAvailable(String version, int build) {
    return 'Version $version ($build) is available';
  }

  @override
  String updatesDownloading(int percent) {
    return 'Downloading update… $percent%';
  }

  @override
  String updatesReady(String version, int build) {
    return 'Version $version ($build) installs when Polder quits';
  }

  @override
  String get updatesRestart => 'Restart to update';

  @override
  String get updatesInstall => 'Update now';

  @override
  String get updatesDownload => 'Download';

  @override
  String get updatesReleaseNotes => 'Release notes';

  @override
  String get aboutNightly => 'Nightly build';

  @override
  String get calendarImported => 'Imported';

  @override
  String get calendarNoImported => 'Add calendars from other services, such as Google Calendar, Outlook or iCloud.';

  @override
  String get calendarNew => 'New calendar';

  @override
  String get calendarEdit => 'Edit calendar';

  @override
  String get calendarAddExternal => 'Add external calendar';

  @override
  String get calendarName => 'Name';

  @override
  String get calendarColorLabel => 'Color';

  @override
  String get calendarDefault => 'Default';

  @override
  String get calendarSetDefault => 'Use for invitations';

  @override
  String calendarDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get calendarDeleteMessage => 'The calendar and all its events will be deleted for everyone it is shared with.';

  @override
  String calendarLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get calendarLeaveMessage => 'You will no longer see this calendar. The owner can share it with you again.';

  @override
  String get calendarLeave => 'Leave';

  @override
  String calendarRemoveImportedTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get calendarRemoveImportedMessage =>
      'The calendar stops syncing and its events are removed from Polder. The original is not affected.';

  @override
  String get calendarRemove => 'Remove';

  @override
  String get calendarSyncNow => 'Sync now';

  @override
  String calendarSyncedAt(String time) {
    return 'Synced $time';
  }

  @override
  String get calendarSyncPending => 'Waiting for the first sync';

  @override
  String calendarSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String calendarSyncRequested(String name) {
    return 'Syncing $name';
  }

  @override
  String get calendarFromUrl => 'Link';

  @override
  String get calendarFromUrlHint =>
      'Stays up to date. Paste an iCal (.ics) or webcal link, such as the secret address of a Google, Outlook or iCloud calendar.';

  @override
  String get calendarFromFile => 'File';

  @override
  String get calendarFromFileHint =>
      'Adds the events of an .ics file once, as a new calendar. A .zip with .ics files, such as a Google Calendar export, works too.';

  @override
  String get calendarLink => 'Calendar link';

  @override
  String get calendarInvalidLink => 'Enter an http, https or webcal link';

  @override
  String get calendarRefreshEvery => 'Refresh';

  @override
  String get calendarEvery15Minutes => 'Every 15 minutes';

  @override
  String get calendarEveryHour => 'Every hour';

  @override
  String get calendarEvery6Hours => 'Every 6 hours';

  @override
  String get calendarEveryDay => 'Every day';

  @override
  String get calendarChooseFile => 'Choose .ics file';

  @override
  String calendarImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events imported',
      one: '1 event imported',
    );
    return '$_temp0';
  }

  @override
  String get calendarAccessRead => 'Can view';

  @override
  String get calendarAccessReadWrite => 'Can edit';

  @override
  String get calendarAccessFreeBusy => 'Sees busy times only';

  @override
  String get calendarStopSharing => 'Stop sharing';

  @override
  String get calendarManage => 'Calendars';

  @override
  String get calendarDiscover => 'Discover';

  @override
  String get calendarDiscoverHint => 'Calendars that stay up to date by themselves.';

  @override
  String get calendarSuggested => 'Suggested';

  @override
  String get calendarPublicHolidays => 'Public holidays';

  @override
  String get calendarReligiousHolidays => 'Religious holidays';

  @override
  String get calendarMore => 'More';

  @override
  String get calendarSearchCountries => 'Search countries';

  @override
  String calendarHolidaysIn(String country) {
    return 'Holidays in $country';
  }

  @override
  String get calendarChristianHolidays => 'Christian holidays';

  @override
  String get calendarOrthodoxHolidays => 'Orthodox Christian holidays';

  @override
  String get calendarIslamicHolidays => 'Islamic holidays';

  @override
  String get calendarJewishHolidays => 'Jewish holidays';

  @override
  String get calendarHinduHolidays => 'Hindu holidays';

  @override
  String get calendarWeekNumbers => 'Week numbers';

  @override
  String get calendarMoonPhases => 'Phases of the moon';

  @override
  String get calendarAdded => 'Added';

  @override
  String get calendarImportInto => 'Import from file';

  @override
  String get calendarImportIntoHint => 'Choose an .ics file, or a .zip of them such as a Google Calendar export';

  @override
  String calendarImportFailedSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events could not be imported',
      one: '1 event could not be imported',
    );
    return '$_temp0';
  }

  @override
  String get calendarFeedLanguage => 'Language of the calendars';

  @override
  String get calendarFeedLanguageHint =>
      'Google translates calendar names and most holidays; some event names stay in English.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHint => 'Shares, reminders and uploads';

  @override
  String get notificationsEnable => 'Show notifications';

  @override
  String get notificationsEnableHint => 'On this device';

  @override
  String get notificationsWebHint => 'Your browser shows them while Polder is open in a tab';

  @override
  String get notificationsBlocked =>
      'Notifications are blocked. Allow them for Polder in your system or browser settings.';

  @override
  String get notificationsNotAllowed =>
      'Notifications are on, but this device hasn\'t allowed Polder to show them yet.';

  @override
  String get notificationsAllow => 'Allow';

  @override
  String get notificationsOpenSettings => 'Open settings';

  @override
  String get notificationsReminderOff => 'Calendar reminder notifications are off, so you won\'t get these.';

  @override
  String get notificationsTurnOn => 'Turn on';

  @override
  String get notificationsAbout => 'What to notify about';

  @override
  String get notificationsShares => 'New shares';

  @override
  String get notificationsSharesHint =>
      'When someone shares a file or folder with you, with buttons to accept or decline';

  @override
  String get notificationsCalendar => 'Calendar reminders';

  @override
  String get notificationsCalendarHint =>
      'At the reminder times set on each event; turn calendars on or off from their menu in the calendar';

  @override
  String get notificationsUploadProgress => 'Upload progress';

  @override
  String get notificationsUploadProgressHint => 'One notification that keeps updating while auto upload runs';

  @override
  String get notificationsUploadSummary => 'Upload results';

  @override
  String get notificationsUploadSummaryHint => 'How much was uploaded, and anything that failed';

  @override
  String get notificationsUploadCheck => 'Checking for new photos';

  @override
  String get notificationsUploadCheckHint => 'A quiet notification while auto upload looks for new photos and videos';

  @override
  String get notificationsReliability => 'Reliability';

  @override
  String get notificationsBattery => 'Run in the background';

  @override
  String get notificationsBatteryHint => 'Stops the system from delaying reminders, shares and uploads to save battery';

  @override
  String get notificationsAllowed => 'Allowed';

  @override
  String get notificationChannelUploads => 'Uploads';

  @override
  String get notificationChannelCalendar => 'Calendar reminders';

  @override
  String get notificationChannelSharing => 'Shares';

  @override
  String notificationShareTitle(String owner, String name) {
    return '$owner shared $name with you';
  }

  @override
  String notificationShareGroupTitle(String owner, String name, String group) {
    return '$owner shared $name with $group';
  }

  @override
  String notificationFederatedShareBody(String server) {
    return 'From $server';
  }

  @override
  String notificationUploadingTitle(int done, int total) {
    return 'Uploading $done of $total';
  }

  @override
  String notificationUploadDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files uploaded',
      one: '1 file uploaded',
    );
    return '$_temp0';
  }

  @override
  String notificationUploadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files could not be uploaded',
      one: '1 file could not be uploaded',
    );
    return '$_temp0';
  }

  @override
  String get notificationUploadFailedBody => 'Open auto upload to see what went wrong';

  @override
  String get notificationUploadChecking => 'Checking for new photos and videos';

  @override
  String notificationReminderAt(String time) {
    return '$time';
  }

  @override
  String get notificationReminderAllDay => 'All day';

  @override
  String get calendarRemindersOn => 'Turn reminders on';

  @override
  String get calendarRemindersOff => 'Turn reminders off';

  @override
  String get sharedWaiting => 'Waiting for you';

  @override
  String get sharedWaitingHint => 'Accept to add these to your files';

  @override
  String shareAccepted(String name) {
    return '$name is now in your files';
  }

  @override
  String shareDeclined(String name) {
    return 'Declined $name';
  }

  @override
  String get errorStorageFull => 'The server ran out of disk space and could not save this.';

  @override
  String get errorTimedOut => 'The server stopped responding.';

  @override
  String get connectionNoNetwork => 'No network connection';

  @override
  String get connectionServerUnreachable => 'Not connected to server';

  @override
  String get connectionServerFull => 'Server storage is full';

  @override
  String get connectionServerReadOnly => 'Server can\'t store changes';

  @override
  String changesSavedOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes saved on this device',
      one: '1 change saved on this device',
      zero: 'Changes are saved on this device',
    );
    return '$_temp0';
  }

  @override
  String get hintUnreachable =>
      'Check your network connection, or whether the server is running. Changes sync automatically when it\'s back.';

  @override
  String get hintStorageFull =>
      'The server could not store the change; its disk may be full. Ask the server administrator to free up space, then retry.';

  @override
  String get hintQuota => 'Your storage quota is full. Delete files or empty the trash, then retry.';

  @override
  String get hintServerError =>
      'The server ran into an error. Retry later, or ask the server administrator to check the server logs.';

  @override
  String get hintConflict => 'This was changed somewhere else too. Choose which version to keep.';

  @override
  String get hintRejected => 'The server refused this change. Discard it, or save a copy and try again.';

  @override
  String get noteSynced => 'Saved and synced';

  @override
  String get noteSavedOnDevice => 'Saved on this device; waiting to sync. Tap to sync now';

  @override
  String get noteNotSynced => 'Saved on this device, but not synced to the server';

  @override
  String get retrySync => 'Retry';

  @override
  String get retryAll => 'Retry all';

  @override
  String get discardChange => 'Discard';

  @override
  String get discardChangeTitle => 'Discard this change?';

  @override
  String get discardChangeMessage => 'The version on this device is thrown away and the server\'s version is kept.';

  @override
  String get offlineGroupNotes => 'Notes';

  @override
  String get offlineGroupFiles => 'Files';

  @override
  String get offlineGroupCalendar => 'Calendar';

  @override
  String get syncWaitingForServer => 'Waiting for the server';

  @override
  String get syncFailedItem => 'Not synced';

  @override
  String get keepOffline => 'Make available offline';

  @override
  String get removeFromDevice => 'Remove from device';

  @override
  String get availableOffline => 'Available offline';

  @override
  String get errorDeviceFull => 'Not enough free space on this device';

  @override
  String get hintDeviceFull => 'Free up space on this device, or remove offline files with \"Remove from device\".';

  @override
  String offlineDownloadFailed(String reason) {
    return 'Couldn\'t download for offline use: $reason';
  }

  @override
  String offlineDownloadingTag(int percent) {
    return 'Downloading $percent%';
  }

  @override
  String offlineDownloadsFailedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files couldn\'t be made available offline',
      one: '1 file couldn\'t be made available offline',
    );
    return '$_temp0';
  }

  @override
  String get waitingForOffline => 'Waiting to download for offline use';

  @override
  String downloadingForOffline(int percent) {
    return 'Downloading for offline use, $percent%';
  }

  @override
  String downloadingFilesForOffline(int done, int total) {
    return 'Downloading for offline use, $done of $total files';
  }

  @override
  String get sessionEndedTitle => 'Sign in again';

  @override
  String get sessionEndedMessage =>
      'Your session on this device has ended. Sign in again to keep syncing. Nothing on this device is lost.';

  @override
  String get sessionEndedStatus => 'Session ended';

  @override
  String get sessionEndedSignIn => 'Sign in';

  @override
  String get continueOffline => 'Continue offline';

  @override
  String get firstDayOfWeek => 'First day of the week';

  @override
  String firstDayOfWeekRegional(String day) {
    return 'Regional default ($day)';
  }

  @override
  String get calendarSettings => 'Calendar settings';

  @override
  String fileOperationMoving(String subject) {
    return 'Moving $subject';
  }

  @override
  String fileOperationMoved(String subject) {
    return 'Moved $subject';
  }

  @override
  String fileOperationCopying(String subject) {
    return 'Copying $subject';
  }

  @override
  String fileOperationCopied(String subject) {
    return 'Copied $subject';
  }

  @override
  String fileOperationDeleting(String subject) {
    return 'Deleting $subject';
  }

  @override
  String fileOperationDeleted(String subject) {
    return 'Deleted $subject';
  }

  @override
  String fileOperationRenaming(String subject) {
    return 'Renaming $subject';
  }

  @override
  String fileOperationRenamed(String subject) {
    return 'Renamed $subject';
  }

  @override
  String fileOperationRestoring(String subject) {
    return 'Restoring $subject';
  }

  @override
  String fileOperationRestored(String subject) {
    return 'Restored $subject';
  }

  @override
  String fileOperationPurging(String subject) {
    return 'Permanently deleting $subject';
  }

  @override
  String fileOperationPurged(String subject) {
    return 'Permanently deleted $subject';
  }

  @override
  String fileOperationItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0';
  }

  @override
  String fileOperationInto(String folder) {
    return 'To $folder';
  }

  @override
  String get fileOperationIncomplete => 'Not everything went through';

  @override
  String get fileOperationTagMoving => 'Moving…';

  @override
  String get fileOperationTagCopying => 'Copying…';

  @override
  String get fileOperationTagDeleting => 'Deleting…';

  @override
  String get fileOperationTagRenaming => 'Renaming…';

  @override
  String get fileOperationTagWaiting => 'Waiting';

  @override
  String get fileOperationTagMovingHere => 'Moving here…';

  @override
  String get fileOperationTagCopyingHere => 'Copying here…';

  @override
  String fileOperationsMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more actions',
      one: '1 more action',
    );
    return '$_temp0';
  }

  @override
  String get fileOperationTagRestoring => 'Restoring…';

  @override
  String get emailSettings => 'Email';

  @override
  String get emailSettingsHint => 'Mail server for password resets, alerts and shares';

  @override
  String get emailOn => 'Emails are on';

  @override
  String get emailOff => 'Emails are off';

  @override
  String get emailOnHint =>
      'Polder sends password resets, sign-in alerts, storage warnings and shares, styled with your branding.';

  @override
  String get emailOffHint =>
      'Set an SMTP server and a sender address to send password resets, sign-in alerts, storage warnings and shares.';

  @override
  String get emailManagedByConfig =>
      'These settings come from the server\'s config or environment, so they can\'t be changed here.';

  @override
  String get mailServerGroup => 'SMTP';

  @override
  String get mailServerHost => 'SMTP server';

  @override
  String get notSet => 'Not set';

  @override
  String get mailSecurity => 'Security';

  @override
  String get mailServerPort => 'SMTP port';

  @override
  String mailServerPortDefault(int port) {
    return 'Default ($port)';
  }

  @override
  String get mailServerPortLabel => 'Port, or empty for the default';

  @override
  String get mailUsername => 'SMTP username';

  @override
  String get mailUsernameNone => 'None; the SMTP server doesn\'t need a login';

  @override
  String get mailPasswordSaved => 'Saved';

  @override
  String get mailPassword => 'SMTP password';

  @override
  String get mailPasswordHint =>
      'Stored on the server and never shown again. Remove it if the SMTP server needs no login.';

  @override
  String get mailSenderGroup => 'Sender';

  @override
  String get mailFrom => 'From address';

  @override
  String get mailFromHint => 'The address emails come from';

  @override
  String get mailFromLabel => 'Address, such as Polder <polder@example.com>';

  @override
  String get mailTestGroup => 'Test';

  @override
  String get sendTestEmail => 'Send a test email';

  @override
  String get sendTestEmailHint => 'Check the settings with an email in your server\'s style';

  @override
  String get sendTestEmailNeedsServer => 'Set an SMTP server and sender address first';

  @override
  String get mailTestRecipient => 'Send to';

  @override
  String get send => 'Send';

  @override
  String testEmailSent(String address) {
    return 'Test email sent to $address';
  }

  @override
  String get mailSecurityStartTls => 'STARTTLS';

  @override
  String get mailSecurityTls => 'TLS';

  @override
  String get mailSecurityNone => 'None';

  @override
  String get mailSecurityStartTlsHint => 'Upgrades to an encrypted connection; usually port 587';

  @override
  String get mailSecurityTlsHint => 'Encrypted from the start; usually port 465';

  @override
  String get mailSecurityNoneHint => 'Unencrypted; only for an SMTP server on a trusted network';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordHint =>
      'Enter your username or email address. If your account has an email address, we\'ll send it a code to choose a new password.';

  @override
  String get usernameOrEmail => 'Username or email';

  @override
  String get resetUnavailable =>
      'This server can\'t send password reset emails. Ask an administrator to set a new password for you.';

  @override
  String get sendResetCode => 'Send code';

  @override
  String get resetCodeTitle => 'Enter your code';

  @override
  String get resetCodeSent =>
      'If an account matches and has an email address, we\'ve sent it a code. It works once, for an hour.';

  @override
  String get resetCode => 'Code from the email';

  @override
  String get resetCodeNeverLinks => 'We never send reset links. Type the code here yourself.';

  @override
  String get sendResetCodeAgain => 'Send a new code';

  @override
  String get passwordResetDoneTitle => 'Password changed';

  @override
  String get passwordResetDone => 'Sign in with your new password. You\'ve been signed out on your other devices.';

  @override
  String get emailNotifications => 'Email';

  @override
  String get emailNotificationsNoAddress => 'Add an email address';

  @override
  String get emailNotificationsNoAddressHint => 'Emails need an address in your account';

  @override
  String get emailSecurity => 'Security alerts';

  @override
  String get emailSecurityHint => 'Sign-ins from new addresses and changes to your email address';

  @override
  String get emailQuota => 'Storage warnings';

  @override
  String get emailQuotaHint => 'When your storage is almost or completely full';

  @override
  String get emailShares => 'Shares';

  @override
  String get emailSharesHint => 'When someone shares a file or folder with you';

  @override
  String get emailAlwaysSent => 'Password resets and password changes are always emailed.';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get newUserEmailHint => 'Gets a welcome email, and lets the user reset a forgotten password';

  @override
  String get invalidEmail => 'Not an email address';

  @override
  String get waitingForBrowser => 'Finish signing in in your browser';

  @override
  String get signInOr => 'or';

  @override
  String signInWithProvider(String provider) {
    return 'Sign in with $provider';
  }

  @override
  String get signInWithAnotherDevice => 'Sign in with another device';

  @override
  String get twoFactorCodePrompt => 'Enter the 6-digit code from your authenticator app.';

  @override
  String get twoFactorRecoveryPrompt => 'Enter one of your recovery codes. Each code works once.';

  @override
  String get authenticatorCode => 'Authentication code';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get verify => 'Verify';

  @override
  String get back => 'Back';

  @override
  String get approveOnAnotherDevice => 'Approve on another device instead';

  @override
  String get useRecoveryCode => 'Use a recovery code';

  @override
  String get useAuthenticatorCode => 'Use the authenticator app';

  @override
  String get deviceApprovalPrompt => 'Open Polder on a device where you\'re signed in and type this number:';

  @override
  String get deviceApprovalHint => 'The request only reaches devices with Polder open.';

  @override
  String get loginErrorInvalidCode => 'That code is wrong or has expired.';

  @override
  String get loginErrorTooManyAttempts => 'Too many attempts. Wait a minute and try again.';

  @override
  String get loginErrorApprovalDenied => 'The sign-in was refused on your other device.';

  @override
  String get loginErrorApprovalExpired => 'No device approved the sign-in in time.';

  @override
  String get loginErrorSsoSignupDisabled =>
      'There\'s no account for you on this server yet. Ask your administrator to create one or to link it.';

  @override
  String get loginErrorSsoLinkRequired =>
      'An account with this email address already exists. Sign in with its password, then connect this provider under Settings → Account.';

  @override
  String get loginErrorSsoFailed => 'Signing in with the provider didn\'t work. Try again or ask your administrator.';

  @override
  String get loginApprovalTitle => 'Sign-in request';

  @override
  String loginApprovalBody(String device, String address) {
    return '$device wants to sign in to your account from $address.';
  }

  @override
  String get loginApprovalTypeNumber => 'Type the number shown on that device';

  @override
  String get loginApprovalApprove => 'Approve';

  @override
  String get loginApprovalDeny => 'It wasn\'t me';

  @override
  String get loginApprovalWrongNumber => 'That wasn\'t the right number, so the sign-in was refused.';

  @override
  String loginApprovalNotificationTitle(String device) {
    return '$device wants to sign in';
  }

  @override
  String loginApprovalNotificationBody(String address) {
    return 'Open Polder to approve or refuse the sign-in from $address.';
  }

  @override
  String get notificationChannelSecurity => 'Security';

  @override
  String get twoFactorTitle => 'Two-factor authentication';

  @override
  String get twoFactorOn => 'On';

  @override
  String get twoFactorOff => 'Off';

  @override
  String get twoFactorOffHint => 'Ask for a code from an authenticator app when signing in with your password.';

  @override
  String twoFactorRequiredBy(String date) {
    return 'Required by your administrator before $date';
  }

  @override
  String get twoFactorRequiredByAdmin => 'Your administrator requires it';

  @override
  String recoveryCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recovery codes left',
      one: '1 recovery code left',
    );
    return '$_temp0';
  }

  @override
  String get regenerateRecoveryCodes => 'New recovery codes';

  @override
  String get regenerateRecoveryCodesHint => 'Your current recovery codes stop working.';

  @override
  String get turnOffTwoFactor => 'Turn off two-factor authentication';

  @override
  String get turnOffTwoFactorHint => 'Signing in will only need your password again.';

  @override
  String get twoFactorSetupTitle => 'Set up two-factor authentication';

  @override
  String get twoFactorSetupIntro => 'Enter your password to start.';

  @override
  String get twoFactorContinue => 'Continue';

  @override
  String get twoFactorScanIntro =>
      'Scan this QR code with an authenticator app such as Aegis, 2FAS or Google Authenticator, then enter the code it shows.';

  @override
  String get twoFactorOpenAuthenticator => 'Open in authenticator app';

  @override
  String get twoFactorManualKey => 'Or enter this key';

  @override
  String get twoFactorCodeMismatch => 'That code doesn\'t match. Check the time on your device and try again.';

  @override
  String get recoveryCodesTitle => 'Save your recovery codes';

  @override
  String get recoveryCodesIntro =>
      'If you lose your phone, each of these codes lets you sign in once. Keep them somewhere safe; you won\'t see them again.';

  @override
  String get copyRecoveryCodes => 'Copy codes';

  @override
  String get recoveryCodesSaved => 'I\'ve saved them';

  @override
  String get setUp => 'Set up';

  @override
  String twoFactorDeadlineBanner(String date) {
    return 'Set up two-factor authentication before $date.';
  }

  @override
  String get twoFactorRequiredTitle => 'Two-factor authentication is required';

  @override
  String get twoFactorRequiredBody =>
      'Your administrator requires it for every account. Set it up to keep using Polder.';

  @override
  String get setPassword => 'Set a password';

  @override
  String get connectedAccounts => 'Connected accounts';

  @override
  String get notConnected => 'Not connected';

  @override
  String get unlink => 'Unlink';

  @override
  String unlinkTitle(String provider) {
    return 'Unlink $provider?';
  }

  @override
  String unlinkMessage(String provider) {
    return 'You can no longer sign in with $provider until you connect it again.';
  }

  @override
  String get ssoAlreadyLinked => 'That account is already linked to someone else.';

  @override
  String get adminAuthentication => 'Authentication';

  @override
  String get adminAuthenticationHint => 'Two-factor authentication and single sign-on';

  @override
  String get requireTwoFactor => 'Require two-factor authentication';

  @override
  String get requireTwoFactorHint => 'Everyone who signs in with a password must set it up. Single sign-on is exempt.';

  @override
  String requireTwoFactorConfirm(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days to set it up',
      one: '1 day to set it up',
      zero: 'to set it up right away',
    );
    return 'Everyone without it gets an email and has $_temp0. After that, they can only set it up.';
  }

  @override
  String get require => 'Require';

  @override
  String get twoFactorGracePeriod => 'Grace period';

  @override
  String twoFactorGracePeriodHint(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days to set it up',
      one: '1 day to set it up',
      zero: 'No grace period',
    );
    return '$_temp0; changes apply to new deadlines';
  }

  @override
  String get days => 'Days';

  @override
  String get twoFactorNoMailWarning =>
      'No mail server is set up, so users won\'t get an email about the deadline. They\'ll still see it in the apps.';

  @override
  String get singleSignOn => 'Single sign-on';

  @override
  String get singleSignOnHint =>
      'Let people sign in with an identity provider such as Pocket ID, authentik, Keycloak, Google, Microsoft or GitHub.';

  @override
  String get addProvider => 'Add provider';

  @override
  String addProviderNamed(String provider) {
    return 'Add $provider';
  }

  @override
  String get noProviders => 'No providers yet';

  @override
  String get managedByConfig => 'Set in the server config';

  @override
  String linkedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked accounts',
      one: '1 linked account',
      zero: 'No linked accounts',
    );
    return '$_temp0';
  }

  @override
  String get providerManagedByConfigHint =>
      'This provider is set in the server config. You can only turn it on or off here.';

  @override
  String get buttonLabel => 'Button label';

  @override
  String get issuerUrl => 'Issuer URL';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client secret';

  @override
  String get clientSecretKept => 'Leave empty to keep the stored secret';

  @override
  String get callbackUrl => 'Callback URL';

  @override
  String get providerServerUrl => 'Server URL';

  @override
  String get providerRealm => 'Realm';

  @override
  String get providerSlug => 'Application slug';

  @override
  String get providerTenantId => 'Tenant ID';

  @override
  String get identityProvider => 'the identity provider';

  @override
  String providerUrlNamed(String provider) {
    return '$provider URL';
  }

  @override
  String get providerTenantIdHint =>
      'Your directory (tenant) ID, or common, organizations or consumers to allow other directories';

  @override
  String callbackUrlHint(String provider, String field) {
    return 'Paste this at $provider under “$field”';
  }

  @override
  String get providerAllowSignup => 'Create accounts';

  @override
  String get providerAllowSignupHint => 'People without an account get one when they first sign in';

  @override
  String get providerLinkByEmail => 'Match by email address';

  @override
  String get providerLinkByEmailHint => 'Sign in to the existing account with the same verified email address';

  @override
  String get testConnection => 'Test';

  @override
  String get providerTestOk => 'The provider answered correctly.';

  @override
  String providerTestFailed(String reason) {
    return 'The provider can\'t be reached: $reason';
  }

  @override
  String deleteProviderTitle(String provider) {
    return 'Remove $provider?';
  }

  @override
  String deleteProviderMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The sign-in button disappears and $count accounts are unlinked. Accounts without a password can then no longer sign in.',
      one: 'The sign-in button disappears and 1 account is unlinked. Accounts without a password can then no longer sign in.',
      zero: 'The sign-in button disappears.',
    );
    return '$_temp0';
  }

  @override
  String get twoFactorTag => '2FA';

  @override
  String twoFactorDueTag(String date) {
    return '2FA due $date';
  }

  @override
  String get twoFactorOverdueTag => '2FA overdue';

  @override
  String get ssoTag => 'SSO';

  @override
  String get resetTwoFactor => 'Reset two-factor';

  @override
  String resetTwoFactorTitle(String username) {
    return 'Reset two-factor authentication for $username?';
  }

  @override
  String get resetTwoFactorMessage =>
      'Use this when they lost their authenticator app. They\'re signed out everywhere and can set it up again.';

  @override
  String get extendTwoFactorDeadline => 'Give more time for 2FA';

  @override
  String get settingsApps => 'Apps';

  @override
  String get settingsAppsHint => 'How Files, Notes and Calendar show up';

  @override
  String get settingsAppsIntro =>
      'Choose per part of Polder whether it lives inside this app, opens its own app, or stays out of the way. Polder only sends notifications for the parts that are built in.';

  @override
  String get featureModeAutomatic => 'Automatic';

  @override
  String featureModeAutomaticOpens(String app) {
    return 'Opens $app, which is installed on this device';
  }

  @override
  String featureModeAutomaticBuiltIn(String app) {
    return 'Built in, until $app is installed on this device';
  }

  @override
  String get featureModeBuiltIn => 'Built in';

  @override
  String get featureModeBuiltInHint => 'Shown inside Polder, with its notifications';

  @override
  String get featureModeOpenApp => 'Open app';

  @override
  String featureModeOpenAppHint(String app) {
    return 'Opens $app; Polder sends no notifications for it';
  }

  @override
  String get featureModeHidden => 'Hidden';

  @override
  String get featureModeHiddenHint => 'Not shown in Polder, and no notifications';

  @override
  String get companionAppUnavailable => 'That app could not be opened';
}
