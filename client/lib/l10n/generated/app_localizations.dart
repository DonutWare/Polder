import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('nl')];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Files, sync and auto-upload for your own server.'**
  String get aboutLegalese;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @accentCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Status colors are tuned to match your accent.'**
  String get accentCustomHint;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentNoSystemHint.
  ///
  /// In en, this message translates to:
  /// **'This device has no accent color to follow, so the default is used.'**
  String get accentNoSystemHint;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get accentRose;

  /// No description provided for @accentSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get accentSlate;

  /// No description provided for @accentSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device\'s accent color.'**
  String get accentSystemHint;

  /// No description provided for @accentTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get accentTeal;

  /// No description provided for @accentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addAutoUploadFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addAutoUploadFolder;

  /// No description provided for @addSyncFolder.
  ///
  /// In en, this message translates to:
  /// **'Add sync folder'**
  String get addSyncFolder;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// No description provided for @addUserHint.
  ///
  /// In en, this message translates to:
  /// **'Create an account with its own storage'**
  String get addUserHint;

  /// No description provided for @adminAccountsCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 administrator} other{{count} administrators}}'**
  String adminAccountsCaption(int count);

  /// No description provided for @adminDisabledCaption.
  ///
  /// In en, this message translates to:
  /// **'Can\'t sign in'**
  String get adminDisabledCaption;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @administrationHint.
  ///
  /// In en, this message translates to:
  /// **'Users and server management'**
  String get administrationHint;

  /// No description provided for @adminNearQuota.
  ///
  /// In en, this message translates to:
  /// **'Near quota'**
  String get adminNearQuota;

  /// No description provided for @adminNearQuotaCaption.
  ///
  /// In en, this message translates to:
  /// **'Over 90% of their quota'**
  String get adminNearQuotaCaption;

  /// No description provided for @adminOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get adminOverview;

  /// No description provided for @adminStorageCaption.
  ///
  /// In en, this message translates to:
  /// **'Across all accounts'**
  String get adminStorageCaption;

  /// No description provided for @adminStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get adminStorageUsed;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @applyToAll.
  ///
  /// In en, this message translates to:
  /// **'Apply my choice to all {count} conflicts'**
  String applyToAll(int count);

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nomad'**
  String get appTitle;

  /// No description provided for @autoUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload new photos and files from the chosen folders automatically.'**
  String get autoUploadDescription;

  /// No description provided for @autoUploadEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-upload'**
  String get autoUploadEnabled;

  /// No description provided for @backToFiles.
  ///
  /// In en, this message translates to:
  /// **'Back to files'**
  String get backToFiles;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @chargingOnly.
  ///
  /// In en, this message translates to:
  /// **'Only while charging'**
  String get chargingOnly;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @chooseServerFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a server folder'**
  String get chooseServerFolder;

  /// No description provided for @chooseThisFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose this folder'**
  String get chooseThisFolder;

  /// No description provided for @clearFinished.
  ///
  /// In en, this message translates to:
  /// **'Clear finished'**
  String get clearFinished;

  /// No description provided for @collapseSidebar.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get collapseSidebar;

  /// No description provided for @conflictBothCreated.
  ///
  /// In en, this message translates to:
  /// **'A different file with this name was created on both sides.'**
  String get conflictBothCreated;

  /// No description provided for @conflictBothModified.
  ///
  /// In en, this message translates to:
  /// **'Changed on this device and on the server.'**
  String get conflictBothModified;

  /// No description provided for @conflictLocalDeletedRemoteModified.
  ///
  /// In en, this message translates to:
  /// **'Deleted on this device but changed on the server.'**
  String get conflictLocalDeletedRemoteModified;

  /// No description provided for @conflictLocalModifiedRemoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Changed on this device but deleted on the server.'**
  String get conflictLocalModifiedRemoteDeleted;

  /// No description provided for @conflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get conflicts;

  /// No description provided for @conflictsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict needs your decision} other{{count} conflicts need your decision}}'**
  String conflictsWaiting(int count);

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create administrator'**
  String get createAdmin;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} deleted'**
  String deletedCount(int count);

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'It will be moved to the trash on the server.'**
  String get deleteMessage;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteTitle(String name);

  /// No description provided for @deleteUserMessage.
  ///
  /// In en, this message translates to:
  /// **'The account is removed. Their files are kept on the server disk.'**
  String get deleteUserMessage;

  /// No description provided for @deleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete user \"{username}\"?'**
  String deleteUserTitle(String username);

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'{width} × {height}'**
  String dimensions(int width, int height);

  /// No description provided for @dimensionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensionsLabel;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} downloaded'**
  String downloadedCount(int count);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit {username}'**
  String editUser(String username);

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get emptyFolder;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Something with that name already exists.'**
  String get errorAlreadyExists;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'The item was changed by someone else. Refresh and try again.'**
  String get errorConflict;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do that.'**
  String get errorForbidden;

  /// No description provided for @errorInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'The request was not valid.'**
  String get errorInvalidRequest;

  /// No description provided for @errorLocalFolderMissing.
  ///
  /// In en, this message translates to:
  /// **'The local folder {path} is missing.'**
  String errorLocalFolderMissing(String path);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'It no longer exists.'**
  String get errorNotFound;

  /// No description provided for @errorQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Your storage quota is full.'**
  String get errorQuotaExceeded;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @expandSidebar.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get expandSidebar;

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String failedCount(int count);

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @keepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get keepBoth;

  /// No description provided for @keepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get keepMine;

  /// No description provided for @keepServer.
  ///
  /// In en, this message translates to:
  /// **'Keep server\'s'**
  String get keepServer;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSynced(String time);

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @localFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder on this device'**
  String get localFolder;

  /// No description provided for @loginErrorDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled.'**
  String get loginErrorDisabled;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorSetupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This server has already been set up.'**
  String get loginErrorSetupUnavailable;

  /// No description provided for @loginErrorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach a Nomad server at this address.'**
  String get loginErrorUnreachable;

  /// No description provided for @loginServerIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of your Nomad server.'**
  String get loginServerIntro;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @manageUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Accounts, roles and quotas'**
  String get manageUsersHint;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @navAutoUpload.
  ///
  /// In en, this message translates to:
  /// **'Auto-upload'**
  String get navAutoUpload;

  /// No description provided for @navFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get navFiles;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @newPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'New password (leave empty to keep)'**
  String get newPasswordOptional;

  /// No description provided for @noConflicts.
  ///
  /// In en, this message translates to:
  /// **'No conflicts. Everything is in sync.'**
  String get noConflicts;

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders yet.'**
  String get noFolders;

  /// No description provided for @notChosen.
  ///
  /// In en, this message translates to:
  /// **'Not chosen'**
  String get notChosen;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users yet.'**
  String get noUsers;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @quota.
  ///
  /// In en, this message translates to:
  /// **'Quota'**
  String get quota;

  /// No description provided for @quotaInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of 0 or more'**
  String get quotaInvalid;

  /// No description provided for @quotaUnlimitedHint.
  ///
  /// In en, this message translates to:
  /// **'0 means unlimited'**
  String get quotaUnlimitedHint;

  /// No description provided for @quotaUsedOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} used'**
  String quotaUsedOf(String used, String total);

  /// No description provided for @quotaUsedUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{used} used'**
  String quotaUsedUnlimited(String used);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeSyncFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'The folder stops syncing. No files are deleted.'**
  String get removeSyncFolderMessage;

  /// No description provided for @removeSyncFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this folder?'**
  String get removeSyncFolderTitle;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @revision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get revision;

  /// No description provided for @revisionShort.
  ///
  /// In en, this message translates to:
  /// **'Revision {rev}'**
  String revisionShort(int rev);

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @rootFolder.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get rootFolder;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder on the server'**
  String get serverFolder;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://cloud.example.com'**
  String get serverUrlHint;

  /// No description provided for @setupIntro.
  ///
  /// In en, this message translates to:
  /// **'This server has no users yet. Create the first administrator account.'**
  String get setupIntro;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign out {username} from {server}?'**
  String signOutMessage(String username, String server);

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @storageByUser.
  ///
  /// In en, this message translates to:
  /// **'Storage by user'**
  String get storageByUser;

  /// No description provided for @syncedWith.
  ///
  /// In en, this message translates to:
  /// **'Synced with {remotePath}'**
  String syncedWith(String remotePath);

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync finished with errors'**
  String get syncError;

  /// No description provided for @syncFolders.
  ///
  /// In en, this message translates to:
  /// **'Sync folders'**
  String get syncFolders;

  /// No description provided for @syncIdle.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncIdle;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncRunning;

  /// No description provided for @syncUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Folder sync is not available on this platform.'**
  String get syncUnsupported;

  /// No description provided for @systemAccentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'System (not available on this device)'**
  String get systemAccentUnavailable;

  /// No description provided for @takenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get takenAt;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @transferDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get transferDone;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @uploadedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} uploaded'**
  String uploadedCount(int count);

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get uploadFiles;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @usersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 user} other{{count} users}}'**
  String usersCount(int count);

  /// No description provided for @wifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Only on Wi-Fi'**
  String get wifiOnly;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
