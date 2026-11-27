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

  /// No description provided for @aboutCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by DonutWare'**
  String get aboutCreatedBy;

  /// No description provided for @aboutHint.
  ///
  /// In en, this message translates to:
  /// **'Version, licenses and supporting the project'**
  String get aboutHint;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Create your own private polder and sync your files.'**
  String get aboutLegalese;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutSocials.
  ///
  /// In en, this message translates to:
  /// **'Socials'**
  String get aboutSocials;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Application version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutServerInfo.
  ///
  /// In en, this message translates to:
  /// **'Server version {version} ({buildNumber})'**
  String aboutServerInfo(String version, String buildNumber);

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

  /// No description provided for @accentPolder.
  ///
  /// In en, this message translates to:
  /// **'Polder'**
  String get accentPolder;

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

  /// No description provided for @adminOverviewHint.
  ///
  /// In en, this message translates to:
  /// **'Storage and usage at a glance'**
  String get adminOverviewHint;

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
  /// **'Polder'**
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

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @deletePermanentlyMessage.
  ///
  /// In en, this message translates to:
  /// **'It can\'t be restored afterwards.'**
  String get deletePermanentlyMessage;

  /// No description provided for @deletePermanentlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deletePermanentlyTitle(String name);

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

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrash;

  /// No description provided for @emptyTrashMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything in the trash is deleted permanently. This can\'t be undone.'**
  String get emptyTrashMessage;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty the trash?'**
  String get emptyTrashTitle;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Something with that name already exists.'**
  String get errorAlreadyExists;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'It changed since it was last loaded. Refresh and try again.'**
  String get errorConflict;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do that.'**
  String get errorForbidden;

  /// No description provided for @errorReauthenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign out and sign in again, then try once more.'**
  String get errorReauthenticationRequired;

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

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The server is busy. Try again shortly.'**
  String get errorUnavailable;

  /// No description provided for @errorPreconditionFailed.
  ///
  /// In en, this message translates to:
  /// **'It changed on the server while this was in progress.'**
  String get errorPreconditionFailed;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server ran into an error (HTTP {status}).'**
  String errorServer(String status);

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'The app ran into an unexpected error.'**
  String get errorUnknown;

  /// No description provided for @expandSidebar.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get expandSidebar;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettings;

  /// No description provided for @generalSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Trash and file versions'**
  String get generalSettingsHint;

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
  /// **'Could not reach a Polder server at this address.'**
  String get loginErrorUnreachable;

  /// No description provided for @loginServerIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of your Polder server.'**
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

  /// No description provided for @navTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get navTrash;

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

  /// No description provided for @ocrLanguagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Tesseract models, comma-separated, like eng, jpn or script/Latin'**
  String get ocrLanguagesLabel;

  /// No description provided for @ocrLanguagesSetting.
  ///
  /// In en, this message translates to:
  /// **'Languages and scripts'**
  String get ocrLanguagesSetting;

  /// No description provided for @ocrMaxPagesHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{OCR reads at most 1 page of each PDF} other{OCR reads at most {count} pages of each PDF}}'**
  String ocrMaxPagesHint(int count);

  /// No description provided for @ocrMaxPagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get ocrMaxPagesLabel;

  /// No description provided for @ocrMaxPagesSetting.
  ///
  /// In en, this message translates to:
  /// **'Pages per PDF'**
  String get ocrMaxPagesSetting;

  /// No description provided for @ocrSetting.
  ///
  /// In en, this message translates to:
  /// **'Recognise text in images and scans'**
  String get ocrSetting;

  /// No description provided for @ocrSettingHint.
  ///
  /// In en, this message translates to:
  /// **'Reads photos and scanned PDF pages with OCR. This is slow and runs in the background.'**
  String get ocrSettingHint;

  /// No description provided for @ocrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'OCR is unavailable: {reason}'**
  String ocrUnavailable(String reason);

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

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

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'There is already something at {path}. Overwrite moves it to the trash, Keep both restores this item next to it under a new name.'**
  String restoreConflictMessage(String path);

  /// No description provided for @restoreConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" already exists'**
  String restoreConflictTitle(String name);

  /// No description provided for @restoredTo.
  ///
  /// In en, this message translates to:
  /// **'Restored to {path}'**
  String restoredTo(String path);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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

  /// No description provided for @searchAddFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get searchAddFilterButton;

  /// No description provided for @searchChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get searchChooseFolder;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// No description provided for @searchContentPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file still to read} other{{count} files still to read}}'**
  String searchContentPending(int count);

  /// No description provided for @searchContentSetting.
  ///
  /// In en, this message translates to:
  /// **'Search inside files'**
  String get searchContentSetting;

  /// No description provided for @searchContentSettingHint.
  ///
  /// In en, this message translates to:
  /// **'Reads the text in documents, PDFs and images so search can find it.'**
  String get searchContentSettingHint;

  /// No description provided for @searchCustomSize.
  ///
  /// In en, this message translates to:
  /// **'Another size, like 250mb'**
  String get searchCustomSize;

  /// No description provided for @searchCustomType.
  ///
  /// In en, this message translates to:
  /// **'Another type or extension, like heic'**
  String get searchCustomType;

  /// No description provided for @searchDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String searchDaysAgo(int count);

  /// No description provided for @searchFieldFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get searchFieldFolder;

  /// No description provided for @searchFieldModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get searchFieldModified;

  /// No description provided for @searchFieldSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get searchFieldSize;

  /// No description provided for @searchFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get searchFieldType;

  /// No description provided for @searchEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String searchEventsCount(int count);

  /// No description provided for @searchMoreEvents.
  ///
  /// In en, this message translates to:
  /// **'Show more events'**
  String get searchMoreEvents;

  /// No description provided for @searchFieldCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get searchFieldCalendar;

  /// No description provided for @searchFieldRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get searchFieldRepeats;

  /// No description provided for @searchFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get searchFieldWhen;

  /// No description provided for @searchRepeatYes.
  ///
  /// In en, this message translates to:
  /// **'repeating'**
  String get searchRepeatYes;

  /// No description provided for @searchRepeatNo.
  ///
  /// In en, this message translates to:
  /// **'one-off'**
  String get searchRepeatNo;

  /// No description provided for @searchRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'daily'**
  String get searchRepeatDaily;

  /// No description provided for @searchRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'weekly'**
  String get searchRepeatWeekly;

  /// No description provided for @searchRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get searchRepeatMonthly;

  /// No description provided for @searchRepeatYearly.
  ///
  /// In en, this message translates to:
  /// **'yearly'**
  String get searchRepeatYearly;

  /// No description provided for @searchWhenUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get searchWhenUpcoming;

  /// No description provided for @searchWhenPast.
  ///
  /// In en, this message translates to:
  /// **'past'**
  String get searchWhenPast;

  /// No description provided for @searchEventPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get searchEventPast;

  /// No description provided for @searchOpenInCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open in calendar'**
  String get searchOpenInCalendar;

  /// No description provided for @searchFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String searchFilesCount(int count);

  /// No description provided for @searchFilterAdd.
  ///
  /// In en, this message translates to:
  /// **'Add filter'**
  String get searchFilterAdd;

  /// No description provided for @searchFilterValues.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get searchFilterValues;

  /// No description provided for @searchGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get searchGoTo;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search files, folders and pages'**
  String get searchHint;

  /// No description provided for @searchKeywordsAbout.
  ///
  /// In en, this message translates to:
  /// **'version, licenses, info'**
  String get searchKeywordsAbout;

  /// No description provided for @searchKeywordsActivity.
  ///
  /// In en, this message translates to:
  /// **'history, log, uploads, downloads, transfers, sessions, devices'**
  String get searchKeywordsActivity;

  /// No description provided for @searchKeywordsAdmin.
  ///
  /// In en, this message translates to:
  /// **'admin, server, administration, retention, storage, ocr, text recognition, search'**
  String get searchKeywordsAdmin;

  /// No description provided for @searchKeywordsAdminUsers.
  ///
  /// In en, this message translates to:
  /// **'accounts, people, members, quota'**
  String get searchKeywordsAdminUsers;

  /// No description provided for @searchKeywordsAutoUpload.
  ///
  /// In en, this message translates to:
  /// **'camera, photos, backup, gallery'**
  String get searchKeywordsAutoUpload;

  /// No description provided for @searchKeywordsConflicts.
  ///
  /// In en, this message translates to:
  /// **'conflict, resolve, versions'**
  String get searchKeywordsConflicts;

  /// No description provided for @searchKeywordsFiles.
  ///
  /// In en, this message translates to:
  /// **'browse, documents, home, storage'**
  String get searchKeywordsFiles;

  /// No description provided for @searchKeywordsSettings.
  ///
  /// In en, this message translates to:
  /// **'preferences, appearance, theme, account, language, password'**
  String get searchKeywordsSettings;

  /// No description provided for @searchKeywordsSync.
  ///
  /// In en, this message translates to:
  /// **'folders, desktop, mirror'**
  String get searchKeywordsSync;

  /// No description provided for @searchKeywordsTrash.
  ///
  /// In en, this message translates to:
  /// **'deleted, recycle bin, restore, bin'**
  String get searchKeywordsTrash;

  /// No description provided for @searchMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String searchMonthsAgo(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search'**
  String get searchNoResults;

  /// No description provided for @searchOpAfter.
  ///
  /// In en, this message translates to:
  /// **'after'**
  String get searchOpAfter;

  /// No description provided for @searchOpAtLeast.
  ///
  /// In en, this message translates to:
  /// **'at least'**
  String get searchOpAtLeast;

  /// No description provided for @searchOpAtMost.
  ///
  /// In en, this message translates to:
  /// **'at most'**
  String get searchOpAtMost;

  /// No description provided for @searchOpBefore.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get searchOpBefore;

  /// No description provided for @searchOpBetween.
  ///
  /// In en, this message translates to:
  /// **'between'**
  String get searchOpBetween;

  /// No description provided for @searchOpFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get searchOpFrom;

  /// No description provided for @searchOpIs.
  ///
  /// In en, this message translates to:
  /// **'is'**
  String get searchOpIs;

  /// No description provided for @searchOpIsNot.
  ///
  /// In en, this message translates to:
  /// **'is not'**
  String get searchOpIsNot;

  /// No description provided for @searchOpLarger.
  ///
  /// In en, this message translates to:
  /// **'larger than'**
  String get searchOpLarger;

  /// No description provided for @searchOpOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get searchOpOn;

  /// No description provided for @searchOpSmaller.
  ///
  /// In en, this message translates to:
  /// **'smaller than'**
  String get searchOpSmaller;

  /// No description provided for @searchOpUntil.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get searchOpUntil;

  /// No description provided for @searchPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get searchPickDate;

  /// No description provided for @searchPickRange.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get searchPickRange;

  /// No description provided for @searchPresetToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get searchPresetToday;

  /// No description provided for @searchPresetYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get searchPresetYesterday;

  /// No description provided for @searchRange.
  ///
  /// In en, this message translates to:
  /// **'{from} and {to}'**
  String searchRange(String from, String to);

  /// No description provided for @searchShowInFolder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get searchShowInFolder;

  /// No description provided for @searchSizeFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get searchSizeFrom;

  /// No description provided for @searchSizeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get searchSizeTo;

  /// No description provided for @searchSyncConflicts.
  ///
  /// In en, this message translates to:
  /// **'Sync conflicts'**
  String get searchSyncConflicts;

  /// No description provided for @searchTipsBody.
  ///
  /// In en, this message translates to:
  /// **'Type part of a name, even with typos. Add tags like type=pdf, modified>7d or size>100mb, use != to leave things out, or pick one with Filter. type=event searches your calendar, with repeats=no or when=upcoming to narrow it.'**
  String get searchTipsBody;

  /// No description provided for @searchTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow it down'**
  String get searchTipsTitle;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search ({shortcut})'**
  String searchTooltip(String shortcut);

  /// No description provided for @searchWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String searchWeeksAgo(int count);

  /// No description provided for @searchYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String searchYearsAgo(int count);

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

  /// No description provided for @serverSearchGroup.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get serverSearchGroup;

  /// No description provided for @serverSettings.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get serverSettings;

  /// No description provided for @serverSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Trash, versions, search, previews and federation'**
  String get serverSettingsHint;

  /// No description provided for @serverTrashRetention.
  ///
  /// In en, this message translates to:
  /// **'Trash retention'**
  String get serverTrashRetention;

  /// No description provided for @serverTrashRetentionHint.
  ///
  /// In en, this message translates to:
  /// **'Default and upper limit for every user: {duration}'**
  String serverTrashRetentionHint(String duration);

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

  /// No description provided for @sponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get sponsor;

  /// No description provided for @sponsorMessage.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy using Polder, consider sponsoring the project to support ongoing development and improvements. Thank you for your support!'**
  String get sponsorMessage;

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

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {date}'**
  String trashItemDeleted(String date);

  /// No description provided for @trashItemExpires.
  ///
  /// In en, this message translates to:
  /// **'Deleted permanently on {date}'**
  String trashItemExpires(String date);

  /// No description provided for @trashItemFrom.
  ///
  /// In en, this message translates to:
  /// **'From {folder}'**
  String trashItemFrom(String folder);

  /// No description provided for @trashRetention.
  ///
  /// In en, this message translates to:
  /// **'Keep deleted items'**
  String get trashRetention;

  /// No description provided for @trashRetentionDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String trashRetentionDays(int count);

  /// No description provided for @trashRetentionForever.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get trashRetentionForever;

  /// No description provided for @trashRetentionForeverHint.
  ///
  /// In en, this message translates to:
  /// **'Items stay in the trash until you delete them.'**
  String get trashRetentionForeverHint;

  /// No description provided for @trashRetentionHint.
  ///
  /// In en, this message translates to:
  /// **'Items in the trash are deleted permanently after {duration}.'**
  String trashRetentionHint(String duration);

  /// No description provided for @trashRetentionServerDefault.
  ///
  /// In en, this message translates to:
  /// **'Server default ({duration})'**
  String trashRetentionServerDefault(String duration);

  /// No description provided for @trashSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} · {size}'**
  String trashSummary(int count, String size);

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

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get uploadFiles;

  /// No description provided for @uploadHere.
  ///
  /// In en, this message translates to:
  /// **'Upload here'**
  String get uploadHere;

  /// No description provided for @uploadSharedFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Upload shared file} other{Upload {count} shared files}}'**
  String uploadSharedFiles(int count);

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

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @activityNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get activityNow;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get activityHistory;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has happened yet.'**
  String get activityEmpty;

  /// No description provided for @nothingTransferring.
  ///
  /// In en, this message translates to:
  /// **'Nothing is transferring right now.'**
  String get nothingTransferring;

  /// No description provided for @activityScopeMe.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get activityScopeMe;

  /// No description provided for @activityScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get activityScopeAll;

  /// No description provided for @activityScopeChooseUser.
  ///
  /// In en, this message translates to:
  /// **'Choose a user…'**
  String get activityScopeChooseUser;

  /// No description provided for @activityScopeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Whose activity to show'**
  String get activityScopeTooltip;

  /// No description provided for @chooseUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Show activity of'**
  String get chooseUserTitle;

  /// No description provided for @activityAllFiles.
  ///
  /// In en, this message translates to:
  /// **'All files'**
  String get activityAllFiles;

  /// No description provided for @activityKindUpload.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get activityKindUpload;

  /// No description provided for @activityKindDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get activityKindDownload;

  /// No description provided for @activityKindMkdir.
  ///
  /// In en, this message translates to:
  /// **'Created folder'**
  String get activityKindMkdir;

  /// No description provided for @activityKindMove.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get activityKindMove;

  /// No description provided for @activityKindDelete.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get activityKindDelete;

  /// No description provided for @activityKindRestore.
  ///
  /// In en, this message translates to:
  /// **'Restored from trash'**
  String get activityKindRestore;

  /// No description provided for @activityKindTrashDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted permanently'**
  String get activityKindTrashDelete;

  /// No description provided for @activityKindTrashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Emptied the trash'**
  String get activityKindTrashEmpty;

  /// No description provided for @activityKindTrashExpire.
  ///
  /// In en, this message translates to:
  /// **'Old items removed from trash'**
  String get activityKindTrashExpire;

  /// No description provided for @activityKindLogin.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get activityKindLogin;

  /// No description provided for @activityKindLogout.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get activityKindLogout;

  /// No description provided for @activityKindUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something happened'**
  String get activityKindUnknown;

  /// No description provided for @activityRescanAdded.
  ///
  /// In en, this message translates to:
  /// **'Added on the server'**
  String get activityRescanAdded;

  /// No description provided for @activityRescanChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed on the server'**
  String get activityRescanChanged;

  /// No description provided for @activityRescanRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed on the server'**
  String get activityRescanRemoved;

  /// No description provided for @activityRescanSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change} other{{count} changes}} found on the server'**
  String activityRescanSummary(int count);

  /// No description provided for @activityMovedFrom.
  ///
  /// In en, this message translates to:
  /// **'from {path}'**
  String activityMovedFrom(String path);

  /// No description provided for @activityItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String activityItemCount(int count);

  /// No description provided for @activityFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get activityFailed;

  /// No description provided for @activityCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get activityCancelled;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} s'**
  String durationSeconds(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String durationMinutes(int count);

  /// No description provided for @transferUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get transferUploading;

  /// No description provided for @transferDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get transferDownloading;

  /// No description provided for @transferProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String transferProgress(String done, String total);

  /// No description provided for @folderUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get folderUploading;

  /// No description provided for @folderDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get folderDownloading;

  /// No description provided for @realtimeOffline.
  ///
  /// In en, this message translates to:
  /// **'Live updates paused, reconnecting…'**
  String get realtimeOffline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @syncWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncWaiting;

  /// No description provided for @syncPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing to sync'**
  String get syncPreparing;

  /// No description provided for @syncPaused.
  ///
  /// In en, this message translates to:
  /// **'Sync paused'**
  String get syncPaused;

  /// No description provided for @pauseSync.
  ///
  /// In en, this message translates to:
  /// **'Pause sync'**
  String get pauseSync;

  /// No description provided for @resumeSync.
  ///
  /// In en, this message translates to:
  /// **'Resume sync'**
  String get resumeSync;

  /// No description provided for @itemPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get itemPaused;

  /// No description provided for @nowGroupFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String nowGroupFiles(int count);

  /// No description provided for @nowGroupProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} files'**
  String nowGroupProgress(int done, int total);

  /// No description provided for @nowGroupUploading.
  ///
  /// In en, this message translates to:
  /// **'{count} uploading'**
  String nowGroupUploading(int count);

  /// No description provided for @nowGroupDownloading.
  ///
  /// In en, this message translates to:
  /// **'{count} downloading'**
  String nowGroupDownloading(int count);

  /// No description provided for @nowGroupPreparing.
  ///
  /// In en, this message translates to:
  /// **'{count} preparing'**
  String nowGroupPreparing(int count);

  /// No description provided for @nowGroupWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String nowGroupWaiting(int count);

  /// No description provided for @showFiles.
  ///
  /// In en, this message translates to:
  /// **'Show files'**
  String get showFiles;

  /// No description provided for @hideFiles.
  ///
  /// In en, this message translates to:
  /// **'Hide files'**
  String get hideFiles;

  /// No description provided for @uploadExistingFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload existing files'**
  String get uploadExistingFiles;

  /// No description provided for @uploadExistingFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Otherwise only files added from now on are uploaded'**
  String get uploadExistingFilesHint;

  /// No description provided for @storageAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Polder needs access to your files to upload this folder. Allow all files access, or at least photos and videos, in the app settings.'**
  String get storageAccessDenied;

  /// No description provided for @folderWillBeCreated.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t exist yet. It will be created.'**
  String get folderWillBeCreated;

  /// No description provided for @trayUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get trayUpToDate;

  /// No description provided for @traySyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get traySyncing;

  /// No description provided for @traySyncingFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Syncing 1 file} other{Syncing {count} files}}'**
  String traySyncingFiles(int count);

  /// No description provided for @traySyncPaused.
  ///
  /// In en, this message translates to:
  /// **'Sync paused'**
  String get traySyncPaused;

  /// No description provided for @traySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get traySyncFailed;

  /// No description provided for @traySignedOut.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get traySignedOut;

  /// No description provided for @trayOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Polder'**
  String get trayOpenApp;

  /// No description provided for @trayOpenSyncedFolders.
  ///
  /// In en, this message translates to:
  /// **'Open synced folders'**
  String get trayOpenSyncedFolders;

  /// No description provided for @trayOpenFiles.
  ///
  /// In en, this message translates to:
  /// **'Open files'**
  String get trayOpenFiles;

  /// No description provided for @trayOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get trayOpenCalendar;

  /// No description provided for @trayOpenNotes.
  ///
  /// In en, this message translates to:
  /// **'Open notes'**
  String get trayOpenNotes;

  /// No description provided for @trayQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit Polder'**
  String get trayQuit;

  /// No description provided for @trayNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get trayNew;

  /// No description provided for @shortcutNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get shortcutNewNote;

  /// No description provided for @shortcutEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get shortcutEvent;

  /// No description provided for @shortcutChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get shortcutChecklist;

  /// No description provided for @shortcutSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get shortcutSearch;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @quitWhileSyncingTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit while syncing?'**
  String get quitWhileSyncingTitle;

  /// No description provided for @quitWhileSyncingMessage.
  ///
  /// In en, this message translates to:
  /// **'Polder is still syncing. Unfinished transfers continue the next time you open Polder.'**
  String get quitWhileSyncingMessage;

  /// No description provided for @newDocument.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get newDocument;

  /// No description provided for @reviewScan.
  ///
  /// In en, this message translates to:
  /// **'Review scan'**
  String get reviewScan;

  /// No description provided for @addPages.
  ///
  /// In en, this message translates to:
  /// **'Add pages'**
  String get addPages;

  /// No description provided for @removePage.
  ///
  /// In en, this message translates to:
  /// **'Remove page'**
  String get removePage;

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// No description provided for @scanFormatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get scanFormatPdf;

  /// No description provided for @scanFormatImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get scanFormatImages;

  /// No description provided for @scanSaveTo.
  ///
  /// In en, this message translates to:
  /// **'Save to'**
  String get scanSaveTo;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this scan?'**
  String get discardScanTitle;

  /// No description provided for @discardScanMessage.
  ///
  /// In en, this message translates to:
  /// **'The scanned pages won\'t be saved.'**
  String get discardScanMessage;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t scan the document.'**
  String get scanFailed;

  /// No description provided for @scanCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan documents.'**
  String get scanCameraDenied;

  /// No description provided for @scanCameraOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanCameraOpenSettings;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @sortFoldersFirst.
  ///
  /// In en, this message translates to:
  /// **'Folders on top'**
  String get sortFoldersFirst;

  /// No description provided for @indexingBanner.
  ///
  /// In en, this message translates to:
  /// **'Indexing… folders fill in as files are found.'**
  String get indexingBanner;

  /// No description provided for @indexingEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Still indexing. Files appear here as they\'re found.'**
  String get indexingEmptyFolder;

  /// No description provided for @serverLogs.
  ///
  /// In en, this message translates to:
  /// **'Server logs'**
  String get serverLogs;

  /// No description provided for @serverLogsHint.
  ///
  /// In en, this message translates to:
  /// **'What the server did and every error it ran into'**
  String get serverLogsHint;

  /// No description provided for @logLevelDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get logLevelDebug;

  /// No description provided for @logLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get logLevelInfo;

  /// No description provided for @logLevelWarn.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get logLevelWarn;

  /// No description provided for @logLevelError.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get logLevelError;

  /// No description provided for @logMinimumLevel.
  ///
  /// In en, this message translates to:
  /// **'Minimum level'**
  String get logMinimumLevel;

  /// No description provided for @logComponent.
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get logComponent;

  /// No description provided for @logAllComponents.
  ///
  /// In en, this message translates to:
  /// **'All components'**
  String get logAllComponents;

  /// No description provided for @logSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages and details'**
  String get logSearchHint;

  /// No description provided for @logFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow new entries'**
  String get logFollow;

  /// No description provided for @logStopFollowing.
  ///
  /// In en, this message translates to:
  /// **'Stop following'**
  String get logStopFollowing;

  /// No description provided for @logDownload.
  ///
  /// In en, this message translates to:
  /// **'Download log file'**
  String get logDownload;

  /// No description provided for @logNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No log files yet.'**
  String get logNoFiles;

  /// No description provided for @logsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No log entries match.'**
  String get logsEmpty;

  /// No description provided for @editorOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in editor'**
  String get editorOpen;

  /// No description provided for @editorSaved.
  ///
  /// In en, this message translates to:
  /// **'All changes saved'**
  String get editorSaved;

  /// No description provided for @editorSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editorSaving;

  /// No description provided for @editorUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get editorUnsaved;

  /// No description provided for @editorReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get editorReadOnly;

  /// No description provided for @editorSaveFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes not saved'**
  String get editorSaveFailedTitle;

  /// No description provided for @editorSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your changes could not be saved to the server. Leave anyway and lose them?'**
  String get editorSaveFailedMessage;

  /// No description provided for @editorLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave anyway'**
  String get editorLeave;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @documentKind.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentKind;

  /// No description provided for @spreadsheetKind.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get spreadsheetKind;

  /// No description provided for @presentationKind.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get presentationKind;

  /// No description provided for @newSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'New spreadsheet'**
  String get newSpreadsheet;

  /// No description provided for @newPresentation.
  ///
  /// In en, this message translates to:
  /// **'New presentation'**
  String get newPresentation;

  /// No description provided for @pdfKind.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfKind;

  /// No description provided for @newPdf.
  ///
  /// In en, this message translates to:
  /// **'New PDF'**
  String get newPdf;

  /// No description provided for @brandingGroup.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get brandingGroup;

  /// No description provided for @serverName.
  ///
  /// In en, this message translates to:
  /// **'Server name'**
  String get serverName;

  /// No description provided for @serverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on the login screen, in the sidebar and as the window title'**
  String get serverNameHint;

  /// No description provided for @brandingDefault.
  ///
  /// In en, this message translates to:
  /// **'{value} (default)'**
  String brandingDefault(String value);

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome message'**
  String get welcomeMessage;

  /// No description provided for @welcomeMessageNone.
  ///
  /// In en, this message translates to:
  /// **'Not shown'**
  String get welcomeMessageNone;

  /// No description provided for @brandingAccent.
  ///
  /// In en, this message translates to:
  /// **'Default accent color'**
  String get brandingAccent;

  /// No description provided for @brandingAccentHint.
  ///
  /// In en, this message translates to:
  /// **'Used unless someone picks their own accent color'**
  String get brandingAccentHint;

  /// No description provided for @appDefault.
  ///
  /// In en, this message translates to:
  /// **'App default'**
  String get appDefault;

  /// No description provided for @hexColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color as #RRGGBB'**
  String get hexColorLabel;

  /// No description provided for @serverIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get serverIcon;

  /// No description provided for @serverIconHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on the login screen and in the sidebar'**
  String get serverIconHint;

  /// No description provided for @loginBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Login backgrounds'**
  String get loginBackgrounds;

  /// No description provided for @loginBackgroundsHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None; images you add are shown in turn behind the login screen} =1{1 image} other{{count} images, shown in turn}}'**
  String loginBackgroundsHint(int count);

  /// No description provided for @brandingHint.
  ///
  /// In en, this message translates to:
  /// **'Name, colors, icon and login screen'**
  String get brandingHint;

  /// No description provided for @brandingIdentityGroup.
  ///
  /// In en, this message translates to:
  /// **'Name and colors'**
  String get brandingIdentityGroup;

  /// No description provided for @brandingImagesGroup.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get brandingImagesGroup;

  /// No description provided for @imageFromDevice.
  ///
  /// In en, this message translates to:
  /// **'From this device'**
  String get imageFromDevice;

  /// No description provided for @imageFromFiles.
  ///
  /// In en, this message translates to:
  /// **'From your files'**
  String get imageFromFiles;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose an image'**
  String get chooseImage;

  /// No description provided for @chooseImages.
  ///
  /// In en, this message translates to:
  /// **'Choose images'**
  String get chooseImages;

  /// No description provided for @noImagesInFolder.
  ///
  /// In en, this message translates to:
  /// **'No images or folders here'**
  String get noImagesInFolder;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add} other{Add {count}}}'**
  String addSelected(int count);

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get versionHistory;

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get versions;

  /// No description provided for @versionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None yet} =1{1 earlier version} other{{count} earlier versions}}'**
  String versionCount(int count);

  /// No description provided for @versionCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get versionCurrent;

  /// No description provided for @versionHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No earlier versions yet. When this file is saved over, the previous content is kept here.'**
  String get versionHistoryEmpty;

  /// No description provided for @versionHistoryOff.
  ///
  /// In en, this message translates to:
  /// **'Version history is turned off, so earlier versions aren\'t kept.'**
  String get versionHistoryOff;

  /// No description provided for @versionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get versionView;

  /// No description provided for @versionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get versionRestore;

  /// No description provided for @versionRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this version?'**
  String get versionRestoreTitle;

  /// No description provided for @versionRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'The current content is kept as a version, so you can go back to it.'**
  String get versionRestoreMessage;

  /// No description provided for @versionRestored.
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get versionRestored;

  /// No description provided for @versionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this version?'**
  String get versionDeleteTitle;

  /// No description provided for @versionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This version is deleted permanently.'**
  String get versionDeleteMessage;

  /// No description provided for @versionViewing.
  ///
  /// In en, this message translates to:
  /// **'Version from {date}, read only'**
  String versionViewing(String date);

  /// No description provided for @versionBackToCurrent.
  ///
  /// In en, this message translates to:
  /// **'Back to current'**
  String get versionBackToCurrent;

  /// No description provided for @versionsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep earlier versions'**
  String get versionsKeep;

  /// No description provided for @versionsKeepHint.
  ///
  /// In en, this message translates to:
  /// **'When a file is saved over, its previous content is kept. Versions count towards your storage.'**
  String get versionsKeepHint;

  /// No description provided for @versionsPerFile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No limit per file} =1{1 per file} other{{count} per file}}'**
  String versionsPerFile(int count);

  /// No description provided for @versionsMaxPerFile.
  ///
  /// In en, this message translates to:
  /// **'Versions per file'**
  String get versionsMaxPerFile;

  /// No description provided for @versionsMaxPerFileHint.
  ///
  /// In en, this message translates to:
  /// **'The server allows at most {limit}.'**
  String versionsMaxPerFileHint(String limit);

  /// No description provided for @versionsMaxAge.
  ///
  /// In en, this message translates to:
  /// **'Keep versions for'**
  String get versionsMaxAge;

  /// No description provided for @versionsFollowServer.
  ///
  /// In en, this message translates to:
  /// **'Follow the server'**
  String get versionsFollowServer;

  /// No description provided for @versionsTurnOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off version history?'**
  String get versionsTurnOffTitle;

  /// No description provided for @versionsTurnOffMessage.
  ///
  /// In en, this message translates to:
  /// **'All earlier versions of your files are deleted permanently.'**
  String get versionsTurnOffMessage;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @versionsTurnedOffByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Turned off by your administrator'**
  String get versionsTurnedOffByAdmin;

  /// No description provided for @versionsKeepAllHint.
  ///
  /// In en, this message translates to:
  /// **'The server allows at most {limit}.'**
  String versionsKeepAllHint(String limit);

  /// No description provided for @trashKeep.
  ///
  /// In en, this message translates to:
  /// **'Move deleted items to the trash'**
  String get trashKeep;

  /// No description provided for @trashKeepHint.
  ///
  /// In en, this message translates to:
  /// **'Deleted items can be restored until the trash is emptied. Off deletes them permanently.'**
  String get trashKeepHint;

  /// No description provided for @trashTurnedOffByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Turned off by your administrator. Deleted items are removed permanently.'**
  String get trashTurnedOffByAdmin;

  /// No description provided for @trashTurnOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off the trash?'**
  String get trashTurnOffTitle;

  /// No description provided for @trashTurnOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything in your trash is deleted permanently, and from now on deleting can\'t be undone.'**
  String get trashTurnOffMessage;

  /// No description provided for @serverTrashEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Turning this off empties every user\'s trash and makes deleting permanent.'**
  String get serverTrashEnabledHint;

  /// No description provided for @serverTrashTurnOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Every user\'s trash is emptied permanently, and from now on deleting can\'t be undone.'**
  String get serverTrashTurnOffMessage;

  /// No description provided for @serverVersionsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Keep earlier versions'**
  String get serverVersionsEnabled;

  /// No description provided for @serverVersionsEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Only changes made through Polder are kept. Turning this off deletes all history.'**
  String get serverVersionsEnabledHint;

  /// No description provided for @serverVersionsTurnOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Earlier versions of every user\'s files are deleted permanently, and no new ones are kept.'**
  String get serverVersionsTurnOffMessage;

  /// No description provided for @versionsKeepAll.
  ///
  /// In en, this message translates to:
  /// **'Keep every save for'**
  String get versionsKeepAll;

  /// No description provided for @serverVersionsKeepAllHint.
  ///
  /// In en, this message translates to:
  /// **'After this, versions thin out: about one per hour after a day, fewer as they age.'**
  String get serverVersionsKeepAllHint;

  /// No description provided for @versionsHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Don\'t keep every save} =1{1 hour} other{{count} hours}}'**
  String versionsHours(int count);

  /// No description provided for @versionsHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get versionsHoursLabel;

  /// No description provided for @serverVersionsMaxAge.
  ///
  /// In en, this message translates to:
  /// **'Keep versions for'**
  String get serverVersionsMaxAge;

  /// No description provided for @serverVersionsMaxPerFile.
  ///
  /// In en, this message translates to:
  /// **'Versions per file'**
  String get serverVersionsMaxPerFile;

  /// No description provided for @serverVersionsLimitHint.
  ///
  /// In en, this message translates to:
  /// **'Default and upper limit for every user'**
  String get serverVersionsLimitHint;

  /// No description provided for @quotaHistory.
  ///
  /// In en, this message translates to:
  /// **'{size} of that is version history'**
  String quotaHistory(String size);

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @searchKeywordsCalendar.
  ///
  /// In en, this message translates to:
  /// **'calendar, agenda, events, appointments, schedule, meetings'**
  String get searchKeywordsCalendar;

  /// No description provided for @searchKeywordsNotes.
  ///
  /// In en, this message translates to:
  /// **'notes, markdown, wiki, knowledge base, pages, journal'**
  String get searchKeywordsNotes;

  /// No description provided for @notesSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up notes'**
  String get notesSetupTitle;

  /// No description provided for @notesSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Notes are markdown files in a folder of your choice. Pick a name for the folder; it\'s created if it doesn\'t exist yet.'**
  String get notesSetupMessage;

  /// No description provided for @notesFolder.
  ///
  /// In en, this message translates to:
  /// **'Notes folder'**
  String get notesFolder;

  /// No description provided for @notesDefaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesDefaultFolder;

  /// No description provided for @notesSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get notesSetUp;

  /// No description provided for @notesFolderIsFile.
  ///
  /// In en, this message translates to:
  /// **'That\'s a file, not a folder.'**
  String get notesFolderIsFile;

  /// No description provided for @notesFolderExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder already exists'**
  String get notesFolderExistsTitle;

  /// No description provided for @notesFolderExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'{path} already exists. Use it as your notes folder? The markdown files in it become pages.'**
  String notesFolderExistsMessage(String path);

  /// No description provided for @notesUseExistingFolder.
  ///
  /// In en, this message translates to:
  /// **'Use this folder'**
  String get notesUseExistingFolder;

  /// No description provided for @notesChooseAnotherName.
  ///
  /// In en, this message translates to:
  /// **'Choose another name'**
  String get notesChooseAnotherName;

  /// No description provided for @notesChangeFolder.
  ///
  /// In en, this message translates to:
  /// **'Change notes folder'**
  String get notesChangeFolder;

  /// No description provided for @notesEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'No pages yet.'**
  String get notesEmptyFolder;

  /// No description provided for @notesMoveToTop.
  ///
  /// In en, this message translates to:
  /// **'Drop here to move to the top level'**
  String get notesMoveToTop;

  /// No description provided for @notesNothingOpenMessage.
  ///
  /// In en, this message translates to:
  /// **'Pick a page on the left, or start a new one.'**
  String get notesNothingOpenMessage;

  /// No description provided for @noteNewPage.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get noteNewPage;

  /// No description provided for @noteNewSubpage.
  ///
  /// In en, this message translates to:
  /// **'New subpage'**
  String get noteNewSubpage;

  /// No description provided for @noteNewChecklist.
  ///
  /// In en, this message translates to:
  /// **'New checklist'**
  String get noteNewChecklist;

  /// No description provided for @noteListItem.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get noteListItem;

  /// No description provided for @noteRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get noteRemoveItem;

  /// No description provided for @noteCheckedItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 checked item} other{{count} checked items}}'**
  String noteCheckedItems(int count);

  /// No description provided for @noteShowCheckboxes.
  ///
  /// In en, this message translates to:
  /// **'Show checkboxes'**
  String get noteShowCheckboxes;

  /// No description provided for @noteHideCheckboxes.
  ///
  /// In en, this message translates to:
  /// **'Hide checkboxes'**
  String get noteHideCheckboxes;

  /// No description provided for @noteSubpages.
  ///
  /// In en, this message translates to:
  /// **'Subpages'**
  String get noteSubpages;

  /// No description provided for @noteCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get noteCollapse;

  /// No description provided for @noteExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get noteExpand;

  /// No description provided for @notesUpOneLevel.
  ///
  /// In en, this message translates to:
  /// **'Up one level'**
  String get notesUpOneLevel;

  /// No description provided for @noteNewNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteNewNote;

  /// No description provided for @noteDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteDefaultName;

  /// No description provided for @noteMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get noteMove;

  /// No description provided for @noteShowInFiles.
  ///
  /// In en, this message translates to:
  /// **'Show in files'**
  String get noteShowInFiles;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}?'**
  String noteDeleteTitle(String title);

  /// No description provided for @noteDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The page goes to the trash.'**
  String get noteDeleteMessage;

  /// No description provided for @noteDeleteWithChildrenMessage.
  ///
  /// In en, this message translates to:
  /// **'The page and its subpages go to the trash.'**
  String get noteDeleteWithChildrenMessage;

  /// No description provided for @noteDeleteManyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} pages?'**
  String noteDeleteManyTitle(int count);

  /// No description provided for @noteDeleteManyMessage.
  ///
  /// In en, this message translates to:
  /// **'The pages and any subpages go to the trash.'**
  String get noteDeleteManyMessage;

  /// No description provided for @noteSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get noteSelect;

  /// No description provided for @noteUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes; save now'**
  String get noteUnsaved;

  /// No description provided for @noteSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get noteSaving;

  /// No description provided for @noteLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get noteLivePreview;

  /// No description provided for @noteSourceMode.
  ///
  /// In en, this message translates to:
  /// **'Source mode'**
  String get noteSourceMode;

  /// No description provided for @noteLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get noteLinks;

  /// No description provided for @noteBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get noteBack;

  /// No description provided for @noteForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get noteForward;

  /// No description provided for @noteLinkedFrom.
  ///
  /// In en, this message translates to:
  /// **'Linked from'**
  String get noteLinkedFrom;

  /// No description provided for @noteLinksTo.
  ///
  /// In en, this message translates to:
  /// **'Links to'**
  String get noteLinksTo;

  /// No description provided for @noteNoBacklinks.
  ///
  /// In en, this message translates to:
  /// **'Nothing links here yet.'**
  String get noteNoBacklinks;

  /// No description provided for @noteNoLinks.
  ///
  /// In en, this message translates to:
  /// **'This note doesn\'t link to anything.'**
  String get noteNoLinks;

  /// No description provided for @noteBrokenLink.
  ///
  /// In en, this message translates to:
  /// **'Not found: {path}'**
  String noteBrokenLink(String path);

  /// No description provided for @noteLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'The linked file no longer exists.'**
  String get noteLinkMissing;

  /// No description provided for @noteLinkSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get noteLinkSearch;

  /// No description provided for @noteLinkBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get noteLinkBrowse;

  /// No description provided for @noteLinkThisFolder.
  ///
  /// In en, this message translates to:
  /// **'Link to this folder'**
  String get noteLinkThisFolder;

  /// No description provided for @noteNotText.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t plain UTF-8 text, so it can\'t be edited here.'**
  String get noteNotText;

  /// No description provided for @noteDraftFound.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes from {time} were found on this device.'**
  String noteDraftFound(String time);

  /// No description provided for @noteDraftFoundChanged.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes from {time} were found, but the note has changed since.'**
  String noteDraftFoundChanged(String time);

  /// No description provided for @noteRecoverDraft.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get noteRecoverDraft;

  /// No description provided for @noteDiscardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get noteDiscardDraft;

  /// No description provided for @noteConflict.
  ///
  /// In en, this message translates to:
  /// **'This note was changed somewhere else.'**
  String get noteConflict;

  /// No description provided for @noteConflictTheirs.
  ///
  /// In en, this message translates to:
  /// **'Use theirs'**
  String get noteConflictTheirs;

  /// No description provided for @noteConflictMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get noteConflictMine;

  /// No description provided for @noteConflictCopy.
  ///
  /// In en, this message translates to:
  /// **'Save mine as copy'**
  String get noteConflictCopy;

  /// No description provided for @copySuffix.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copySuffix;

  /// No description provided for @noteUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get noteUndo;

  /// No description provided for @noteRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get noteRedo;

  /// No description provided for @noteHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get noteHeading;

  /// No description provided for @noteHeadingLevel.
  ///
  /// In en, this message translates to:
  /// **'Heading {level}'**
  String noteHeadingLevel(int level);

  /// No description provided for @noteParagraph.
  ///
  /// In en, this message translates to:
  /// **'Normal text'**
  String get noteParagraph;

  /// No description provided for @noteBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get noteBold;

  /// No description provided for @noteItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get noteItalic;

  /// No description provided for @noteStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get noteStrikethrough;

  /// No description provided for @noteInlineCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get noteInlineCode;

  /// No description provided for @noteBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get noteBulletList;

  /// No description provided for @noteNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get noteNumberedList;

  /// No description provided for @noteTaskList.
  ///
  /// In en, this message translates to:
  /// **'Task list'**
  String get noteTaskList;

  /// No description provided for @noteQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get noteQuote;

  /// No description provided for @noteCallout.
  ///
  /// In en, this message translates to:
  /// **'Callout'**
  String get noteCallout;

  /// No description provided for @noteCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code block'**
  String get noteCodeBlock;

  /// No description provided for @noteTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get noteTable;

  /// No description provided for @noteDivider.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get noteDivider;

  /// No description provided for @noteLinkFile.
  ///
  /// In en, this message translates to:
  /// **'Link a file or note'**
  String get noteLinkFile;

  /// No description provided for @noteAttachFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get noteAttachFiles;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @accountSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Your name, picture and appearance'**
  String get accountSettingsHint;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Shown instead of your first name'**
  String get displayNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @userIcon.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get userIcon;

  /// No description provided for @userIconHint.
  ///
  /// In en, this message translates to:
  /// **'Without a picture, your initials are shown'**
  String get userIconHint;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @deleteItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 item?} other{Delete {count} items?}}'**
  String deleteItemsTitle(int count);

  /// No description provided for @deletePermanentlyItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 item permanently?} other{Delete {count} items permanently?}}'**
  String deletePermanentlyItemsTitle(int count);

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @moveEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" to…'**
  String moveEntryTitle(String name);

  /// No description provided for @moveItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 item to…} other{Move {count} items to…}}'**
  String moveItemsTitle(int count);

  /// No description provided for @moveHere.
  ///
  /// In en, this message translates to:
  /// **'Move here'**
  String get moveHere;

  /// No description provided for @copyEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy \"{name}\" to…'**
  String copyEntryTitle(String name);

  /// No description provided for @copyItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copy 1 item to…} other{Copy {count} items to…}}'**
  String copyItemsTitle(int count);

  /// No description provided for @copyHere.
  ///
  /// In en, this message translates to:
  /// **'Copy here'**
  String get copyHere;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDoNotMatch;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your other devices are signed out after the change.'**
  String get changePasswordHint;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @usernameRequirements.
  ///
  /// In en, this message translates to:
  /// **'2–32 characters: lowercase letters, digits, \'.\', \'_\' or \'-\', starting with a letter or digit'**
  String get usernameRequirements;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordRequirements(int count);

  /// No description provided for @navShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get navShared;

  /// No description provided for @searchKeywordsShared.
  ///
  /// In en, this message translates to:
  /// **'shared share links people groups'**
  String get searchKeywordsShared;

  /// No description provided for @sharedWithMe.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get sharedWithMe;

  /// No description provided for @sharedByMe.
  ///
  /// In en, this message translates to:
  /// **'Shared by me'**
  String get sharedByMe;

  /// No description provided for @shareLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get shareLinks;

  /// No description provided for @noIncomingShares.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been shared with you yet'**
  String get noIncomingShares;

  /// No description provided for @noOutgoingShares.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t shared anything yet'**
  String get noOutgoingShares;

  /// No description provided for @noShareLinks.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any links yet'**
  String get noShareLinks;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share {name}'**
  String shareTitle(String name);

  /// No description provided for @shareRecipients.
  ///
  /// In en, this message translates to:
  /// **'Shared with'**
  String get shareRecipients;

  /// No description provided for @shareSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Add people or groups'**
  String get shareSearchHint;

  /// No description provided for @shareNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No people or groups found'**
  String get shareNoMatches;

  /// No description provided for @sharePermissionRead.
  ///
  /// In en, this message translates to:
  /// **'Can view'**
  String get sharePermissionRead;

  /// No description provided for @sharePermissionWrite.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get sharePermissionWrite;

  /// No description provided for @shareNotSharedYet.
  ///
  /// In en, this message translates to:
  /// **'Not shared with anyone yet'**
  String get shareNotSharedYet;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String sharedBy(String name);

  /// No description provided for @shareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In the trash'**
  String get shareUnavailable;

  /// No description provided for @shareLeave.
  ///
  /// In en, this message translates to:
  /// **'Remove from my shared items'**
  String get shareLeave;

  /// No description provided for @shareDetailsOwner.
  ///
  /// In en, this message translates to:
  /// **'Shared by'**
  String get shareDetailsOwner;

  /// No description provided for @shareDetailsGroups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Group} other{Groups}}'**
  String shareDetailsGroups(int count);

  /// No description provided for @shareDetailsAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get shareDetailsAccess;

  /// No description provided for @shareDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get shareDetailsNote;

  /// No description provided for @shareStop.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get shareStop;

  /// No description provided for @shareGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String shareGroupMembers(int count);

  /// No description provided for @createLink.
  ///
  /// In en, this message translates to:
  /// **'Create link'**
  String get createLink;

  /// No description provided for @editLink.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get editLink;

  /// No description provided for @linkAccess.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can'**
  String get linkAccess;

  /// No description provided for @linkCanView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get linkCanView;

  /// No description provided for @linkCanViewHint.
  ///
  /// In en, this message translates to:
  /// **'Browse the files and see previews'**
  String get linkCanViewHint;

  /// No description provided for @linkCanDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get linkCanDownload;

  /// No description provided for @linkCanDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'Save files and folders to their device'**
  String get linkCanDownloadHint;

  /// No description provided for @linkCanUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get linkCanUpload;

  /// No description provided for @linkCanUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Add files to this folder; existing files are never replaced'**
  String get linkCanUploadHint;

  /// No description provided for @linkPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get linkPassword;

  /// No description provided for @linkPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no password'**
  String get linkPasswordHint;

  /// No description provided for @linkPasswordKeep.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the current password'**
  String get linkPasswordKeep;

  /// No description provided for @linkPasswordSet.
  ///
  /// In en, this message translates to:
  /// **'Password protected'**
  String get linkPasswordSet;

  /// No description provided for @linkRemovePassword.
  ///
  /// In en, this message translates to:
  /// **'Remove password'**
  String get linkRemovePassword;

  /// No description provided for @linkExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get linkExpiry;

  /// No description provided for @linkNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'Never expires'**
  String get linkNoExpiry;

  /// No description provided for @linkExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String linkExpiresOn(String date);

  /// No description provided for @linkExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get linkExpired;

  /// No description provided for @linkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get linkCopy;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @deleteLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete link?'**
  String get deleteLinkTitle;

  /// No description provided for @deleteLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'The link stops working right away for everyone who has it.'**
  String get deleteLinkMessage;

  /// No description provided for @publicShareLocked.
  ///
  /// In en, this message translates to:
  /// **'This link is password protected'**
  String get publicShareLocked;

  /// No description provided for @publicShareUnlock.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get publicShareUnlock;

  /// No description provided for @publicShareWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get publicShareWrongPassword;

  /// No description provided for @publicShareRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a minute.'**
  String get publicShareRateLimited;

  /// No description provided for @publicShareNotFound.
  ///
  /// In en, this message translates to:
  /// **'This link doesn\'t exist or has expired'**
  String get publicShareNotFound;

  /// No description provided for @publicShareUploadOnly.
  ///
  /// In en, this message translates to:
  /// **'Files you upload here go to {name}. You can\'t see what\'s already there.'**
  String publicShareUploadOnly(String name);

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get downloadAll;

  /// No description provided for @openInApp.
  ///
  /// In en, this message translates to:
  /// **'Open in app'**
  String get openInApp;

  /// No description provided for @openInPolder.
  ///
  /// In en, this message translates to:
  /// **'Open in Polder'**
  String get openInPolder;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @renameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get renameGroup;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get deleteGroupTitle;

  /// No description provided for @deleteGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is deleted and anything shared with it is no longer shared.'**
  String deleteGroupMessage(String name);

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembers;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroups;

  /// No description provided for @filterUsers.
  ///
  /// In en, this message translates to:
  /// **'Filter users'**
  String get filterUsers;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get myGroups;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All groups'**
  String get allGroups;

  /// No description provided for @groupRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupRoleAdmin;

  /// No description provided for @groupRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupRoleMember;

  /// No description provided for @groupRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get groupRoleViewer;

  /// No description provided for @groupRoleAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Manages members and can remove anything shared with the group'**
  String get groupRoleAdminHint;

  /// No description provided for @groupRoleMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Can share with the group'**
  String get groupRoleMemberHint;

  /// No description provided for @groupRoleViewerHint.
  ///
  /// In en, this message translates to:
  /// **'Can only view what is shared with the group'**
  String get groupRoleViewerHint;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String leaveGroupTitle(String name);

  /// No description provided for @leaveGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see what is shared with this group, and what you shared with it is no longer shared.'**
  String get leaveGroupMessage;

  /// No description provided for @leaveGroupAloneMessage.
  ///
  /// In en, this message translates to:
  /// **'You are the only member of {name}. Leaving deletes the group, and anything shared with it is no longer shared.'**
  String leaveGroupAloneMessage(String name);

  /// No description provided for @leaveAndDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave and delete'**
  String get leaveAndDeleteGroup;

  /// No description provided for @leaveGroupLastAdminMessage.
  ///
  /// In en, this message translates to:
  /// **'You are the last admin of {name}. Make someone else an admin before you leave, or delete the group.'**
  String leaveGroupLastAdminMessage(String name);

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get removeMember;

  /// No description provided for @groupShared.
  ///
  /// In en, this message translates to:
  /// **'Shared with this group'**
  String get groupShared;

  /// No description provided for @noGroupShares.
  ///
  /// In en, this message translates to:
  /// **'Nothing is shared with this group yet'**
  String get noGroupShares;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select a group or create one'**
  String get selectGroup;

  /// No description provided for @searchKeywordsGroups.
  ///
  /// In en, this message translates to:
  /// **'groups teams members roles'**
  String get searchKeywordsGroups;

  /// No description provided for @groupCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String groupCreatedBy(String name);

  /// No description provided for @sharePermissionCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom permissions'**
  String get sharePermissionCustom;

  /// No description provided for @sharePermView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get sharePermView;

  /// No description provided for @sharePermCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get sharePermCreate;

  /// No description provided for @sharePermEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sharePermEdit;

  /// No description provided for @sharePermDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sharePermDelete;

  /// No description provided for @shareNote.
  ///
  /// In en, this message translates to:
  /// **'Note to recipient'**
  String get shareNote;

  /// No description provided for @shareNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to them together with the share'**
  String get shareNoteHint;

  /// No description provided for @nothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Choose something on the left'**
  String get nothingSelected;

  /// No description provided for @sharedByWithPermission.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name} · {permission}'**
  String sharedByWithPermission(String name, String permission);

  /// No description provided for @shareWithName.
  ///
  /// In en, this message translates to:
  /// **'Share with {name}'**
  String shareWithName(String name);

  /// No description provided for @sharedWithName.
  ///
  /// In en, this message translates to:
  /// **'Shared with {name}'**
  String sharedWithName(String name);

  /// No description provided for @finderLocationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on Polder in System Settings › General › Login Items & Extensions › File Providers to see your files in Finder.'**
  String get finderLocationDisabled;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get openSystemSettings;

  /// No description provided for @startup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get startup;

  /// No description provided for @launchAtLogin.
  ///
  /// In en, this message translates to:
  /// **'Open at login'**
  String get launchAtLogin;

  /// No description provided for @launchAtLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Start Polder automatically when you sign in to your computer'**
  String get launchAtLoginHint;

  /// No description provided for @launchMinimized.
  ///
  /// In en, this message translates to:
  /// **'Start minimized'**
  String get launchMinimized;

  /// No description provided for @launchMinimizedHint.
  ///
  /// In en, this message translates to:
  /// **'Run in the background at login without opening the window'**
  String get launchMinimizedHint;

  /// No description provided for @showInFinder.
  ///
  /// In en, this message translates to:
  /// **'Show in Finder'**
  String get showInFinder;

  /// No description provided for @showInFinderHint.
  ///
  /// In en, this message translates to:
  /// **'Browse your files in Finder; they download when you open them'**
  String get showInFinderHint;

  /// No description provided for @finderRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Finder?'**
  String get finderRemoveTitle;

  /// No description provided for @finderRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Files downloaded for offline use are removed from this Mac. They stay on the server.'**
  String get finderRemoveMessage;

  /// No description provided for @finderHandedOffToDrive.
  ///
  /// In en, this message translates to:
  /// **'Polder Drive shows your files in Finder. You can change this in Polder Drive.'**
  String get finderHandedOffToDrive;

  /// No description provided for @filesAppHandedOffToDrive.
  ///
  /// In en, this message translates to:
  /// **'Polder Drive shows your files in the Files app. You can change this in Polder Drive.'**
  String get filesAppHandedOffToDrive;

  /// No description provided for @showInFilesApp.
  ///
  /// In en, this message translates to:
  /// **'Show in Files'**
  String get showInFilesApp;

  /// No description provided for @showInFilesAppHint.
  ///
  /// In en, this message translates to:
  /// **'Open and save Polder files from other apps through the Files app'**
  String get showInFilesAppHint;

  /// No description provided for @filesAppRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Files?'**
  String get filesAppRemoveTitle;

  /// No description provided for @filesAppRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Other apps can no longer open or save files in Polder. Your files stay on the server.'**
  String get filesAppRemoveMessage;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @appPasswords.
  ///
  /// In en, this message translates to:
  /// **'App passwords'**
  String get appPasswords;

  /// No description provided for @appPasswordsHint.
  ///
  /// In en, this message translates to:
  /// **'WebDAV and CalDAV apps such as Finder, Explorer, rclone and Apple Calendar log in with your username and an app password. Your account password does not work there.'**
  String get appPasswordsHint;

  /// No description provided for @createAppPassword.
  ///
  /// In en, this message translates to:
  /// **'Create app password'**
  String get createAppPassword;

  /// No description provided for @appPasswordNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Finder on my laptop'**
  String get appPasswordNameHint;

  /// No description provided for @appPasswordReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get appPasswordReadOnly;

  /// No description provided for @appPasswordReadOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Apps using it can only read files'**
  String get appPasswordReadOnlyHint;

  /// No description provided for @appPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account password to confirm it is you'**
  String get appPasswordConfirmHint;

  /// No description provided for @appPasswordCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'App password created'**
  String get appPasswordCreatedTitle;

  /// No description provided for @appPasswordCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy this password now. It will not be shown again.'**
  String get appPasswordCreatedMessage;

  /// No description provided for @appPasswordCopied.
  ///
  /// In en, this message translates to:
  /// **'App password copied'**
  String get appPasswordCopied;

  /// No description provided for @appPasswordNeverUsed.
  ///
  /// In en, this message translates to:
  /// **'Never used'**
  String get appPasswordNeverUsed;

  /// No description provided for @appPasswordLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {date} from {address}'**
  String appPasswordLastUsed(String date, String address);

  /// No description provided for @noAppPasswords.
  ///
  /// In en, this message translates to:
  /// **'No app passwords yet'**
  String get noAppPasswords;

  /// No description provided for @revokeAppPassword.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeAppPassword;

  /// No description provided for @revokeAppPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke {name}?'**
  String revokeAppPasswordTitle(String name);

  /// No description provided for @revokeAppPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Apps using this password stop working at once.'**
  String get revokeAppPasswordMessage;

  /// No description provided for @webdavAddress.
  ///
  /// In en, this message translates to:
  /// **'WebDAV address'**
  String get webdavAddress;

  /// No description provided for @webdavAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'WebDAV address copied'**
  String get webdavAddressCopied;

  /// No description provided for @caldavAddress.
  ///
  /// In en, this message translates to:
  /// **'CalDAV address'**
  String get caldavAddress;

  /// No description provided for @caldavAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'CalDAV address copied'**
  String get caldavAddressCopied;

  /// No description provided for @calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendars;

  /// No description provided for @calendarsHint.
  ///
  /// In en, this message translates to:
  /// **'Apps such as Apple Calendar, Thunderbird and DAVx⁵ sync a calendar over CalDAV with your username and an app password. Apps such as Google Calendar and Outlook can instead subscribe to a secret link, which they refresh every few hours.'**
  String get calendarsHint;

  /// No description provided for @noCalendars.
  ///
  /// In en, this message translates to:
  /// **'No calendars yet'**
  String get noCalendars;

  /// No description provided for @calendarAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Calendar address copied'**
  String get calendarAddressCopied;

  /// No description provided for @calendarSharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String calendarSharedBy(String name);

  /// No description provided for @calendarSubscribedFeed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed feed'**
  String get calendarSubscribedFeed;

  /// No description provided for @subscriptionLinks.
  ///
  /// In en, this message translates to:
  /// **'Subscription links'**
  String get subscriptionLinks;

  /// No description provided for @noSubscriptionLinks.
  ///
  /// In en, this message translates to:
  /// **'No subscription links yet'**
  String get noSubscriptionLinks;

  /// No description provided for @createSubscriptionLink.
  ///
  /// In en, this message translates to:
  /// **'Create subscription link'**
  String get createSubscriptionLink;

  /// No description provided for @subscriptionLinkModeFull.
  ///
  /// In en, this message translates to:
  /// **'All details'**
  String get subscriptionLinkModeFull;

  /// No description provided for @subscriptionLinkModeFullHint.
  ///
  /// In en, this message translates to:
  /// **'Titles, places, notes and attendees'**
  String get subscriptionLinkModeFullHint;

  /// No description provided for @subscriptionLinkModeBusy.
  ///
  /// In en, this message translates to:
  /// **'Only busy times'**
  String get subscriptionLinkModeBusy;

  /// No description provided for @subscriptionLinkModeBusyHint.
  ///
  /// In en, this message translates to:
  /// **'Shows when you are busy and nothing else'**
  String get subscriptionLinkModeBusyHint;

  /// No description provided for @subscriptionLinkNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Outlook at work'**
  String get subscriptionLinkNameHint;

  /// No description provided for @subscriptionLinkCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription link created'**
  String get subscriptionLinkCreatedTitle;

  /// No description provided for @subscriptionLinkCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy the link now. It will not be shown again, and anyone who has it can see this calendar.'**
  String get subscriptionLinkCreatedMessage;

  /// No description provided for @subscriptionLinkWebcal.
  ///
  /// In en, this message translates to:
  /// **'Link for calendar apps (webcal)'**
  String get subscriptionLinkWebcal;

  /// No description provided for @subscriptionLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Subscription link copied'**
  String get subscriptionLinkCopied;

  /// No description provided for @subscriptionLinkLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {date}'**
  String subscriptionLinkLastUsed(String date);

  /// No description provided for @revokeSubscriptionLink.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeSubscriptionLink;

  /// No description provided for @revokeSubscriptionLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this subscription link?'**
  String get revokeSubscriptionLinkTitle;

  /// No description provided for @revokeSubscriptionLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'Apps subscribed with it stop getting updates at once.'**
  String get revokeSubscriptionLinkMessage;

  /// No description provided for @federation.
  ///
  /// In en, this message translates to:
  /// **'Federation'**
  String get federation;

  /// No description provided for @federationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Share with other servers'**
  String get federationEnabled;

  /// No description provided for @federationEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'People can share with users on trusted servers that support Open Cloud Mesh'**
  String get federationEnabledHint;

  /// No description provided for @federationNeedsPublicUrl.
  ///
  /// In en, this message translates to:
  /// **'Set publicUrl in the server config to turn this on'**
  String get federationNeedsPublicUrl;

  /// No description provided for @trustServer.
  ///
  /// In en, this message translates to:
  /// **'Trust server'**
  String get trustServer;

  /// No description provided for @trustServerHint.
  ///
  /// In en, this message translates to:
  /// **'Shares are only exchanged with servers you trust. The server\'s signing key is pinned when you add it.'**
  String get trustServerHint;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// No description provided for @allowPrivateNetwork.
  ///
  /// In en, this message translates to:
  /// **'Allow private network'**
  String get allowPrivateNetwork;

  /// No description provided for @allowPrivateNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'Only for a server on your own network, such as at home'**
  String get allowPrivateNetworkHint;

  /// No description provided for @noTrustedServers.
  ///
  /// In en, this message translates to:
  /// **'No trusted servers yet'**
  String get noTrustedServers;

  /// No description provided for @noTrustedServersHint.
  ///
  /// In en, this message translates to:
  /// **'Add a server to share with its users'**
  String get noTrustedServersHint;

  /// No description provided for @serverKey.
  ///
  /// In en, this message translates to:
  /// **'Key {fingerprint}'**
  String serverKey(String fingerprint);

  /// No description provided for @rediscoverServer.
  ///
  /// In en, this message translates to:
  /// **'Fetch key again'**
  String get rediscoverServer;

  /// No description provided for @rediscoverServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Fetch the key of {name} again?'**
  String rediscoverServerTitle(String name);

  /// No description provided for @rediscoverServerMessage.
  ///
  /// In en, this message translates to:
  /// **'Only do this when the server\'s administrator tells you its key changed. The new key is trusted from now on.'**
  String get rediscoverServerMessage;

  /// No description provided for @removeTrustedServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop trusting {name}?'**
  String removeTrustedServerTitle(String name);

  /// No description provided for @removeTrustedServerMessage.
  ///
  /// In en, this message translates to:
  /// **'Every share with this server ends.'**
  String get removeTrustedServerMessage;

  /// No description provided for @federatedRecipients.
  ///
  /// In en, this message translates to:
  /// **'On other servers'**
  String get federatedRecipients;

  /// No description provided for @federatedNotSharedYet.
  ///
  /// In en, this message translates to:
  /// **'Type a cloud ID, such as alice@cloud.example.com, to share with someone on another server'**
  String get federatedNotSharedYet;

  /// No description provided for @federatedShareHint.
  ///
  /// In en, this message translates to:
  /// **'They get a request on their own server and can open the item once they accept.'**
  String get federatedShareHint;

  /// No description provided for @federatedSharePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for them to accept.'**
  String get federatedSharePending;

  /// No description provided for @federatedSharePendingShort.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get federatedSharePendingShort;

  /// No description provided for @federatedShareAccepted.
  ///
  /// In en, this message translates to:
  /// **'They accepted this share.'**
  String get federatedShareAccepted;

  /// No description provided for @shareSearchFederatedHint.
  ///
  /// In en, this message translates to:
  /// **'Name, group or cloud ID'**
  String get shareSearchFederatedHint;

  /// No description provided for @shareWithFederated.
  ///
  /// In en, this message translates to:
  /// **'Share with someone on another server'**
  String get shareWithFederated;

  /// No description provided for @sharedFromOtherServers.
  ///
  /// In en, this message translates to:
  /// **'From other servers'**
  String get sharedFromOtherServers;

  /// No description provided for @noFederatedShares.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been shared with you from other servers'**
  String get noFederatedShares;

  /// No description provided for @declineFederatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline {name}?'**
  String declineFederatedTitle(String name);

  /// No description provided for @removeFederatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeFederatedTitle(String name);

  /// No description provided for @removeFederatedMessage.
  ///
  /// In en, this message translates to:
  /// **'{owner} is told you no longer want this share.'**
  String removeFederatedMessage(String owner);

  /// No description provided for @acceptInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept invite'**
  String get acceptInvite;

  /// No description provided for @acceptInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite token and server address you received. You become each other\'s contacts and can share with each other.'**
  String get acceptInviteHint;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeone;

  /// No description provided for @inviteToken.
  ///
  /// In en, this message translates to:
  /// **'Invite token'**
  String get inviteToken;

  /// No description provided for @inviteCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite created'**
  String get inviteCreatedTitle;

  /// No description provided for @inviteCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Send the token and this server\'s address to the other person. They accept it on their own server before {date}.'**
  String inviteCreatedMessage(String date);

  /// No description provided for @inviteAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} is now a contact'**
  String inviteAccepted(String name);

  /// No description provided for @openInvite.
  ///
  /// In en, this message translates to:
  /// **'Open invite'**
  String get openInvite;

  /// No description provided for @openInvites.
  ///
  /// In en, this message translates to:
  /// **'Open invites'**
  String get openInvites;

  /// No description provided for @federationContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts on other servers'**
  String get federationContacts;

  /// No description provided for @removeContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeContactTitle(String name);

  /// No description provided for @removeContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Shares stay as they are; you can invite each other again later.'**
  String get removeContactMessage;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @checkSenderAddress.
  ///
  /// In en, this message translates to:
  /// **'Check sender address'**
  String get checkSenderAddress;

  /// No description provided for @checkSenderAddressHint.
  ///
  /// In en, this message translates to:
  /// **'For servers that do not sign requests: only accept them from addresses the server\'s name points to'**
  String get checkSenderAddressHint;

  /// No description provided for @serverUnsignedChecked.
  ///
  /// In en, this message translates to:
  /// **'Does not sign requests; sender address checked'**
  String get serverUnsignedChecked;

  /// No description provided for @serverUnsignedAnyAddress.
  ///
  /// In en, this message translates to:
  /// **'Does not sign requests; any sender address accepted'**
  String get serverUnsignedAnyAddress;

  /// No description provided for @shareDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share details'**
  String get shareDetailsTitle;

  /// No description provided for @shareDetailsSoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get shareDetailsSoftware;

  /// No description provided for @shareDetailsSharedOn.
  ///
  /// In en, this message translates to:
  /// **'Shared on'**
  String get shareDetailsSharedOn;

  /// No description provided for @sharedWithYou.
  ///
  /// In en, this message translates to:
  /// **'Shared with you'**
  String get sharedWithYou;

  /// No description provided for @leaveShareMessage.
  ///
  /// In en, this message translates to:
  /// **'It disappears from your files. {owner} can share it with you again.'**
  String leaveShareMessage(String owner);

  /// No description provided for @showSharesInFiles.
  ///
  /// In en, this message translates to:
  /// **'Show in Files'**
  String get showSharesInFiles;

  /// No description provided for @showSharesInFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Shares appear among your own files. When off, open them from here.'**
  String get showSharesInFilesHint;

  /// No description provided for @sharedByYou.
  ///
  /// In en, this message translates to:
  /// **'Shared by you'**
  String get sharedByYou;

  /// No description provided for @serverPreviewsGroup.
  ///
  /// In en, this message translates to:
  /// **'Previews'**
  String get serverPreviewsGroup;

  /// No description provided for @regeneratePreviews.
  ///
  /// In en, this message translates to:
  /// **'Regenerate previews'**
  String get regeneratePreviews;

  /// No description provided for @regeneratePreviewsHint.
  ///
  /// In en, this message translates to:
  /// **'Make every file\'s preview again in the background'**
  String get regeneratePreviewsHint;

  /// No description provided for @regeneratePreviewsMessage.
  ///
  /// In en, this message translates to:
  /// **'Every file gets a new preview in the background. Until its new preview is ready, a file shows its icon.'**
  String get regeneratePreviewsMessage;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @previewsQueued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file queued for a new preview} other{{count} files queued for a new preview}}'**
  String previewsQueued(int count);

  /// No description provided for @searchFieldTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get searchFieldTag;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @tagsAction.
  ///
  /// In en, this message translates to:
  /// **'Tags…'**
  String get tagsAction;

  /// No description provided for @tagPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Search or create a tag'**
  String get tagPickerHint;

  /// No description provided for @tagInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Use letters, digits, -, _ or / without spaces'**
  String get tagInvalidName;

  /// No description provided for @tagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Type #name in a note, or add one from an item\'s menu.'**
  String get tagsEmpty;

  /// No description provided for @tagCreate.
  ///
  /// In en, this message translates to:
  /// **'Create #{name}'**
  String tagCreate(String name);

  /// No description provided for @tagUsage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not used} =1{1 item} other{{count} items}}'**
  String tagUsage(int count);

  /// No description provided for @tagEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get tagEditTitle;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tagName;

  /// No description provided for @tagColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get tagColor;

  /// No description provided for @tagDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete #{name}?'**
  String tagDeleteTitle(String name);

  /// No description provided for @tagDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The tag is not used anywhere.} =1{It is removed from 1 item, including the text of your notes.} other{It is removed from {count} items, including the text of your notes.}}'**
  String tagDeleteMessage(int count);

  /// No description provided for @tagSuggestionCreate.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagSuggestionCreate;

  /// No description provided for @searchKeywordsTags.
  ///
  /// In en, this message translates to:
  /// **'labels, hashtags, colors, categories'**
  String get searchKeywordsTags;

  /// No description provided for @tagsDeleteUnused.
  ///
  /// In en, this message translates to:
  /// **'Delete unused tags'**
  String get tagsDeleteUnused;

  /// No description provided for @tagsDeleteUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete unused tags?'**
  String get tagsDeleteUnusedTitle;

  /// No description provided for @tagsDeleteUnusedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tag is not on any item or in any of your notes. It will be deleted.} other{{count} tags are not on any item or in any of your notes. They will be deleted.}}'**
  String tagsDeleteUnusedMessage(int count);

  /// No description provided for @tagsUnusedDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unused tags} =1{1 tag deleted} other{{count} tags deleted}}'**
  String tagsUnusedDeleted(int count);

  /// No description provided for @recipeImportLink.
  ///
  /// In en, this message translates to:
  /// **'Link to the recipe'**
  String get recipeImportLink;

  /// No description provided for @recipeImportMessage.
  ///
  /// In en, this message translates to:
  /// **'The ingredients, steps and images are copied into a new note. You can tidy it up afterwards.'**
  String get recipeImportMessage;

  /// No description provided for @recipeImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get recipeImportAction;

  /// No description provided for @recipeStartCooking.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get recipeStartCooking;

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipeServings;

  /// No description provided for @recipeFewerServings.
  ///
  /// In en, this message translates to:
  /// **'Fewer servings'**
  String get recipeFewerServings;

  /// No description provided for @recipeMoreServings.
  ///
  /// In en, this message translates to:
  /// **'More servings'**
  String get recipeMoreServings;

  /// No description provided for @recipeStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String recipeStepOf(int current, int total);

  /// No description provided for @recipeYouNeed.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need'**
  String get recipeYouNeed;

  /// No description provided for @recipePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get recipePrevious;

  /// No description provided for @recipeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recipeNext;

  /// No description provided for @recipeBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get recipeBegin;

  /// No description provided for @recipeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recipeDone;

  /// No description provided for @recipeNoSteps.
  ///
  /// In en, this message translates to:
  /// **'This recipe has no steps yet.'**
  String get recipeNoSteps;

  /// No description provided for @recipeStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start a timer for {duration}'**
  String recipeStartTimer(String duration);

  /// No description provided for @recipeStopTimer.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get recipeStopTimer;

  /// No description provided for @recipeTimerDone.
  ///
  /// In en, this message translates to:
  /// **'{label} is done'**
  String recipeTimerDone(String label);

  /// No description provided for @recipeImportFromLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get recipeImportFromLink;

  /// No description provided for @recipeImportFromPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get recipeImportFromPaste;

  /// No description provided for @recipeImportPasteMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy the recipe in your browser and paste it here. Select the text from the title to the last step, or copy the whole page source to get the images too.'**
  String get recipeImportPasteMessage;

  /// No description provided for @recipeImportPasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get recipeImportPasteButton;

  /// No description provided for @recipeImportPastedLength.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character pasted} other{{count} characters pasted}}'**
  String recipeImportPastedLength(int count);

  /// No description provided for @recipeImportLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'Link to the recipe (optional)'**
  String get recipeImportLinkOptional;

  /// No description provided for @recipeImportRefused.
  ///
  /// In en, this message translates to:
  /// **'This site doesn\'t let Polder load the page. Open it in your browser, copy the recipe and paste it here.'**
  String get recipeImportRefused;

  /// No description provided for @recipeImportClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clipboard holds no text.'**
  String get recipeImportClipboardEmpty;

  /// No description provided for @recipeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get recipeAdd;

  /// No description provided for @recipeFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get recipeFromScratch;

  /// No description provided for @recipeFromScratchMessage.
  ///
  /// In en, this message translates to:
  /// **'Start from an empty recipe with ingredients and steps to fill in yourself.'**
  String get recipeFromScratchMessage;

  /// No description provided for @notesFilterByTag.
  ///
  /// In en, this message translates to:
  /// **'Filter by tag'**
  String get notesFilterByTag;

  /// No description provided for @notesFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get notesFilterClear;

  /// No description provided for @notesFilterNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Create tags to filter your notes by them.'**
  String get notesFilterNoTags;

  /// No description provided for @notesFilterNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No notes in your notes folder have these tags.'**
  String get notesFilterNoMatches;

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter notes'**
  String get notesSearchHint;

  /// No description provided for @notesSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No notes match your search.'**
  String get notesSearchNoResults;

  /// No description provided for @notesViewOptions.
  ///
  /// In en, this message translates to:
  /// **'Sort and view options'**
  String get notesViewOptions;

  /// No description provided for @notesExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get notesExpandAll;

  /// No description provided for @notesCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get notesCollapseAll;

  /// No description provided for @notesRevealCurrent.
  ///
  /// In en, this message translates to:
  /// **'Reveal open note'**
  String get notesRevealCurrent;

  /// No description provided for @notesShowFamilyTree.
  ///
  /// In en, this message translates to:
  /// **'Related pages'**
  String get notesShowFamilyTree;

  /// No description provided for @notesViewAll.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get notesViewAll;

  /// No description provided for @notesViewUntagged.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get notesViewUntagged;

  /// No description provided for @notesViewUntaggedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Every note in your notes folder has a tag.'**
  String get notesViewUntaggedEmpty;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @slideshow.
  ///
  /// In en, this message translates to:
  /// **'Slideshow'**
  String get slideshow;

  /// No description provided for @previousItem.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousItem;

  /// No description provided for @nextItem.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextItem;

  /// No description provided for @mediaCounter.
  ///
  /// In en, this message translates to:
  /// **'{index} / {count}'**
  String mediaCounter(int index, int count);

  /// No description provided for @couldNotLoadMedia.
  ///
  /// In en, this message translates to:
  /// **'This file couldn\'t be loaded'**
  String get couldNotLoadMedia;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @setAsWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Set as wallpaper'**
  String get setAsWallpaper;

  /// No description provided for @wallpaperSet.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper updated'**
  String get wallpaperSet;

  /// No description provided for @setAs.
  ///
  /// In en, this message translates to:
  /// **'Set as…'**
  String get setAs;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @lensLabel.
  ///
  /// In en, this message translates to:
  /// **'Lens'**
  String get lensLabel;

  /// No description provided for @apertureLabel.
  ///
  /// In en, this message translates to:
  /// **'Aperture'**
  String get apertureLabel;

  /// No description provided for @shutterSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Shutter speed'**
  String get shutterSpeedLabel;

  /// No description provided for @focalLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Focal length'**
  String get focalLengthLabel;

  /// No description provided for @isoLabel.
  ///
  /// In en, this message translates to:
  /// **'ISO'**
  String get isoLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @videoCodecLabel.
  ///
  /// In en, this message translates to:
  /// **'Video codec'**
  String get videoCodecLabel;

  /// No description provided for @frameRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Frame rate'**
  String get frameRateLabel;

  /// No description provided for @audioCodecLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio codec'**
  String get audioCodecLabel;

  /// No description provided for @bitrateLabel.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrateLabel;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @updatesAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Install updates automatically'**
  String get updatesAutomatic;

  /// No description provided for @updatesAutomaticHint.
  ///
  /// In en, this message translates to:
  /// **'Download new versions in the background and install them when Polder quits'**
  String get updatesAutomaticHint;

  /// No description provided for @updatesNightly.
  ///
  /// In en, this message translates to:
  /// **'Receive nightly builds'**
  String get updatesNightly;

  /// No description provided for @updatesNightlyHint.
  ///
  /// In en, this message translates to:
  /// **'Get the newest development builds early; they may contain bugs'**
  String get updatesNightlyHint;

  /// No description provided for @updatesCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updatesCheck;

  /// No description provided for @updatesChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updatesChecking;

  /// No description provided for @updatesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Polder is up to date'**
  String get updatesUpToDate;

  /// No description provided for @updatesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates'**
  String get updatesFailed;

  /// No description provided for @updatesInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t install version {version} ({build})'**
  String updatesInstallFailed(String version, int build);

  /// No description provided for @updatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build}) is available'**
  String updatesAvailable(String version, int build);

  /// No description provided for @updatesDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update… {percent}%'**
  String updatesDownloading(int percent);

  /// No description provided for @updatesReady.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build}) installs when Polder quits'**
  String updatesReady(String version, int build);

  /// No description provided for @updatesRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart to update'**
  String get updatesRestart;

  /// No description provided for @updatesInstall.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updatesInstall;

  /// No description provided for @updatesDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updatesDownload;

  /// No description provided for @updatesReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get updatesReleaseNotes;

  /// No description provided for @aboutNightly.
  ///
  /// In en, this message translates to:
  /// **'Nightly build'**
  String get aboutNightly;

  /// No description provided for @calendarImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get calendarImported;

  /// No description provided for @calendarNoImported.
  ///
  /// In en, this message translates to:
  /// **'Add calendars from other services, such as Google Calendar, Outlook or iCloud.'**
  String get calendarNoImported;

  /// No description provided for @calendarNew.
  ///
  /// In en, this message translates to:
  /// **'New calendar'**
  String get calendarNew;

  /// No description provided for @calendarEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit calendar'**
  String get calendarEdit;

  /// No description provided for @calendarAddExternal.
  ///
  /// In en, this message translates to:
  /// **'Add external calendar'**
  String get calendarAddExternal;

  /// No description provided for @calendarName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get calendarName;

  /// No description provided for @calendarColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get calendarColorLabel;

  /// No description provided for @calendarDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get calendarDefault;

  /// No description provided for @calendarSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Use for invitations'**
  String get calendarSetDefault;

  /// No description provided for @calendarDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String calendarDeleteTitle(String name);

  /// No description provided for @calendarDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The calendar and all its events will be deleted for everyone it is shared with.'**
  String get calendarDeleteMessage;

  /// No description provided for @calendarLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String calendarLeaveTitle(String name);

  /// No description provided for @calendarLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see this calendar. The owner can share it with you again.'**
  String get calendarLeaveMessage;

  /// No description provided for @calendarLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get calendarLeave;

  /// No description provided for @calendarRemoveImportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String calendarRemoveImportedTitle(String name);

  /// No description provided for @calendarRemoveImportedMessage.
  ///
  /// In en, this message translates to:
  /// **'The calendar stops syncing and its events are removed from Polder. The original is not affected.'**
  String get calendarRemoveImportedMessage;

  /// No description provided for @calendarRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get calendarRemove;

  /// No description provided for @calendarSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get calendarSyncNow;

  /// No description provided for @calendarSyncedAt.
  ///
  /// In en, this message translates to:
  /// **'Synced {time}'**
  String calendarSyncedAt(String time);

  /// No description provided for @calendarSyncPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first sync'**
  String get calendarSyncPending;

  /// No description provided for @calendarSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String calendarSyncFailed(String error);

  /// No description provided for @calendarSyncRequested.
  ///
  /// In en, this message translates to:
  /// **'Syncing {name}'**
  String calendarSyncRequested(String name);

  /// No description provided for @calendarFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get calendarFromUrl;

  /// No description provided for @calendarFromUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Stays up to date. Paste an iCal (.ics) or webcal link, such as the secret address of a Google, Outlook or iCloud calendar.'**
  String get calendarFromUrlHint;

  /// No description provided for @calendarFromFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get calendarFromFile;

  /// No description provided for @calendarFromFileHint.
  ///
  /// In en, this message translates to:
  /// **'Adds the events of an .ics file once, as a new calendar. A .zip with .ics files, such as a Google Calendar export, works too.'**
  String get calendarFromFileHint;

  /// No description provided for @calendarLink.
  ///
  /// In en, this message translates to:
  /// **'Calendar link'**
  String get calendarLink;

  /// No description provided for @calendarInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'Enter an http, https or webcal link'**
  String get calendarInvalidLink;

  /// No description provided for @calendarRefreshEvery.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get calendarRefreshEvery;

  /// No description provided for @calendarEvery15Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 15 minutes'**
  String get calendarEvery15Minutes;

  /// No description provided for @calendarEveryHour.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get calendarEveryHour;

  /// No description provided for @calendarEvery6Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 6 hours'**
  String get calendarEvery6Hours;

  /// No description provided for @calendarEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get calendarEveryDay;

  /// No description provided for @calendarChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose .ics file'**
  String get calendarChooseFile;

  /// No description provided for @calendarImportDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event imported} other{{count} events imported}}'**
  String calendarImportDone(int count);

  /// No description provided for @calendarAccessRead.
  ///
  /// In en, this message translates to:
  /// **'Can view'**
  String get calendarAccessRead;

  /// No description provided for @calendarAccessReadWrite.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get calendarAccessReadWrite;

  /// No description provided for @calendarAccessFreeBusy.
  ///
  /// In en, this message translates to:
  /// **'Sees busy times only'**
  String get calendarAccessFreeBusy;

  /// No description provided for @calendarStopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get calendarStopSharing;

  /// No description provided for @calendarManage.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendarManage;

  /// No description provided for @calendarDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get calendarDiscover;

  /// No description provided for @calendarDiscoverHint.
  ///
  /// In en, this message translates to:
  /// **'Calendars that stay up to date by themselves.'**
  String get calendarDiscoverHint;

  /// No description provided for @calendarSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get calendarSuggested;

  /// No description provided for @calendarPublicHolidays.
  ///
  /// In en, this message translates to:
  /// **'Public holidays'**
  String get calendarPublicHolidays;

  /// No description provided for @calendarReligiousHolidays.
  ///
  /// In en, this message translates to:
  /// **'Religious holidays'**
  String get calendarReligiousHolidays;

  /// No description provided for @calendarMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get calendarMore;

  /// No description provided for @calendarSearchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get calendarSearchCountries;

  /// No description provided for @calendarHolidaysIn.
  ///
  /// In en, this message translates to:
  /// **'Holidays in {country}'**
  String calendarHolidaysIn(String country);

  /// No description provided for @calendarChristianHolidays.
  ///
  /// In en, this message translates to:
  /// **'Christian holidays'**
  String get calendarChristianHolidays;

  /// No description provided for @calendarOrthodoxHolidays.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Christian holidays'**
  String get calendarOrthodoxHolidays;

  /// No description provided for @calendarIslamicHolidays.
  ///
  /// In en, this message translates to:
  /// **'Islamic holidays'**
  String get calendarIslamicHolidays;

  /// No description provided for @calendarJewishHolidays.
  ///
  /// In en, this message translates to:
  /// **'Jewish holidays'**
  String get calendarJewishHolidays;

  /// No description provided for @calendarHinduHolidays.
  ///
  /// In en, this message translates to:
  /// **'Hindu holidays'**
  String get calendarHinduHolidays;

  /// No description provided for @calendarWeekNumbers.
  ///
  /// In en, this message translates to:
  /// **'Week numbers'**
  String get calendarWeekNumbers;

  /// No description provided for @calendarMoonPhases.
  ///
  /// In en, this message translates to:
  /// **'Phases of the moon'**
  String get calendarMoonPhases;

  /// No description provided for @calendarAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get calendarAdded;

  /// No description provided for @calendarImportInto.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get calendarImportInto;

  /// No description provided for @calendarImportIntoHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an .ics file, or a .zip of them such as a Google Calendar export'**
  String get calendarImportIntoHint;

  /// No description provided for @calendarImportFailedSome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event could not be imported} other{{count} events could not be imported}}'**
  String calendarImportFailedSome(int count);

  /// No description provided for @calendarFeedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language of the calendars'**
  String get calendarFeedLanguage;

  /// No description provided for @calendarFeedLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Google translates calendar names and most holidays; some event names stay in English.'**
  String get calendarFeedLanguageHint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Shares, reminders and uploads'**
  String get notificationsHint;

  /// No description provided for @notificationsEnable.
  ///
  /// In en, this message translates to:
  /// **'Show notifications'**
  String get notificationsEnable;

  /// No description provided for @notificationsEnableHint.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get notificationsEnableHint;

  /// No description provided for @notificationsWebHint.
  ///
  /// In en, this message translates to:
  /// **'Your browser shows them while Polder is open in a tab'**
  String get notificationsWebHint;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them for Polder in your system or browser settings.'**
  String get notificationsBlocked;

  /// No description provided for @notificationsNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on, but this device hasn\'t allowed Polder to show them yet.'**
  String get notificationsNotAllowed;

  /// No description provided for @notificationsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notificationsAllow;

  /// No description provided for @notificationsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notificationsOpenSettings;

  /// No description provided for @notificationsReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Calendar reminder notifications are off, so you won\'t get these.'**
  String get notificationsReminderOff;

  /// No description provided for @notificationsTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notificationsTurnOn;

  /// No description provided for @notificationsAbout.
  ///
  /// In en, this message translates to:
  /// **'What to notify about'**
  String get notificationsAbout;

  /// No description provided for @notificationsShares.
  ///
  /// In en, this message translates to:
  /// **'New shares'**
  String get notificationsShares;

  /// No description provided for @notificationsSharesHint.
  ///
  /// In en, this message translates to:
  /// **'When someone shares a file or folder with you, with buttons to accept or decline'**
  String get notificationsSharesHint;

  /// No description provided for @notificationsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar reminders'**
  String get notificationsCalendar;

  /// No description provided for @notificationsCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'At the reminder times set on each event; turn calendars on or off from their menu in the calendar'**
  String get notificationsCalendarHint;

  /// No description provided for @notificationsUploadProgress.
  ///
  /// In en, this message translates to:
  /// **'Upload progress'**
  String get notificationsUploadProgress;

  /// No description provided for @notificationsUploadProgressHint.
  ///
  /// In en, this message translates to:
  /// **'One notification that keeps updating while auto upload runs'**
  String get notificationsUploadProgressHint;

  /// No description provided for @notificationsUploadSummary.
  ///
  /// In en, this message translates to:
  /// **'Upload results'**
  String get notificationsUploadSummary;

  /// No description provided for @notificationsUploadSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'How much was uploaded, and anything that failed'**
  String get notificationsUploadSummaryHint;

  /// No description provided for @notificationsUploadCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking for new photos'**
  String get notificationsUploadCheck;

  /// No description provided for @notificationsUploadCheckHint.
  ///
  /// In en, this message translates to:
  /// **'A quiet notification while auto upload looks for new photos and videos'**
  String get notificationsUploadCheckHint;

  /// No description provided for @notificationsReliability.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get notificationsReliability;

  /// No description provided for @notificationsBattery.
  ///
  /// In en, this message translates to:
  /// **'Run in the background'**
  String get notificationsBattery;

  /// No description provided for @notificationsBatteryHint.
  ///
  /// In en, this message translates to:
  /// **'Stops the system from delaying reminders, shares and uploads to save battery'**
  String get notificationsBatteryHint;

  /// No description provided for @notificationsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get notificationsAllowed;

  /// No description provided for @notificationChannelUploads.
  ///
  /// In en, this message translates to:
  /// **'Uploads'**
  String get notificationChannelUploads;

  /// No description provided for @notificationChannelCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar reminders'**
  String get notificationChannelCalendar;

  /// No description provided for @notificationChannelSharing.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get notificationChannelSharing;

  /// No description provided for @notificationShareTitle.
  ///
  /// In en, this message translates to:
  /// **'{owner} shared {name} with you'**
  String notificationShareTitle(String owner, String name);

  /// No description provided for @notificationShareGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'{owner} shared {name} with {group}'**
  String notificationShareGroupTitle(String owner, String name, String group);

  /// No description provided for @notificationFederatedShareBody.
  ///
  /// In en, this message translates to:
  /// **'From {server}'**
  String notificationFederatedShareBody(String server);

  /// No description provided for @notificationUploadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploading {done} of {total}'**
  String notificationUploadingTitle(int done, int total);

  /// No description provided for @notificationUploadDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file uploaded} other{{count} files uploaded}}'**
  String notificationUploadDone(int count);

  /// No description provided for @notificationUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file could not be uploaded} other{{count} files could not be uploaded}}'**
  String notificationUploadFailed(int count);

  /// No description provided for @notificationUploadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Open auto upload to see what went wrong'**
  String get notificationUploadFailedBody;

  /// No description provided for @notificationUploadChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for new photos and videos'**
  String get notificationUploadChecking;

  /// No description provided for @notificationReminderAt.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String notificationReminderAt(String time);

  /// No description provided for @notificationReminderAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get notificationReminderAllDay;

  /// No description provided for @calendarRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders on'**
  String get calendarRemindersOn;

  /// No description provided for @calendarRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders off'**
  String get calendarRemindersOff;

  /// No description provided for @sharedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get sharedWaiting;

  /// No description provided for @sharedWaitingHint.
  ///
  /// In en, this message translates to:
  /// **'Accept to add these to your files'**
  String get sharedWaitingHint;

  /// No description provided for @shareAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} is now in your files'**
  String shareAccepted(String name);

  /// No description provided for @shareDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined {name}'**
  String shareDeclined(String name);

  /// No description provided for @errorStorageFull.
  ///
  /// In en, this message translates to:
  /// **'The server ran out of disk space and could not save this.'**
  String get errorStorageFull;

  /// No description provided for @errorTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The server stopped responding.'**
  String get errorTimedOut;

  /// No description provided for @connectionNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network connection'**
  String get connectionNoNetwork;

  /// No description provided for @connectionServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Not connected to server'**
  String get connectionServerUnreachable;

  /// No description provided for @connectionServerFull.
  ///
  /// In en, this message translates to:
  /// **'Server storage is full'**
  String get connectionServerFull;

  /// No description provided for @connectionServerReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Server can\'t store changes'**
  String get connectionServerReadOnly;

  /// No description provided for @changesSavedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Changes are saved on this device} =1{1 change saved on this device} other{{count} changes saved on this device}}'**
  String changesSavedOnDevice(int count);

  /// No description provided for @hintUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Check your network connection, or whether the server is running. Changes sync automatically when it\'s back.'**
  String get hintUnreachable;

  /// No description provided for @hintStorageFull.
  ///
  /// In en, this message translates to:
  /// **'The server could not store the change; its disk may be full. Ask the server administrator to free up space, then retry.'**
  String get hintStorageFull;

  /// No description provided for @hintQuota.
  ///
  /// In en, this message translates to:
  /// **'Your storage quota is full. Delete files or empty the trash, then retry.'**
  String get hintQuota;

  /// No description provided for @hintServerError.
  ///
  /// In en, this message translates to:
  /// **'The server ran into an error. Retry later, or ask the server administrator to check the server logs.'**
  String get hintServerError;

  /// No description provided for @hintConflict.
  ///
  /// In en, this message translates to:
  /// **'This was changed somewhere else too. Choose which version to keep.'**
  String get hintConflict;

  /// No description provided for @hintRejected.
  ///
  /// In en, this message translates to:
  /// **'The server refused this change. Discard it, or save a copy and try again.'**
  String get hintRejected;

  /// No description provided for @noteSynced.
  ///
  /// In en, this message translates to:
  /// **'Saved and synced'**
  String get noteSynced;

  /// No description provided for @noteSavedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device; waiting to sync. Tap to sync now'**
  String get noteSavedOnDevice;

  /// No description provided for @noteNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device, but not synced to the server'**
  String get noteNotSynced;

  /// No description provided for @retrySync.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retrySync;

  /// No description provided for @retryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry all'**
  String get retryAll;

  /// No description provided for @discardChange.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardChange;

  /// No description provided for @discardChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this change?'**
  String get discardChangeTitle;

  /// No description provided for @discardChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'The version on this device is thrown away and the server\'s version is kept.'**
  String get discardChangeMessage;

  /// No description provided for @offlineGroupNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get offlineGroupNotes;

  /// No description provided for @offlineGroupFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get offlineGroupFiles;

  /// No description provided for @offlineGroupCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get offlineGroupCalendar;

  /// No description provided for @syncWaitingForServer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the server'**
  String get syncWaitingForServer;

  /// No description provided for @syncFailedItem.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get syncFailedItem;

  /// No description provided for @keepOffline.
  ///
  /// In en, this message translates to:
  /// **'Make available offline'**
  String get keepOffline;

  /// No description provided for @removeFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove from device'**
  String get removeFromDevice;

  /// No description provided for @availableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get availableOffline;

  /// No description provided for @errorDeviceFull.
  ///
  /// In en, this message translates to:
  /// **'Not enough free space on this device'**
  String get errorDeviceFull;

  /// No description provided for @hintDeviceFull.
  ///
  /// In en, this message translates to:
  /// **'Free up space on this device, or remove offline files with \"Remove from device\".'**
  String get hintDeviceFull;

  /// No description provided for @offlineDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download for offline use: {reason}'**
  String offlineDownloadFailed(String reason);

  /// No description provided for @offlineDownloadingTag.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String offlineDownloadingTag(int percent);

  /// No description provided for @offlineDownloadsFailedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file couldn\'t be made available offline} other{{count} files couldn\'t be made available offline}}'**
  String offlineDownloadsFailedSummary(int count);

  /// No description provided for @waitingForOffline.
  ///
  /// In en, this message translates to:
  /// **'Waiting to download for offline use'**
  String get waitingForOffline;

  /// No description provided for @downloadingForOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloading for offline use, {percent}%'**
  String downloadingForOffline(int percent);

  /// No description provided for @downloadingFilesForOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloading for offline use, {done} of {total} files'**
  String downloadingFilesForOffline(int done, int total);

  /// No description provided for @sessionEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get sessionEndedTitle;

  /// No description provided for @sessionEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session on this device has ended. Sign in again to keep syncing. Nothing on this device is lost.'**
  String get sessionEndedMessage;

  /// No description provided for @sessionEndedStatus.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEndedStatus;

  /// No description provided for @sessionEndedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sessionEndedSignIn;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get continueOffline;

  /// No description provided for @firstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First day of the week'**
  String get firstDayOfWeek;

  /// No description provided for @firstDayOfWeekRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional default ({day})'**
  String firstDayOfWeekRegional(String day);

  /// No description provided for @calendarSettings.
  ///
  /// In en, this message translates to:
  /// **'Calendar settings'**
  String get calendarSettings;

  /// No description provided for @fileOperationMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving {subject}'**
  String fileOperationMoving(String subject);

  /// No description provided for @fileOperationMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved {subject}'**
  String fileOperationMoved(String subject);

  /// No description provided for @fileOperationCopying.
  ///
  /// In en, this message translates to:
  /// **'Copying {subject}'**
  String fileOperationCopying(String subject);

  /// No description provided for @fileOperationCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied {subject}'**
  String fileOperationCopied(String subject);

  /// No description provided for @fileOperationDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting {subject}'**
  String fileOperationDeleting(String subject);

  /// No description provided for @fileOperationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {subject}'**
  String fileOperationDeleted(String subject);

  /// No description provided for @fileOperationRenaming.
  ///
  /// In en, this message translates to:
  /// **'Renaming {subject}'**
  String fileOperationRenaming(String subject);

  /// No description provided for @fileOperationRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed {subject}'**
  String fileOperationRenamed(String subject);

  /// No description provided for @fileOperationRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring {subject}'**
  String fileOperationRestoring(String subject);

  /// No description provided for @fileOperationRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored {subject}'**
  String fileOperationRestored(String subject);

  /// No description provided for @fileOperationPurging.
  ///
  /// In en, this message translates to:
  /// **'Permanently deleting {subject}'**
  String fileOperationPurging(String subject);

  /// No description provided for @fileOperationPurged.
  ///
  /// In en, this message translates to:
  /// **'Permanently deleted {subject}'**
  String fileOperationPurged(String subject);

  /// No description provided for @fileOperationItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String fileOperationItems(int count);

  /// No description provided for @fileOperationInto.
  ///
  /// In en, this message translates to:
  /// **'To {folder}'**
  String fileOperationInto(String folder);

  /// No description provided for @fileOperationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Not everything went through'**
  String get fileOperationIncomplete;

  /// No description provided for @fileOperationTagMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving…'**
  String get fileOperationTagMoving;

  /// No description provided for @fileOperationTagCopying.
  ///
  /// In en, this message translates to:
  /// **'Copying…'**
  String get fileOperationTagCopying;

  /// No description provided for @fileOperationTagDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get fileOperationTagDeleting;

  /// No description provided for @fileOperationTagRenaming.
  ///
  /// In en, this message translates to:
  /// **'Renaming…'**
  String get fileOperationTagRenaming;

  /// No description provided for @fileOperationTagWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get fileOperationTagWaiting;

  /// No description provided for @fileOperationTagMovingHere.
  ///
  /// In en, this message translates to:
  /// **'Moving here…'**
  String get fileOperationTagMovingHere;

  /// No description provided for @fileOperationTagCopyingHere.
  ///
  /// In en, this message translates to:
  /// **'Copying here…'**
  String get fileOperationTagCopyingHere;

  /// No description provided for @fileOperationsMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more action} other{{count} more actions}}'**
  String fileOperationsMore(int count);

  /// No description provided for @fileOperationTagRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get fileOperationTagRestoring;

  /// No description provided for @emailSettings.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailSettings;

  /// No description provided for @emailSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Mail server for password resets, alerts and shares'**
  String get emailSettingsHint;

  /// No description provided for @emailOn.
  ///
  /// In en, this message translates to:
  /// **'Emails are on'**
  String get emailOn;

  /// No description provided for @emailOff.
  ///
  /// In en, this message translates to:
  /// **'Emails are off'**
  String get emailOff;

  /// No description provided for @emailOnHint.
  ///
  /// In en, this message translates to:
  /// **'Polder sends password resets, sign-in alerts, storage warnings and shares, styled with your branding.'**
  String get emailOnHint;

  /// No description provided for @emailOffHint.
  ///
  /// In en, this message translates to:
  /// **'Set an SMTP server and a sender address to send password resets, sign-in alerts, storage warnings and shares.'**
  String get emailOffHint;

  /// No description provided for @emailManagedByConfig.
  ///
  /// In en, this message translates to:
  /// **'These settings come from the server\'s config or environment, so they can\'t be changed here.'**
  String get emailManagedByConfig;

  /// No description provided for @mailServerGroup.
  ///
  /// In en, this message translates to:
  /// **'SMTP'**
  String get mailServerGroup;

  /// No description provided for @mailServerHost.
  ///
  /// In en, this message translates to:
  /// **'SMTP server'**
  String get mailServerHost;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @mailSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get mailSecurity;

  /// No description provided for @mailServerPort.
  ///
  /// In en, this message translates to:
  /// **'SMTP port'**
  String get mailServerPort;

  /// No description provided for @mailServerPortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default ({port})'**
  String mailServerPortDefault(int port);

  /// No description provided for @mailServerPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port, or empty for the default'**
  String get mailServerPortLabel;

  /// No description provided for @mailUsername.
  ///
  /// In en, this message translates to:
  /// **'SMTP username'**
  String get mailUsername;

  /// No description provided for @mailUsernameNone.
  ///
  /// In en, this message translates to:
  /// **'None; the SMTP server doesn\'t need a login'**
  String get mailUsernameNone;

  /// No description provided for @mailPasswordSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get mailPasswordSaved;

  /// No description provided for @mailPassword.
  ///
  /// In en, this message translates to:
  /// **'SMTP password'**
  String get mailPassword;

  /// No description provided for @mailPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Stored on the server and never shown again. Remove it if the SMTP server needs no login.'**
  String get mailPasswordHint;

  /// No description provided for @mailSenderGroup.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get mailSenderGroup;

  /// No description provided for @mailFrom.
  ///
  /// In en, this message translates to:
  /// **'From address'**
  String get mailFrom;

  /// No description provided for @mailFromHint.
  ///
  /// In en, this message translates to:
  /// **'The address emails come from'**
  String get mailFromHint;

  /// No description provided for @mailFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Address, such as Polder <polder@example.com>'**
  String get mailFromLabel;

  /// No description provided for @mailTestGroup.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get mailTestGroup;

  /// No description provided for @sendTestEmail.
  ///
  /// In en, this message translates to:
  /// **'Send a test email'**
  String get sendTestEmail;

  /// No description provided for @sendTestEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Check the settings with an email in your server\'s style'**
  String get sendTestEmailHint;

  /// No description provided for @sendTestEmailNeedsServer.
  ///
  /// In en, this message translates to:
  /// **'Set an SMTP server and sender address first'**
  String get sendTestEmailNeedsServer;

  /// No description provided for @mailTestRecipient.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get mailTestRecipient;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @testEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Test email sent to {address}'**
  String testEmailSent(String address);

  /// No description provided for @mailSecurityStartTls.
  ///
  /// In en, this message translates to:
  /// **'STARTTLS'**
  String get mailSecurityStartTls;

  /// No description provided for @mailSecurityTls.
  ///
  /// In en, this message translates to:
  /// **'TLS'**
  String get mailSecurityTls;

  /// No description provided for @mailSecurityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mailSecurityNone;

  /// No description provided for @mailSecurityStartTlsHint.
  ///
  /// In en, this message translates to:
  /// **'Upgrades to an encrypted connection; usually port 587'**
  String get mailSecurityStartTlsHint;

  /// No description provided for @mailSecurityTlsHint.
  ///
  /// In en, this message translates to:
  /// **'Encrypted from the start; usually port 465'**
  String get mailSecurityTlsHint;

  /// No description provided for @mailSecurityNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted; only for an SMTP server on a trusted network'**
  String get mailSecurityNoneHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email address. If your account has an email address, we\'ll send it a code to choose a new password.'**
  String get forgotPasswordHint;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get usernameOrEmail;

  /// No description provided for @resetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This server can\'t send password reset emails. Ask an administrator to set a new password for you.'**
  String get resetUnavailable;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendResetCode;

  /// No description provided for @resetCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get resetCodeTitle;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'If an account matches and has an email address, we\'ve sent it a code. It works once, for an hour.'**
  String get resetCodeSent;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get resetCode;

  /// No description provided for @resetCodeNeverLinks.
  ///
  /// In en, this message translates to:
  /// **'We never send reset links. Type the code here yourself.'**
  String get resetCodeNeverLinks;

  /// No description provided for @sendResetCodeAgain.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get sendResetCodeAgain;

  /// No description provided for @passwordResetDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordResetDoneTitle;

  /// No description provided for @passwordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your new password. You\'ve been signed out on your other devices.'**
  String get passwordResetDone;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Add an email address'**
  String get emailNotificationsNoAddress;

  /// No description provided for @emailNotificationsNoAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Emails need an address in your account'**
  String get emailNotificationsNoAddressHint;

  /// No description provided for @emailSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security alerts'**
  String get emailSecurity;

  /// No description provided for @emailSecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Sign-ins from new addresses and changes to your email address'**
  String get emailSecurityHint;

  /// No description provided for @emailQuota.
  ///
  /// In en, this message translates to:
  /// **'Storage warnings'**
  String get emailQuota;

  /// No description provided for @emailQuotaHint.
  ///
  /// In en, this message translates to:
  /// **'When your storage is almost or completely full'**
  String get emailQuotaHint;

  /// No description provided for @emailShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get emailShares;

  /// No description provided for @emailSharesHint.
  ///
  /// In en, this message translates to:
  /// **'When someone shares a file or folder with you'**
  String get emailSharesHint;

  /// No description provided for @emailAlwaysSent.
  ///
  /// In en, this message translates to:
  /// **'Password resets and password changes are always emailed.'**
  String get emailAlwaysSent;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @newUserEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Gets a welcome email, and lets the user reset a forgotten password'**
  String get newUserEmailHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Not an email address'**
  String get invalidEmail;

  /// No description provided for @waitingForBrowser.
  ///
  /// In en, this message translates to:
  /// **'Finish signing in in your browser'**
  String get waitingForBrowser;

  /// No description provided for @signInOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// No description provided for @signInWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider}'**
  String signInWithProvider(String provider);

  /// No description provided for @signInWithAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another device'**
  String get signInWithAnotherDevice;

  /// No description provided for @twoFactorCodePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get twoFactorCodePrompt;

  /// No description provided for @twoFactorRecoveryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter one of your recovery codes. Each code works once.'**
  String get twoFactorRecoveryPrompt;

  /// No description provided for @authenticatorCode.
  ///
  /// In en, this message translates to:
  /// **'Authentication code'**
  String get authenticatorCode;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @approveOnAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Approve on another device instead'**
  String get approveOnAnotherDevice;

  /// No description provided for @useRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code'**
  String get useRecoveryCode;

  /// No description provided for @useAuthenticatorCode.
  ///
  /// In en, this message translates to:
  /// **'Use the authenticator app'**
  String get useAuthenticatorCode;

  /// No description provided for @deviceApprovalPrompt.
  ///
  /// In en, this message translates to:
  /// **'Open Polder on a device where you\'re signed in and type this number:'**
  String get deviceApprovalPrompt;

  /// No description provided for @deviceApprovalHint.
  ///
  /// In en, this message translates to:
  /// **'The request only reaches devices with Polder open.'**
  String get deviceApprovalHint;

  /// No description provided for @loginErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired.'**
  String get loginErrorInvalidCode;

  /// No description provided for @loginErrorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get loginErrorTooManyAttempts;

  /// No description provided for @loginErrorApprovalDenied.
  ///
  /// In en, this message translates to:
  /// **'The sign-in was refused on your other device.'**
  String get loginErrorApprovalDenied;

  /// No description provided for @loginErrorApprovalExpired.
  ///
  /// In en, this message translates to:
  /// **'No device approved the sign-in in time.'**
  String get loginErrorApprovalExpired;

  /// No description provided for @loginErrorSsoSignupDisabled.
  ///
  /// In en, this message translates to:
  /// **'There\'s no account for you on this server yet. Ask your administrator to create one or to link it.'**
  String get loginErrorSsoSignupDisabled;

  /// No description provided for @loginErrorSsoLinkRequired.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists. Sign in with its password, then connect this provider under Settings → Account.'**
  String get loginErrorSsoLinkRequired;

  /// No description provided for @loginErrorSsoFailed.
  ///
  /// In en, this message translates to:
  /// **'Signing in with the provider didn\'t work. Try again or ask your administrator.'**
  String get loginErrorSsoFailed;

  /// No description provided for @loginApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in request'**
  String get loginApprovalTitle;

  /// No description provided for @loginApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'{device} wants to sign in to your account from {address}.'**
  String loginApprovalBody(String device, String address);

  /// No description provided for @loginApprovalTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Type the number shown on that device'**
  String get loginApprovalTypeNumber;

  /// No description provided for @loginApprovalApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get loginApprovalApprove;

  /// No description provided for @loginApprovalDeny.
  ///
  /// In en, this message translates to:
  /// **'It wasn\'t me'**
  String get loginApprovalDeny;

  /// No description provided for @loginApprovalWrongNumber.
  ///
  /// In en, this message translates to:
  /// **'That wasn\'t the right number, so the sign-in was refused.'**
  String get loginApprovalWrongNumber;

  /// No description provided for @loginApprovalNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{device} wants to sign in'**
  String loginApprovalNotificationTitle(String device);

  /// No description provided for @loginApprovalNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Open Polder to approve or refuse the sign-in from {address}.'**
  String loginApprovalNotificationBody(String address);

  /// No description provided for @notificationChannelSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get notificationChannelSecurity;

  /// No description provided for @twoFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get twoFactorTitle;

  /// No description provided for @twoFactorOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get twoFactorOn;

  /// No description provided for @twoFactorOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get twoFactorOff;

  /// No description provided for @twoFactorOffHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for a code from an authenticator app when signing in with your password.'**
  String get twoFactorOffHint;

  /// No description provided for @twoFactorRequiredBy.
  ///
  /// In en, this message translates to:
  /// **'Required by your administrator before {date}'**
  String twoFactorRequiredBy(String date);

  /// No description provided for @twoFactorRequiredByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your administrator requires it'**
  String get twoFactorRequiredByAdmin;

  /// No description provided for @recoveryCodesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recovery code left} other{{count} recovery codes left}}'**
  String recoveryCodesLeft(int count);

  /// No description provided for @regenerateRecoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'New recovery codes'**
  String get regenerateRecoveryCodes;

  /// No description provided for @regenerateRecoveryCodesHint.
  ///
  /// In en, this message translates to:
  /// **'Your current recovery codes stop working.'**
  String get regenerateRecoveryCodesHint;

  /// No description provided for @turnOffTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Turn off two-factor authentication'**
  String get turnOffTwoFactor;

  /// No description provided for @turnOffTwoFactorHint.
  ///
  /// In en, this message translates to:
  /// **'Signing in will only need your password again.'**
  String get turnOffTwoFactorHint;

  /// No description provided for @twoFactorSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up two-factor authentication'**
  String get twoFactorSetupTitle;

  /// No description provided for @twoFactorSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to start.'**
  String get twoFactorSetupIntro;

  /// No description provided for @twoFactorContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get twoFactorContinue;

  /// No description provided for @twoFactorScanIntro.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with an authenticator app such as Aegis, 2FAS or Google Authenticator, then enter the code it shows.'**
  String get twoFactorScanIntro;

  /// No description provided for @twoFactorOpenAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Open in authenticator app'**
  String get twoFactorOpenAuthenticator;

  /// No description provided for @twoFactorManualKey.
  ///
  /// In en, this message translates to:
  /// **'Or enter this key'**
  String get twoFactorManualKey;

  /// No description provided for @twoFactorCodeMismatch.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t match. Check the time on your device and try again.'**
  String get twoFactorCodeMismatch;

  /// No description provided for @recoveryCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your recovery codes'**
  String get recoveryCodesTitle;

  /// No description provided for @recoveryCodesIntro.
  ///
  /// In en, this message translates to:
  /// **'If you lose your phone, each of these codes lets you sign in once. Keep them somewhere safe; you won\'t see them again.'**
  String get recoveryCodesIntro;

  /// No description provided for @copyRecoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'Copy codes'**
  String get copyRecoveryCodes;

  /// No description provided for @recoveryCodesSaved.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved them'**
  String get recoveryCodesSaved;

  /// No description provided for @setUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setUp;

  /// No description provided for @twoFactorDeadlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Set up two-factor authentication before {date}.'**
  String twoFactorDeadlineBanner(String date);

  /// No description provided for @twoFactorRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication is required'**
  String get twoFactorRequiredTitle;

  /// No description provided for @twoFactorRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your administrator requires it for every account. Set it up to keep using Polder.'**
  String get twoFactorRequiredBody;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get setPassword;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected accounts'**
  String get connectedAccounts;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @unlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink {provider}?'**
  String unlinkTitle(String provider);

  /// No description provided for @unlinkMessage.
  ///
  /// In en, this message translates to:
  /// **'You can no longer sign in with {provider} until you connect it again.'**
  String unlinkMessage(String provider);

  /// No description provided for @ssoAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'That account is already linked to someone else.'**
  String get ssoAlreadyLinked;

  /// No description provided for @adminAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get adminAuthentication;

  /// No description provided for @adminAuthenticationHint.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication and single sign-on'**
  String get adminAuthenticationHint;

  /// No description provided for @requireTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Require two-factor authentication'**
  String get requireTwoFactor;

  /// No description provided for @requireTwoFactorHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone who signs in with a password must set it up. Single sign-on is exempt.'**
  String get requireTwoFactorHint;

  /// No description provided for @requireTwoFactorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Everyone without it gets an email and has {days, plural, =0{to set it up right away} =1{1 day to set it up} other{{days} days to set it up}}. After that, they can only set it up.'**
  String requireTwoFactorConfirm(int days);

  /// No description provided for @require.
  ///
  /// In en, this message translates to:
  /// **'Require'**
  String get require;

  /// No description provided for @twoFactorGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get twoFactorGracePeriod;

  /// No description provided for @twoFactorGracePeriodHint.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{No grace period} =1{1 day to set it up} other{{days} days to set it up}}; changes apply to new deadlines'**
  String twoFactorGracePeriodHint(int days);

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @twoFactorNoMailWarning.
  ///
  /// In en, this message translates to:
  /// **'No mail server is set up, so users won\'t get an email about the deadline. They\'ll still see it in the apps.'**
  String get twoFactorNoMailWarning;

  /// No description provided for @singleSignOn.
  ///
  /// In en, this message translates to:
  /// **'Single sign-on'**
  String get singleSignOn;

  /// No description provided for @singleSignOnHint.
  ///
  /// In en, this message translates to:
  /// **'Let people sign in with an identity provider such as Pocket ID, authentik, Keycloak, Google, Microsoft or GitHub.'**
  String get singleSignOnHint;

  /// No description provided for @addProvider.
  ///
  /// In en, this message translates to:
  /// **'Add provider'**
  String get addProvider;

  /// No description provided for @addProviderNamed.
  ///
  /// In en, this message translates to:
  /// **'Add {provider}'**
  String addProviderNamed(String provider);

  /// No description provided for @noProviders.
  ///
  /// In en, this message translates to:
  /// **'No providers yet'**
  String get noProviders;

  /// No description provided for @managedByConfig.
  ///
  /// In en, this message translates to:
  /// **'Set in the server config'**
  String get managedByConfig;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No linked accounts} =1{1 linked account} other{{count} linked accounts}}'**
  String linkedAccounts(int count);

  /// No description provided for @providerManagedByConfigHint.
  ///
  /// In en, this message translates to:
  /// **'This provider is set in the server config. You can only turn it on or off here.'**
  String get providerManagedByConfigHint;

  /// No description provided for @buttonLabel.
  ///
  /// In en, this message translates to:
  /// **'Button label'**
  String get buttonLabel;

  /// No description provided for @issuerUrl.
  ///
  /// In en, this message translates to:
  /// **'Issuer URL'**
  String get issuerUrl;

  /// No description provided for @clientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get clientId;

  /// No description provided for @clientSecret.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get clientSecret;

  /// No description provided for @clientSecretKept.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the stored secret'**
  String get clientSecretKept;

  /// No description provided for @callbackUrl.
  ///
  /// In en, this message translates to:
  /// **'Callback URL'**
  String get callbackUrl;

  /// No description provided for @providerServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get providerServerUrl;

  /// No description provided for @providerRealm.
  ///
  /// In en, this message translates to:
  /// **'Realm'**
  String get providerRealm;

  /// No description provided for @providerSlug.
  ///
  /// In en, this message translates to:
  /// **'Application slug'**
  String get providerSlug;

  /// No description provided for @providerTenantId.
  ///
  /// In en, this message translates to:
  /// **'Tenant ID'**
  String get providerTenantId;

  /// No description provided for @identityProvider.
  ///
  /// In en, this message translates to:
  /// **'the identity provider'**
  String get identityProvider;

  /// No description provided for @providerUrlNamed.
  ///
  /// In en, this message translates to:
  /// **'{provider} URL'**
  String providerUrlNamed(String provider);

  /// No description provided for @providerTenantIdHint.
  ///
  /// In en, this message translates to:
  /// **'Your directory (tenant) ID, or common, organizations or consumers to allow other directories'**
  String get providerTenantIdHint;

  /// No description provided for @callbackUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste this at {provider} under “{field}”'**
  String callbackUrlHint(String provider, String field);

  /// No description provided for @providerAllowSignup.
  ///
  /// In en, this message translates to:
  /// **'Create accounts'**
  String get providerAllowSignup;

  /// No description provided for @providerAllowSignupHint.
  ///
  /// In en, this message translates to:
  /// **'People without an account get one when they first sign in'**
  String get providerAllowSignupHint;

  /// No description provided for @providerLinkByEmail.
  ///
  /// In en, this message translates to:
  /// **'Match by email address'**
  String get providerLinkByEmail;

  /// No description provided for @providerLinkByEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the existing account with the same verified email address'**
  String get providerLinkByEmailHint;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testConnection;

  /// No description provided for @providerTestOk.
  ///
  /// In en, this message translates to:
  /// **'The provider answered correctly.'**
  String get providerTestOk;

  /// No description provided for @providerTestFailed.
  ///
  /// In en, this message translates to:
  /// **'The provider can\'t be reached: {reason}'**
  String providerTestFailed(String reason);

  /// No description provided for @deleteProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {provider}?'**
  String deleteProviderTitle(String provider);

  /// No description provided for @deleteProviderMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The sign-in button disappears.} =1{The sign-in button disappears and 1 account is unlinked. Accounts without a password can then no longer sign in.} other{The sign-in button disappears and {count} accounts are unlinked. Accounts without a password can then no longer sign in.}}'**
  String deleteProviderMessage(int count);

  /// No description provided for @twoFactorTag.
  ///
  /// In en, this message translates to:
  /// **'2FA'**
  String get twoFactorTag;

  /// No description provided for @twoFactorDueTag.
  ///
  /// In en, this message translates to:
  /// **'2FA due {date}'**
  String twoFactorDueTag(String date);

  /// No description provided for @twoFactorOverdueTag.
  ///
  /// In en, this message translates to:
  /// **'2FA overdue'**
  String get twoFactorOverdueTag;

  /// No description provided for @ssoTag.
  ///
  /// In en, this message translates to:
  /// **'SSO'**
  String get ssoTag;

  /// No description provided for @resetTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Reset two-factor'**
  String get resetTwoFactor;

  /// No description provided for @resetTwoFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset two-factor authentication for {username}?'**
  String resetTwoFactorTitle(String username);

  /// No description provided for @resetTwoFactorMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this when they lost their authenticator app. They\'re signed out everywhere and can set it up again.'**
  String get resetTwoFactorMessage;

  /// No description provided for @extendTwoFactorDeadline.
  ///
  /// In en, this message translates to:
  /// **'Give more time for 2FA'**
  String get extendTwoFactorDeadline;

  /// No description provided for @settingsApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get settingsApps;

  /// No description provided for @settingsAppsHint.
  ///
  /// In en, this message translates to:
  /// **'How Files, Notes and Calendar show up'**
  String get settingsAppsHint;

  /// No description provided for @settingsAppsIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose per part of Polder whether it lives inside this app, opens its own app, or stays out of the way. Polder only sends notifications for the parts that are built in.'**
  String get settingsAppsIntro;

  /// No description provided for @featureModeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get featureModeAutomatic;

  /// No description provided for @featureModeAutomaticOpens.
  ///
  /// In en, this message translates to:
  /// **'Opens {app}, which is installed on this device'**
  String featureModeAutomaticOpens(String app);

  /// No description provided for @featureModeAutomaticBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built in, until {app} is installed on this device'**
  String featureModeAutomaticBuiltIn(String app);

  /// No description provided for @featureModeBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built in'**
  String get featureModeBuiltIn;

  /// No description provided for @featureModeBuiltInHint.
  ///
  /// In en, this message translates to:
  /// **'Shown inside Polder, with its notifications'**
  String get featureModeBuiltInHint;

  /// No description provided for @featureModeOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get featureModeOpenApp;

  /// No description provided for @featureModeOpenAppHint.
  ///
  /// In en, this message translates to:
  /// **'Opens {app}; Polder sends no notifications for it'**
  String featureModeOpenAppHint(String app);

  /// No description provided for @featureModeHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get featureModeHidden;

  /// No description provided for @featureModeHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'Not shown in Polder, and no notifications'**
  String get featureModeHiddenHint;

  /// No description provided for @companionAppUnavailable.
  ///
  /// In en, this message translates to:
  /// **'That app could not be opened'**
  String get companionAppUnavailable;
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
