// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get about => 'Over';

  @override
  String get aboutCreatedBy => 'Gemaakt door DonutWare';

  @override
  String get aboutHint => 'Versie, licenties en het project steunen';

  @override
  String get aboutLegalese => 'Creëer je eigen privé-polder en synchroniseer je bestanden.';

  @override
  String get aboutLicenses => 'Licenties';

  @override
  String get aboutSocials => 'Sociaal';

  @override
  String aboutVersion(String version) {
    return 'Application versie $version';
  }

  @override
  String aboutServerInfo(String version, String buildNumber) {
    return 'Server $version ($buildNumber)';
  }

  @override
  String get accentBlue => 'Blauw';

  @override
  String get accentColor => 'Accentkleur';

  @override
  String get accentCustomHint => 'Statuskleuren zijn afgestemd op je accentkleur.';

  @override
  String get accentGreen => 'Groen';

  @override
  String get accentNoSystemHint =>
      'Dit apparaat heeft geen accentkleur om te volgen, dus de standaardkleur wordt gebruikt.';

  @override
  String get accentOrange => 'Oranje';

  @override
  String get accentPolder => 'Polder';

  @override
  String get accentRose => 'Roze';

  @override
  String get accentSlate => 'Leisteen';

  @override
  String get accentSystemHint => 'Volgt de accentkleur van je apparaat.';

  @override
  String get accentTeal => 'Groenblauw';

  @override
  String get accentViolet => 'Violet';

  @override
  String get account => 'Account';

  @override
  String get add => 'Toevoegen';

  @override
  String get addAutoUploadFolder => 'Map toevoegen';

  @override
  String get addSyncFolder => 'Synchronisatiemap toevoegen';

  @override
  String get addUser => 'Gebruiker toevoegen';

  @override
  String get addUserHint => 'Een account met eigen opslag aanmaken';

  @override
  String adminAccountsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count beheerders', one: '1 beheerder');
    return '$_temp0';
  }

  @override
  String get adminDisabledCaption => 'Kunnen niet inloggen';

  @override
  String get administration => 'Beheer';

  @override
  String get administrationHint => 'Gebruikers en serverbeheer';

  @override
  String get adminNearQuota => 'Bijna vol';

  @override
  String get adminNearQuotaCaption => 'Meer dan 90% van hun quotum';

  @override
  String get adminOverview => 'Overzicht';

  @override
  String get adminOverviewHint => 'Opslag en gebruik in één oogopslag';

  @override
  String get adminStorageCaption => 'Over alle accounts';

  @override
  String get adminStorageUsed => 'Gebruikte opslag';

  @override
  String get appearance => 'Weergave';

  @override
  String applyToAll(int count) {
    return 'Mijn keuze toepassen op alle $count conflicten';
  }

  @override
  String get appTitle => 'Polder';

  @override
  String get autoUploadDescription => 'Nieuwe foto\'s en bestanden uit de gekozen mappen automatisch uploaden.';

  @override
  String get autoUploadEnabled => 'Automatisch uploaden';

  @override
  String get cancel => 'Annuleren';

  @override
  String get change => 'Wijzigen';

  @override
  String get chargingOnly => 'Alleen tijdens opladen';

  @override
  String get choose => 'Kiezen';

  @override
  String get chooseServerFolder => 'Kies een map op de server';

  @override
  String get chooseThisFolder => 'Deze map kiezen';

  @override
  String get clearFinished => 'Voltooide wissen';

  @override
  String get collapseSidebar => 'Zijbalk inklappen';

  @override
  String get conflictBothCreated => 'Aan beide kanten is een ander bestand met deze naam gemaakt.';

  @override
  String get conflictBothModified => 'Gewijzigd op dit apparaat en op de server.';

  @override
  String get conflictLocalDeletedRemoteModified => 'Verwijderd op dit apparaat maar gewijzigd op de server.';

  @override
  String get conflictLocalModifiedRemoteDeleted => 'Gewijzigd op dit apparaat maar verwijderd op de server.';

  @override
  String get conflicts => 'Conflicten';

  @override
  String conflictsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicten wachten op je keuze',
      one: '1 conflict wacht op je keuze',
    );
    return '$_temp0';
  }

  @override
  String get connect => 'Verbinden';

  @override
  String get create => 'Maken';

  @override
  String get createAdmin => 'Beheerder aanmaken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleted => 'Verwijderd';

  @override
  String get deletePermanently => 'Definitief verwijderen';

  @override
  String get deletePermanentlyMessage => 'Het kan daarna niet meer worden teruggezet.';

  @override
  String deletePermanentlyTitle(String name) {
    return '\"$name\" definitief verwijderen?';
  }

  @override
  String get deleteMessage => 'Het wordt naar de prullenbak op de server verplaatst.';

  @override
  String deleteTitle(String name) {
    return '\"$name\" verwijderen?';
  }

  @override
  String get deleteUserMessage =>
      'Het account wordt verwijderd. De bestanden blijven op de schijf van de server bewaard.';

  @override
  String deleteUserTitle(String username) {
    return 'Gebruiker \"$username\" verwijderen?';
  }

  @override
  String dimensions(int width, int height) {
    return '$width × $height';
  }

  @override
  String get dimensionsLabel => 'Afmetingen';

  @override
  String get disabled => 'Uitgeschakeld';

  @override
  String get done => 'Klaar';

  @override
  String get download => 'Downloaden';

  @override
  String get edit => 'Bewerken';

  @override
  String editUser(String username) {
    return '$username bewerken';
  }

  @override
  String get emptyFolder => 'Deze map is leeg';

  @override
  String get emptyTrash => 'Prullenbak legen';

  @override
  String get emptyTrashMessage =>
      'Alles in de prullenbak wordt definitief verwijderd. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get emptyTrashTitle => 'Prullenbak legen?';

  @override
  String get errorAlreadyExists => 'Er bestaat al iets met die naam.';

  @override
  String get errorConflict => 'Het is gewijzigd sinds het laatst werd geladen. Vernieuw en probeer het opnieuw.';

  @override
  String get errorForbidden => 'Je hebt hier geen toestemming voor.';

  @override
  String get errorReauthenticationRequired => 'Log voor je veiligheid uit en opnieuw in, en probeer het dan nog eens.';

  @override
  String get errorInvalidRequest => 'Het verzoek was ongeldig.';

  @override
  String errorLocalFolderMissing(String path) {
    return 'De lokale map $path ontbreekt.';
  }

  @override
  String get errorNetwork => 'Kan de server niet bereiken.';

  @override
  String get errorNotFound => 'Het bestaat niet meer.';

  @override
  String get errorQuotaExceeded => 'Je opslagquotum is vol.';

  @override
  String get errorRateLimited => 'Te veel pogingen. Wacht even en probeer het opnieuw.';

  @override
  String get errorUnauthorized => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get errorUnavailable => 'De server is bezet. Probeer het zo opnieuw.';

  @override
  String get errorPreconditionFailed => 'Het is op de server gewijzigd terwijl dit bezig was.';

  @override
  String errorServer(String status) {
    return 'De server liep tegen een fout aan (HTTP $status).';
  }

  @override
  String get errorUnknown => 'De app liep tegen een onverwachte fout aan.';

  @override
  String get expandSidebar => 'Zijbalk uitklappen';

  @override
  String get folders => 'Mappen';

  @override
  String get generalSettings => 'Algemeen';

  @override
  String get generalSettingsHint => 'Prullenbak en bestandsversies';

  @override
  String get gridView => 'Rasterweergave';

  @override
  String get keepBoth => 'Beide behouden';

  @override
  String get keepMine => 'Mijn versie behouden';

  @override
  String get keepServer => 'Serverversie behouden';

  @override
  String lastSynced(String time) {
    return 'Laatst gesynchroniseerd $time';
  }

  @override
  String get listView => 'Lijstweergave';

  @override
  String get localFolder => 'Map op dit apparaat';

  @override
  String get loginErrorDisabled => 'Dit account is uitgeschakeld.';

  @override
  String get loginErrorInvalidCredentials => 'Onjuiste gebruikersnaam of wachtwoord.';

  @override
  String get loginErrorSetupUnavailable => 'Deze server is al ingesteld.';

  @override
  String get loginErrorUnreachable => 'Geen Polder-server bereikbaar op dit adres.';

  @override
  String get loginServerIntro => 'Voer het adres van je Polder-server in.';

  @override
  String get management => 'Beheertaken';

  @override
  String get manageUsersHint => 'Accounts, rollen en quota';

  @override
  String get modified => 'Gewijzigd';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get move => 'Verplaatsen';

  @override
  String get name => 'Naam';

  @override
  String get navAutoUpload => 'Automatisch uploaden';

  @override
  String get navFiles => 'Bestanden';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get navSync => 'Synchronisatie';

  @override
  String get navTrash => 'Prullenbak';

  @override
  String get newFolder => 'Nieuwe map';

  @override
  String get newPasswordOptional => 'Nieuw wachtwoord (leeg laten om te behouden)';

  @override
  String get noConflicts => 'Geen conflicten. Alles is gesynchroniseerd.';

  @override
  String get noFolders => 'Nog geen mappen.';

  @override
  String get notChosen => 'Niet gekozen';

  @override
  String get noUsers => 'Nog geen gebruikers.';

  @override
  String get ocrLanguagesLabel => 'Tesseract-modellen, gescheiden door komma\'s, zoals eng, jpn of script/Latin';

  @override
  String get ocrLanguagesSetting => 'Talen en schriften';

  @override
  String ocrMaxPagesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'OCR leest hoogstens $count pagina\'s van elke pdf',
      one: 'OCR leest hoogstens 1 pagina van elke pdf',
    );
    return '$_temp0';
  }

  @override
  String get ocrMaxPagesLabel => 'Pagina\'s';

  @override
  String get ocrMaxPagesSetting => 'Pagina\'s per pdf';

  @override
  String get ocrSetting => 'Tekst in afbeeldingen en scans herkennen';

  @override
  String get ocrSettingHint =>
      'Leest foto\'s en gescande pdf-pagina\'s met OCR. Dit is traag en gebeurt op de achtergrond.';

  @override
  String ocrUnavailable(String reason) {
    return 'OCR is niet beschikbaar: $reason';
  }

  @override
  String get overwrite => 'Overschrijven';

  @override
  String get password => 'Wachtwoord';

  @override
  String get quota => 'Quotum';

  @override
  String get quotaInvalid => 'Voer een getal van 0 of hoger in';

  @override
  String get quotaUnlimitedHint => '0 betekent onbeperkt';

  @override
  String quotaUsedOf(String used, String total) {
    return '$used van $total gebruikt';
  }

  @override
  String quotaUsedUnlimited(String used) {
    return '$used gebruikt';
  }

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get remove => 'Verwijderen';

  @override
  String get removeSyncFolderMessage => 'De map wordt niet meer gesynchroniseerd. Er worden geen bestanden verwijderd.';

  @override
  String get removeSyncFolderTitle => 'Deze map verwijderen?';

  @override
  String get rename => 'Hernoemen';

  @override
  String get resolve => 'Oplossen';

  @override
  String get restore => 'Terugzetten';

  @override
  String restoreConflictMessage(String path) {
    return 'Er staat al iets op $path. Overschrijven verplaatst dat naar de prullenbak, Beide behouden zet dit item ernaast terug onder een nieuwe naam.';
  }

  @override
  String restoreConflictTitle(String name) {
    return '\"$name\" bestaat al';
  }

  @override
  String restoredTo(String path) {
    return 'Teruggezet naar $path';
  }

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String revisionShort(int rev) {
    return 'Revisie $rev';
  }

  @override
  String get roleAdmin => 'Beheerder';

  @override
  String get roleUser => 'Gebruiker';

  @override
  String get rootFolder => 'Bestanden';

  @override
  String get save => 'Opslaan';

  @override
  String get searchAddFilterButton => 'Filter';

  @override
  String get searchChooseFolder => 'Kies map';

  @override
  String get searchClear => 'Wissen';

  @override
  String searchContentPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count bestanden te lezen',
      one: 'Nog 1 bestand te lezen',
    );
    return '$_temp0';
  }

  @override
  String get searchContentSetting => 'In bestanden zoeken';

  @override
  String get searchContentSettingHint =>
      'Leest de tekst in documenten, pdf\'s en afbeeldingen zodat zoeken die kan vinden.';

  @override
  String get searchCustomSize => 'Andere grootte, zoals 250mb';

  @override
  String get searchCustomType => 'Ander type of extensie, zoals heic';

  @override
  String searchDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen geleden',
      one: '1 dag geleden',
    );
    return '$_temp0';
  }

  @override
  String get searchFieldFolder => 'Map';

  @override
  String get searchFieldModified => 'Gewijzigd';

  @override
  String get searchFieldSize => 'Grootte';

  @override
  String get searchFieldType => 'Type';

  @override
  String searchEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count afspraken', one: '1 afspraak');
    return '$_temp0';
  }

  @override
  String get searchMoreEvents => 'Meer afspraken tonen';

  @override
  String get searchFieldCalendar => 'Agenda';

  @override
  String get searchFieldRepeats => 'Herhaling';

  @override
  String get searchFieldWhen => 'Wanneer';

  @override
  String get searchRepeatYes => 'herhalend';

  @override
  String get searchRepeatNo => 'eenmalig';

  @override
  String get searchRepeatDaily => 'dagelijks';

  @override
  String get searchRepeatWeekly => 'wekelijks';

  @override
  String get searchRepeatMonthly => 'maandelijks';

  @override
  String get searchRepeatYearly => 'jaarlijks';

  @override
  String get searchWhenUpcoming => 'komend';

  @override
  String get searchWhenPast => 'voorbij';

  @override
  String get searchEventPast => 'Voorbij';

  @override
  String get searchOpenInCalendar => 'Openen in agenda';

  @override
  String searchFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count bestanden', one: '1 bestand');
    return '$_temp0';
  }

  @override
  String get searchFilterAdd => 'Filter toevoegen';

  @override
  String get searchFilterValues => 'Waarden';

  @override
  String get searchGoTo => 'Ga naar';

  @override
  String get searchHint => 'Zoek bestanden, mappen en pagina\'s';

  @override
  String get searchKeywordsAbout => 'versie, licenties, info';

  @override
  String get searchKeywordsActivity => 'geschiedenis, logboek, uploads, downloads, overdrachten, sessies, apparaten';

  @override
  String get searchKeywordsAdmin => 'admin, server, beheer, bewaartermijn, opslag, ocr, tekstherkenning, zoeken';

  @override
  String get searchKeywordsAdminUsers => 'accounts, gebruikers, mensen, leden, quotum';

  @override
  String get searchKeywordsAutoUpload => 'camera, foto\'s, back-up, galerij';

  @override
  String get searchKeywordsConflicts => 'conflict, oplossen, versies';

  @override
  String get searchKeywordsFiles => 'bladeren, documenten, start, opslag';

  @override
  String get searchKeywordsSettings => 'voorkeuren, weergave, thema, account, taal, wachtwoord';

  @override
  String get searchKeywordsSync => 'mappen, synchronisatie, desktop, spiegelen';

  @override
  String get searchKeywordsTrash => 'verwijderd, prullenbak, herstellen, prullenmand';

  @override
  String searchMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden geleden',
      one: '1 maand geleden',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'Niets gevonden';

  @override
  String get searchOpAfter => 'na';

  @override
  String get searchOpAtLeast => 'minstens';

  @override
  String get searchOpAtMost => 'hoogstens';

  @override
  String get searchOpBefore => 'voor';

  @override
  String get searchOpBetween => 'tussen';

  @override
  String get searchOpFrom => 'vanaf';

  @override
  String get searchOpIs => 'is';

  @override
  String get searchOpIsNot => 'is niet';

  @override
  String get searchOpLarger => 'groter dan';

  @override
  String get searchOpOn => 'op';

  @override
  String get searchOpSmaller => 'kleiner dan';

  @override
  String get searchOpUntil => 'tot en met';

  @override
  String get searchPickDate => 'Kies een datum';

  @override
  String get searchPickRange => 'Kies data';

  @override
  String get searchPresetToday => 'vandaag';

  @override
  String get searchPresetYesterday => 'gisteren';

  @override
  String searchRange(String from, String to) {
    return '$from en $to';
  }

  @override
  String get searchShowInFolder => 'Toon in map';

  @override
  String get searchSizeFrom => 'Van';

  @override
  String get searchSizeTo => 'Tot';

  @override
  String get searchSyncConflicts => 'Synchronisatieconflicten';

  @override
  String get searchTipsBody =>
      'Typ een deel van een naam, ook met tikfouten. Voeg tags toe zoals type=pdf, modified>7d of size>100mb, gebruik != om iets uit te sluiten, of kies er een via Filter. type=event zoekt in je agenda, met repeats=no of when=upcoming om het te verfijnen.';

  @override
  String get searchTipsTitle => 'Zoek gerichter';

  @override
  String searchTooltip(String shortcut) {
    return 'Zoeken ($shortcut)';
  }

  @override
  String searchWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weken geleden',
      one: '1 week geleden',
    );
    return '$_temp0';
  }

  @override
  String searchYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jaar geleden',
      one: '1 jaar geleden',
    );
    return '$_temp0';
  }

  @override
  String get server => 'Server';

  @override
  String get serverFolder => 'Map op de server';

  @override
  String get serverSearchGroup => 'Zoeken';

  @override
  String get serverSettings => 'Serverinstellingen';

  @override
  String get serverSettingsHint => 'Prullenbak, versies, zoeken, voorbeelden en federatie';

  @override
  String get serverTrashRetention => 'Bewaartermijn prullenbak';

  @override
  String serverTrashRetentionHint(String duration) {
    return 'Standaard en maximum voor alle gebruikers: $duration';
  }

  @override
  String get serverUrl => 'Serveradres';

  @override
  String get serverUrlHint => 'https://cloud.voorbeeld.nl';

  @override
  String get setupIntro => 'Deze server heeft nog geen gebruikers. Maak het eerste beheerdersaccount aan.';

  @override
  String get signIn => 'Inloggen';

  @override
  String get signOut => 'Uitloggen';

  @override
  String signOutMessage(String username, String server) {
    return '$username uitloggen bij $server?';
  }

  @override
  String get size => 'Grootte';

  @override
  String get sponsor => 'Sponsors';

  @override
  String get sponsorMessage =>
      'Als je Polder graag gebruikt, overweeg dan om het project te sponsoren ter ondersteuning van voortdurende ontwikkeling en verbeteringen. Bedankt voor je steun!';

  @override
  String get storageByUser => 'Opslag per gebruiker';

  @override
  String syncedWith(String remotePath) {
    return 'Gesynchroniseerd met $remotePath';
  }

  @override
  String get syncError => 'Synchronisatie voltooid met fouten';

  @override
  String get syncFolders => 'Synchronisatiemappen';

  @override
  String get syncIdle => 'Bijgewerkt';

  @override
  String get syncNow => 'Nu synchroniseren';

  @override
  String get syncRunning => 'Bezig met synchroniseren…';

  @override
  String get syncUnsupported => 'Mapsynchronisatie is niet beschikbaar op dit platform.';

  @override
  String get systemAccentUnavailable => 'Systeem (niet beschikbaar op dit apparaat)';

  @override
  String get takenAt => 'Gemaakt op';

  @override
  String get theme => 'Thema';

  @override
  String get themeDark => 'Donker';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get thisDevice => 'Dit apparaat';

  @override
  String get transferDone => 'Klaar';

  @override
  String get transfers => 'Overdrachten';

  @override
  String get trashEmpty => 'De prullenbak is leeg';

  @override
  String trashItemDeleted(String date) {
    return 'Verwijderd $date';
  }

  @override
  String trashItemExpires(String date) {
    return 'Definitief verwijderd op $date';
  }

  @override
  String trashItemFrom(String folder) {
    return 'Uit $folder';
  }

  @override
  String get trashRetention => 'Verwijderde items bewaren';

  @override
  String trashRetentionDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dagen', one: '1 dag');
    return '$_temp0';
  }

  @override
  String get trashRetentionForever => 'Altijd';

  @override
  String get trashRetentionForeverHint => 'Items blijven in de prullenbak tot je ze verwijdert.';

  @override
  String trashRetentionHint(String duration) {
    return 'Items in de prullenbak worden na $duration definitief verwijderd.';
  }

  @override
  String trashRetentionServerDefault(String duration) {
    return 'Serverstandaard ($duration)';
  }

  @override
  String trashSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0 · $size';
  }

  @override
  String get type => 'Type';

  @override
  String get unit => 'Eenheid';

  @override
  String get uploadFiles => 'Bestanden uploaden';

  @override
  String get uploadHere => 'Hier uploaden';

  @override
  String uploadSharedFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gedeelde bestanden uploaden',
      one: 'Gedeeld bestand uploaden',
    );
    return '$_temp0';
  }

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get users => 'Gebruikers';

  @override
  String usersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count gebruikers', one: '1 gebruiker');
    return '$_temp0';
  }

  @override
  String get wifiOnly => 'Alleen via wifi';

  @override
  String get navActivity => 'Activiteit';

  @override
  String get activityNow => 'Nu';

  @override
  String get activityHistory => 'Geschiedenis';

  @override
  String get activityEmpty => 'Er is nog niets gebeurd.';

  @override
  String get nothingTransferring => 'Er wordt nu niets overgedragen.';

  @override
  String get activityScopeMe => 'Alleen ik';

  @override
  String get activityScopeAll => 'Alle gebruikers';

  @override
  String get activityScopeChooseUser => 'Kies een gebruiker…';

  @override
  String get activityScopeTooltip => 'Van wie de activiteit wordt getoond';

  @override
  String get chooseUserTitle => 'Activiteit tonen van';

  @override
  String get activityAllFiles => 'Alle bestanden';

  @override
  String get activityKindUpload => 'Geüpload';

  @override
  String get activityKindDownload => 'Gedownload';

  @override
  String get activityKindMkdir => 'Map gemaakt';

  @override
  String get activityKindMove => 'Verplaatst';

  @override
  String get activityKindDelete => 'Naar prullenbak verplaatst';

  @override
  String get activityKindRestore => 'Teruggezet uit prullenbak';

  @override
  String get activityKindTrashDelete => 'Definitief verwijderd';

  @override
  String get activityKindTrashEmpty => 'Prullenbak geleegd';

  @override
  String get activityKindTrashExpire => 'Oude items uit prullenbak verwijderd';

  @override
  String get activityKindLogin => 'Aangemeld';

  @override
  String get activityKindLogout => 'Afgemeld';

  @override
  String get activityKindUnknown => 'Er is iets gebeurd';

  @override
  String get activityRescanAdded => 'Toegevoegd op de server';

  @override
  String get activityRescanChanged => 'Gewijzigd op de server';

  @override
  String get activityRescanRemoved => 'Verwijderd op de server';

  @override
  String activityRescanSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count wijzigingen', one: '1 wijziging');
    return '$_temp0 gevonden op de server';
  }

  @override
  String activityMovedFrom(String path) {
    return 'van $path';
  }

  @override
  String activityItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0';
  }

  @override
  String get activityFailed => 'Mislukt';

  @override
  String get activityCancelled => 'Geannuleerd';

  @override
  String durationSeconds(int count) {
    return '$count s';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get transferUploading => 'Uploaden';

  @override
  String get transferDownloading => 'Downloaden';

  @override
  String transferProgress(String done, String total) {
    return '$done van $total';
  }

  @override
  String get folderUploading => 'Uploaden…';

  @override
  String get folderDownloading => 'Downloaden…';

  @override
  String get realtimeOffline => 'Live updates gepauzeerd, opnieuw verbinden…';

  @override
  String get today => 'Vandaag';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get syncWaiting => 'Wacht op synchronisatie';

  @override
  String get syncPreparing => 'Voorbereiden voor synchronisatie';

  @override
  String get syncPaused => 'Synchronisatie gepauzeerd';

  @override
  String get pauseSync => 'Synchronisatie pauzeren';

  @override
  String get resumeSync => 'Synchronisatie hervatten';

  @override
  String get itemPaused => 'Gepauzeerd';

  @override
  String nowGroupFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count bestanden', one: '1 bestand');
    return '$_temp0';
  }

  @override
  String nowGroupProgress(int done, int total) {
    return '$done van $total bestanden';
  }

  @override
  String nowGroupUploading(int count) {
    return '$count uploaden';
  }

  @override
  String nowGroupDownloading(int count) {
    return '$count downloaden';
  }

  @override
  String nowGroupPreparing(int count) {
    return '$count voorbereiden';
  }

  @override
  String nowGroupWaiting(int count) {
    return '$count wachten';
  }

  @override
  String get showFiles => 'Bestanden tonen';

  @override
  String get hideFiles => 'Bestanden verbergen';

  @override
  String get uploadExistingFiles => 'Bestaande bestanden uploaden';

  @override
  String get uploadExistingFilesHint => 'Anders worden alleen bestanden geüpload die vanaf nu worden toegevoegd';

  @override
  String get storageAccessDenied =>
      'Polder heeft toegang tot je bestanden nodig om deze map te uploaden. Sta toegang tot alle bestanden, of in ieder geval foto\'s en video\'s, toe in de app-instellingen.';

  @override
  String get folderWillBeCreated => 'Deze map bestaat nog niet. Hij wordt aangemaakt.';

  @override
  String get trayUpToDate => 'Bijgewerkt';

  @override
  String get traySyncing => 'Synchroniseren…';

  @override
  String traySyncingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden synchroniseren',
      one: '1 bestand synchroniseren',
    );
    return '$_temp0';
  }

  @override
  String get traySyncPaused => 'Synchronisatie gepauzeerd';

  @override
  String get traySyncFailed => 'Synchronisatie mislukt';

  @override
  String get traySignedOut => 'Niet aangemeld';

  @override
  String get trayOpenApp => 'Polder openen';

  @override
  String get trayOpenSyncedFolders => 'Gesynchroniseerde mappen openen';

  @override
  String get trayOpenFiles => 'Bestanden openen';

  @override
  String get trayOpenCalendar => 'Agenda openen';

  @override
  String get trayOpenNotes => 'Notities openen';

  @override
  String get trayQuit => 'Polder afsluiten';

  @override
  String get trayNew => 'Nieuw';

  @override
  String get shortcutNewNote => 'Nieuwe notitie';

  @override
  String get shortcutEvent => 'Afspraak';

  @override
  String get shortcutChecklist => 'Checklist';

  @override
  String get shortcutSearch => 'Zoeken';

  @override
  String get quit => 'Afsluiten';

  @override
  String get quitWhileSyncingTitle => 'Afsluiten tijdens synchronisatie?';

  @override
  String get quitWhileSyncingMessage =>
      'Polder is nog aan het synchroniseren. Onvoltooide overdrachten gaan verder zodra je Polder weer opent.';

  @override
  String get newDocument => 'Nieuw document';

  @override
  String get reviewScan => 'Scan controleren';

  @override
  String get addPages => 'Pagina\'s toevoegen';

  @override
  String get removePage => 'Pagina verwijderen';

  @override
  String pageNumber(int number) {
    return 'Pagina $number';
  }

  @override
  String get scanFormatPdf => 'PDF';

  @override
  String get scanFormatImages => 'Afbeeldingen';

  @override
  String get scanSaveTo => 'Opslaan in';

  @override
  String get discard => 'Weggooien';

  @override
  String get discardScanTitle => 'Deze scan weggooien?';

  @override
  String get discardScanMessage => 'De gescande pagina\'s worden niet opgeslagen.';

  @override
  String get scanFailed => 'Het document kon niet worden gescand.';

  @override
  String get scanCameraDenied => 'Geef toegang tot de camera om documenten te scannen.';

  @override
  String get scanCameraOpenSettings => 'Instellingen openen';

  @override
  String get pages => 'Pagina\'s';

  @override
  String get details => 'Details';

  @override
  String get sortBy => 'Sorteren';

  @override
  String get sortAscending => 'Oplopend';

  @override
  String get sortDescending => 'Aflopend';

  @override
  String get sortFoldersFirst => 'Mappen bovenaan';

  @override
  String get indexingBanner => 'Bezig met indexeren… mappen vullen zich zodra bestanden gevonden zijn.';

  @override
  String get indexingEmptyFolder => 'Nog bezig met indexeren. Bestanden verschijnen hier zodra ze gevonden zijn.';

  @override
  String get serverLogs => 'Serverlogboek';

  @override
  String get serverLogsHint => 'Wat de server deed en elke fout die hij tegenkwam';

  @override
  String get logLevelDebug => 'Debug';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelWarn => 'Waarschuwingen';

  @override
  String get logLevelError => 'Fouten';

  @override
  String get logMinimumLevel => 'Minimaal niveau';

  @override
  String get logComponent => 'Onderdeel';

  @override
  String get logAllComponents => 'Alle onderdelen';

  @override
  String get logSearchHint => 'Zoek in berichten en details';

  @override
  String get logFollow => 'Nieuwe regels volgen';

  @override
  String get logStopFollowing => 'Stoppen met volgen';

  @override
  String get logDownload => 'Logbestand downloaden';

  @override
  String get logNoFiles => 'Nog geen logbestanden.';

  @override
  String get logsEmpty => 'Geen logregels gevonden.';

  @override
  String get editorOpen => 'Openen in editor';

  @override
  String get editorSaved => 'Alle wijzigingen opgeslagen';

  @override
  String get editorSaving => 'Opslaan…';

  @override
  String get editorUnsaved => 'Niet-opgeslagen wijzigingen';

  @override
  String get editorReadOnly => 'Alleen-lezen';

  @override
  String get editorSaveFailedTitle => 'Wijzigingen niet opgeslagen';

  @override
  String get editorSaveFailedMessage =>
      'Je wijzigingen konden niet op de server worden opgeslagen. Toch sluiten en ze kwijtraken?';

  @override
  String get editorLeave => 'Toch sluiten';

  @override
  String get scanDocument => 'Document scannen';

  @override
  String get documentKind => 'Document';

  @override
  String get spreadsheetKind => 'Rekenblad';

  @override
  String get presentationKind => 'Presentatie';

  @override
  String get newSpreadsheet => 'Nieuw rekenblad';

  @override
  String get newPresentation => 'Nieuwe presentatie';

  @override
  String get pdfKind => 'PDF';

  @override
  String get newPdf => 'Nieuwe pdf';

  @override
  String get brandingGroup => 'Huisstijl';

  @override
  String get serverName => 'Servernaam';

  @override
  String get serverNameHint => 'Zichtbaar op het inlogscherm, in de zijbalk en als venstertitel';

  @override
  String brandingDefault(String value) {
    return '$value (standaard)';
  }

  @override
  String get welcomeMessage => 'Welkomstbericht';

  @override
  String get welcomeMessageNone => 'Niet getoond';

  @override
  String get brandingAccent => 'Standaard accentkleur';

  @override
  String get brandingAccentHint => 'Gebruikt tenzij iemand een eigen accentkleur kiest';

  @override
  String get appDefault => 'Standaard van de app';

  @override
  String get hexColorLabel => 'Kleur als #RRGGBB';

  @override
  String get serverIcon => 'Pictogram';

  @override
  String get serverIconHint => 'Zichtbaar op het inlogscherm en in de zijbalk';

  @override
  String get loginBackgrounds => 'Achtergronden inlogscherm';

  @override
  String loginBackgroundsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afbeeldingen, om de beurt getoond',
      one: '1 afbeelding',
      zero: 'Geen; toegevoegde afbeeldingen wisselen elkaar af achter het inlogscherm',
    );
    return '$_temp0';
  }

  @override
  String get brandingHint => 'Naam, kleuren, pictogram en inlogscherm';

  @override
  String get brandingIdentityGroup => 'Naam en kleuren';

  @override
  String get brandingImagesGroup => 'Afbeeldingen';

  @override
  String get imageFromDevice => 'Van dit apparaat';

  @override
  String get imageFromFiles => 'Uit je bestanden';

  @override
  String get chooseImage => 'Kies een afbeelding';

  @override
  String get chooseImages => 'Kies afbeeldingen';

  @override
  String get noImagesInFolder => 'Geen afbeeldingen of mappen hier';

  @override
  String addSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count toevoegen', zero: 'Toevoegen');
    return '$_temp0';
  }

  @override
  String get versionHistory => 'Versiegeschiedenis';

  @override
  String get versions => 'Versies';

  @override
  String versionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eerdere versies',
      one: '1 eerdere versie',
      zero: 'Nog geen',
    );
    return '$_temp0';
  }

  @override
  String get versionCurrent => 'Huidige versie';

  @override
  String get versionHistoryEmpty =>
      'Nog geen eerdere versies. Als dit bestand wordt overschreven, wordt de vorige inhoud hier bewaard.';

  @override
  String get versionHistoryOff => 'Versiegeschiedenis staat uit, dus eerdere versies worden niet bewaard.';

  @override
  String get versionView => 'Bekijken';

  @override
  String get versionRestore => 'Terugzetten';

  @override
  String get versionRestoreTitle => 'Deze versie terugzetten?';

  @override
  String get versionRestoreMessage => 'De huidige inhoud wordt als versie bewaard, zodat je ernaar terug kunt.';

  @override
  String get versionRestored => 'Versie teruggezet';

  @override
  String get versionDeleteTitle => 'Deze versie verwijderen?';

  @override
  String get versionDeleteMessage => 'Deze versie wordt definitief verwijderd.';

  @override
  String versionViewing(String date) {
    return 'Versie van $date, alleen lezen';
  }

  @override
  String get versionBackToCurrent => 'Terug naar huidige';

  @override
  String get versionsKeep => 'Eerdere versies bewaren';

  @override
  String get versionsKeepHint =>
      'Als een bestand wordt overschreven, wordt de vorige inhoud bewaard. Versies tellen mee voor je opslag.';

  @override
  String versionsPerFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count per bestand',
      one: '1 per bestand',
      zero: 'Geen limiet per bestand',
    );
    return '$_temp0';
  }

  @override
  String get versionsMaxPerFile => 'Versies per bestand';

  @override
  String versionsMaxPerFileHint(String limit) {
    return 'De server staat er maximaal $limit toe.';
  }

  @override
  String get versionsMaxAge => 'Versies bewaren';

  @override
  String get versionsFollowServer => 'Server volgen';

  @override
  String get versionsTurnOffTitle => 'Versiegeschiedenis uitzetten?';

  @override
  String get versionsTurnOffMessage => 'Alle eerdere versies van je bestanden worden definitief verwijderd.';

  @override
  String get turnOff => 'Uitzetten';

  @override
  String get versionsTurnedOffByAdmin => 'Uitgezet door je beheerder';

  @override
  String versionsKeepAllHint(String limit) {
    return 'De server staat maximaal $limit toe.';
  }

  @override
  String get trashKeep => 'Verwijderde items naar de prullenbak';

  @override
  String get trashKeepHint =>
      'Verwijderde items kun je terugzetten tot de prullenbak wordt geleegd. Uit verwijdert ze definitief.';

  @override
  String get trashTurnedOffByAdmin => 'Uitgezet door je beheerder. Verwijderde items worden definitief verwijderd.';

  @override
  String get trashTurnOffTitle => 'Prullenbak uitzetten?';

  @override
  String get trashTurnOffMessage =>
      'Alles in je prullenbak wordt definitief verwijderd en verwijderen kan daarna niet meer ongedaan worden gemaakt.';

  @override
  String get serverTrashEnabledHint =>
      'Uitzetten leegt de prullenbak van iedere gebruiker en maakt verwijderen definitief.';

  @override
  String get serverTrashTurnOffMessage =>
      'De prullenbak van iedere gebruiker wordt definitief geleegd en verwijderen kan daarna niet meer ongedaan worden gemaakt.';

  @override
  String get serverVersionsEnabled => 'Eerdere versies bewaren';

  @override
  String get serverVersionsEnabledHint =>
      'Alleen wijzigingen via Polder worden bewaard. Uitzetten verwijdert alle geschiedenis.';

  @override
  String get serverVersionsTurnOffMessage =>
      'Eerdere versies van de bestanden van alle gebruikers worden definitief verwijderd en er worden geen nieuwe meer bewaard.';

  @override
  String get versionsKeepAll => 'Elke opslag bewaren gedurende';

  @override
  String get serverVersionsKeepAllHint =>
      'Daarna worden versies uitgedund: na een dag ongeveer één per uur, minder naarmate ze ouder worden.';

  @override
  String versionsHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur',
      one: '1 uur',
      zero: 'Niet elke opslag bewaren',
    );
    return '$_temp0';
  }

  @override
  String get versionsHoursLabel => 'Uren';

  @override
  String get serverVersionsMaxAge => 'Versies bewaren';

  @override
  String get serverVersionsMaxPerFile => 'Versies per bestand';

  @override
  String get serverVersionsLimitHint => 'Standaard en maximum voor iedere gebruiker';

  @override
  String quotaHistory(String size) {
    return 'Daarvan is $size versiegeschiedenis';
  }

  @override
  String get navNotes => 'Notities';

  @override
  String get navCalendar => 'Agenda';

  @override
  String get searchKeywordsCalendar => 'agenda, kalender, afspraken, planning, vergaderingen';

  @override
  String get searchKeywordsNotes => 'notities, markdown, wiki, kennisbank, pagina\'s, dagboek';

  @override
  String get notesSetupTitle => 'Notities instellen';

  @override
  String get notesSetupMessage =>
      'Notities zijn markdown-bestanden in een map naar keuze. Kies een naam voor de map; die wordt aangemaakt als hij nog niet bestaat.';

  @override
  String get notesFolder => 'Notitiemap';

  @override
  String get notesDefaultFolder => 'Notities';

  @override
  String get notesSetUp => 'Instellen';

  @override
  String get notesFolderIsFile => 'Dat is een bestand, geen map.';

  @override
  String get notesFolderExistsTitle => 'Map bestaat al';

  @override
  String notesFolderExistsMessage(String path) {
    return '$path bestaat al. Wil je die als notitiemap gebruiken? De markdown-bestanden erin worden pagina\'s.';
  }

  @override
  String get notesUseExistingFolder => 'Deze map gebruiken';

  @override
  String get notesChooseAnotherName => 'Andere naam kiezen';

  @override
  String get notesChangeFolder => 'Notitiemap wijzigen';

  @override
  String get notesEmptyFolder => 'Nog geen pagina\'s.';

  @override
  String get notesMoveToTop => 'Drop hier om naar het hoogste niveau te verplaatsen';

  @override
  String get notesNothingOpenMessage => 'Kies links een pagina, of begin een nieuwe.';

  @override
  String get noteNewPage => 'Nieuwe pagina';

  @override
  String get noteNewSubpage => 'Nieuwe subpagina';

  @override
  String get noteNewChecklist => 'Nieuwe checklist';

  @override
  String get noteListItem => 'Lijstitem';

  @override
  String get noteRemoveItem => 'Item verwijderen';

  @override
  String noteCheckedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afgevinkte items',
      one: '1 afgevinkt item',
    );
    return '$_temp0';
  }

  @override
  String get noteShowCheckboxes => 'Selectievakjes tonen';

  @override
  String get noteHideCheckboxes => 'Selectievakjes verbergen';

  @override
  String get noteSubpages => 'Subpagina\'s';

  @override
  String get noteCollapse => 'Inklappen';

  @override
  String get noteExpand => 'Uitklappen';

  @override
  String get notesUpOneLevel => 'Eén niveau omhoog';

  @override
  String get noteNewNote => 'Notitie';

  @override
  String get noteDefaultName => 'Notitie';

  @override
  String get noteMove => 'Verplaatsen';

  @override
  String get noteShowInFiles => 'Tonen in bestanden';

  @override
  String noteDeleteTitle(String title) {
    return '$title verwijderen?';
  }

  @override
  String get noteDeleteMessage => 'De pagina gaat naar de prullenbak.';

  @override
  String get noteDeleteWithChildrenMessage => 'De pagina en de subpagina\'s gaan naar de prullenbak.';

  @override
  String noteDeleteManyTitle(int count) {
    return '$count pagina\'s verwijderen?';
  }

  @override
  String get noteDeleteManyMessage => 'De pagina\'s en eventuele subpagina\'s gaan naar de prullenbak.';

  @override
  String get noteSelect => 'Selecteren';

  @override
  String get noteUnsaved => 'Niet-opgeslagen wijzigingen; nu opslaan';

  @override
  String get noteSaving => 'Opslaan';

  @override
  String get noteLivePreview => 'Live voorbeeld';

  @override
  String get noteSourceMode => 'Bronweergave';

  @override
  String get noteLinks => 'Links';

  @override
  String get noteBack => 'Terug';

  @override
  String get noteForward => 'Vooruit';

  @override
  String get noteLinkedFrom => 'Gelinkt vanuit';

  @override
  String get noteLinksTo => 'Linkt naar';

  @override
  String get noteNoBacklinks => 'Er linkt nog niets hierheen.';

  @override
  String get noteNoLinks => 'Deze notitie linkt nergens naar.';

  @override
  String noteBrokenLink(String path) {
    return 'Niet gevonden: $path';
  }

  @override
  String get noteLinkMissing => 'Het gelinkte bestand bestaat niet meer.';

  @override
  String get noteLinkSearch => 'Zoeken';

  @override
  String get noteLinkBrowse => 'Bladeren';

  @override
  String get noteLinkThisFolder => 'Naar deze map linken';

  @override
  String get noteNotText => 'Dit bestand is geen platte UTF-8-tekst en kan hier niet bewerkt worden.';

  @override
  String noteDraftFound(String time) {
    return 'Er zijn niet-opgeslagen wijzigingen van $time op dit apparaat gevonden.';
  }

  @override
  String noteDraftFoundChanged(String time) {
    return 'Er zijn niet-opgeslagen wijzigingen van $time gevonden, maar de notitie is sindsdien gewijzigd.';
  }

  @override
  String get noteRecoverDraft => 'Herstellen';

  @override
  String get noteDiscardDraft => 'Weggooien';

  @override
  String get noteConflict => 'Deze notitie is ergens anders gewijzigd.';

  @override
  String get noteConflictTheirs => 'Die versie gebruiken';

  @override
  String get noteConflictMine => 'Mijn versie houden';

  @override
  String get noteConflictCopy => 'Mijn versie als kopie opslaan';

  @override
  String get copySuffix => 'kopie';

  @override
  String get noteUndo => 'Ongedaan maken';

  @override
  String get noteRedo => 'Opnieuw';

  @override
  String get noteHeading => 'Kop';

  @override
  String noteHeadingLevel(int level) {
    return 'Kop $level';
  }

  @override
  String get noteParagraph => 'Normale tekst';

  @override
  String get noteBold => 'Vet';

  @override
  String get noteItalic => 'Cursief';

  @override
  String get noteStrikethrough => 'Doorgehaald';

  @override
  String get noteInlineCode => 'Code';

  @override
  String get noteBulletList => 'Opsomming';

  @override
  String get noteNumberedList => 'Genummerde lijst';

  @override
  String get noteTaskList => 'Takenlijst';

  @override
  String get noteQuote => 'Citaat';

  @override
  String get noteCallout => 'Kader';

  @override
  String get noteCodeBlock => 'Codeblok';

  @override
  String get noteTable => 'Tabel';

  @override
  String get noteDivider => 'Scheidingslijn';

  @override
  String get noteLinkFile => 'Bestand of notitie linken';

  @override
  String get noteAttachFiles => 'Bestanden bijvoegen';

  @override
  String get profile => 'Profiel';

  @override
  String get accountSettingsHint => 'Je naam, foto en weergave';

  @override
  String get firstName => 'Voornaam';

  @override
  String get lastName => 'Achternaam';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String get displayNameHint => 'Wordt getoond in plaats van je voornaam';

  @override
  String get email => 'E-mail';

  @override
  String get age => 'Leeftijd';

  @override
  String get address => 'Adres';

  @override
  String get profileSaved => 'Profiel opgeslagen';

  @override
  String get userIcon => 'Foto';

  @override
  String get userIconHint => 'Zonder foto worden je initialen getoond';

  @override
  String get open => 'Openen';

  @override
  String deleteItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items verwijderen?',
      one: '1 item verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String deletePermanentlyItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items definitief verwijderen?',
      one: '1 item definitief verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get copy => 'Kopiëren';

  @override
  String moveEntryTitle(String name) {
    return '\"$name\" verplaatsen naar…';
  }

  @override
  String moveItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items verplaatsen naar…',
      one: '1 item verplaatsen naar…',
    );
    return '$_temp0';
  }

  @override
  String get moveHere => 'Hierheen verplaatsen';

  @override
  String copyEntryTitle(String name) {
    return '\"$name\" kopiëren naar…';
  }

  @override
  String copyItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items kopiëren naar…',
      one: '1 item kopiëren naar…',
    );
    return '$_temp0';
  }

  @override
  String get copyHere => 'Hierheen kopiëren';

  @override
  String get showPassword => 'Wachtwoord tonen';

  @override
  String get hidePassword => 'Wachtwoord verbergen';

  @override
  String get confirmPassword => 'Bevestig wachtwoord';

  @override
  String get confirmNewPassword => 'Bevestig nieuw wachtwoord';

  @override
  String get passwordsDoNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get changePassword => 'Wachtwoord wijzigen';

  @override
  String get changePasswordHint => 'Je andere apparaten worden na de wijziging afgemeld.';

  @override
  String get currentPassword => 'Huidig wachtwoord';

  @override
  String get newPassword => 'Nieuw wachtwoord';

  @override
  String get currentPasswordIncorrect => 'Huidig wachtwoord is onjuist';

  @override
  String get passwordChanged => 'Wachtwoord gewijzigd';

  @override
  String get usernameRequirements =>
      '2–32 tekens: kleine letters, cijfers, \'.\', \'_\' of \'-\', beginnend met een letter of cijfer';

  @override
  String passwordRequirements(int count) {
    return 'Minstens $count tekens';
  }

  @override
  String get navShared => 'Gedeeld';

  @override
  String get searchKeywordsShared => 'gedeeld delen links personen groepen';

  @override
  String get sharedWithMe => 'Gedeeld met mij';

  @override
  String get sharedByMe => 'Door mij gedeeld';

  @override
  String get shareLinks => 'Links';

  @override
  String get noIncomingShares => 'Er is nog niets met je gedeeld';

  @override
  String get noOutgoingShares => 'Je hebt nog niets gedeeld';

  @override
  String get noShareLinks => 'Je hebt nog geen links gemaakt';

  @override
  String get share => 'Delen';

  @override
  String shareTitle(String name) {
    return '$name delen';
  }

  @override
  String get shareRecipients => 'Gedeeld met';

  @override
  String get shareSearchHint => 'Personen of groepen toevoegen';

  @override
  String get shareNoMatches => 'Geen personen of groepen gevonden';

  @override
  String get sharePermissionRead => 'Kan bekijken';

  @override
  String get sharePermissionWrite => 'Kan bewerken';

  @override
  String get shareNotSharedYet => 'Nog met niemand gedeeld';

  @override
  String sharedBy(String name) {
    return 'Gedeeld door $name';
  }

  @override
  String get shareUnavailable => 'In de prullenbak';

  @override
  String get shareLeave => 'Verwijderen uit mijn gedeelde items';

  @override
  String get shareDetailsOwner => 'Gedeeld door';

  @override
  String shareDetailsGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Groepen', one: 'Groep');
    return '$_temp0';
  }

  @override
  String get shareDetailsAccess => 'Toegang';

  @override
  String get shareDetailsNote => 'Notitie';

  @override
  String get shareStop => 'Stoppen met delen';

  @override
  String shareGroupMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count leden', one: '1 lid');
    return '$_temp0';
  }

  @override
  String get createLink => 'Link maken';

  @override
  String get editLink => 'Link bewerken';

  @override
  String get linkAccess => 'Iedereen met de link kan';

  @override
  String get linkCanView => 'Bekijken';

  @override
  String get linkCanViewHint => 'Door de bestanden bladeren en voorbeelden zien';

  @override
  String get linkCanDownload => 'Downloaden';

  @override
  String get linkCanDownloadHint => 'Bestanden en mappen op hun apparaat opslaan';

  @override
  String get linkCanUpload => 'Uploaden';

  @override
  String get linkCanUploadHint => 'Bestanden aan deze map toevoegen; bestaande bestanden worden nooit vervangen';

  @override
  String get linkPassword => 'Wachtwoord';

  @override
  String get linkPasswordHint => 'Laat leeg voor geen wachtwoord';

  @override
  String get linkPasswordKeep => 'Laat leeg om het huidige wachtwoord te houden';

  @override
  String get linkPasswordSet => 'Beveiligd met wachtwoord';

  @override
  String get linkRemovePassword => 'Wachtwoord verwijderen';

  @override
  String get linkExpiry => 'Vervaldatum';

  @override
  String get linkNoExpiry => 'Verloopt nooit';

  @override
  String linkExpiresOn(String date) {
    return 'Verloopt $date';
  }

  @override
  String get linkExpired => 'Verlopen';

  @override
  String get linkCopy => 'Link kopiëren';

  @override
  String get linkCopied => 'Link gekopieerd';

  @override
  String get deleteLinkTitle => 'Link verwijderen?';

  @override
  String get deleteLinkMessage => 'De link werkt direct niet meer voor iedereen die hem heeft.';

  @override
  String get publicShareLocked => 'Deze link is beveiligd met een wachtwoord';

  @override
  String get publicShareUnlock => 'Openen';

  @override
  String get publicShareWrongPassword => 'Onjuist wachtwoord';

  @override
  String get publicShareRateLimited => 'Te veel pogingen. Probeer het over een minuut opnieuw.';

  @override
  String get publicShareNotFound => 'Deze link bestaat niet of is verlopen';

  @override
  String publicShareUploadOnly(String name) {
    return 'Bestanden die je hier uploadt gaan naar $name. Je kunt niet zien wat er al staat.';
  }

  @override
  String get downloadAll => 'Alles downloaden';

  @override
  String get openInApp => 'Openen in app';

  @override
  String get openInPolder => 'Openen in Polder';

  @override
  String get groups => 'Groepen';

  @override
  String get groupName => 'Groepsnaam';

  @override
  String get renameGroup => 'Groep hernoemen';

  @override
  String get deleteGroupTitle => 'Groep verwijderen?';

  @override
  String deleteGroupMessage(String name) {
    return '$name wordt verwijderd en alles wat ermee gedeeld is wordt niet meer gedeeld.';
  }

  @override
  String get groupMembers => 'Leden';

  @override
  String get noGroups => 'Nog geen groepen';

  @override
  String get filterUsers => 'Gebruikers filteren';

  @override
  String get newGroup => 'Nieuwe groep';

  @override
  String get myGroups => 'Mijn groepen';

  @override
  String get allGroups => 'Alle groepen';

  @override
  String get groupRoleAdmin => 'Beheerder';

  @override
  String get groupRoleMember => 'Lid';

  @override
  String get groupRoleViewer => 'Kijker';

  @override
  String get groupRoleAdminHint => 'Beheert leden en kan alles verwijderen wat met de groep gedeeld is';

  @override
  String get groupRoleMemberHint => 'Kan delen met de groep';

  @override
  String get groupRoleViewerHint => 'Kan alleen bekijken wat met de groep gedeeld is';

  @override
  String get addMember => 'Lid toevoegen';

  @override
  String get leaveGroup => 'Groep verlaten';

  @override
  String leaveGroupTitle(String name) {
    return '$name verlaten?';
  }

  @override
  String get leaveGroupMessage =>
      'Je ziet niet langer wat met deze groep gedeeld is, en wat jij ermee gedeeld hebt wordt niet meer gedeeld.';

  @override
  String leaveGroupAloneMessage(String name) {
    return 'Je bent het enige lid van $name. Als je vertrekt wordt de groep verwijderd en wordt niets er nog mee gedeeld.';
  }

  @override
  String get leaveAndDeleteGroup => 'Verlaten en verwijderen';

  @override
  String leaveGroupLastAdminMessage(String name) {
    return 'Je bent de laatste beheerder van $name. Maak eerst iemand anders beheerder, of verwijder de groep.';
  }

  @override
  String get removeMember => 'Uit groep verwijderen';

  @override
  String get groupShared => 'Gedeeld met deze groep';

  @override
  String get noGroupShares => 'Er is nog niets met deze groep gedeeld';

  @override
  String get selectGroup => 'Kies een groep of maak er een';

  @override
  String get searchKeywordsGroups => 'groepen teams leden rollen';

  @override
  String groupCreatedBy(String name) {
    return 'Gemaakt door $name';
  }

  @override
  String get sharePermissionCustom => 'Aangepaste rechten';

  @override
  String get sharePermView => 'Bekijken';

  @override
  String get sharePermCreate => 'Aanmaken';

  @override
  String get sharePermEdit => 'Bewerken';

  @override
  String get sharePermDelete => 'Verwijderen';

  @override
  String get shareNote => 'Notitie voor ontvanger';

  @override
  String get shareNoteHint => 'Wordt samen met het gedeelde item getoond';

  @override
  String get nothingSelected => 'Kies iets aan de linkerkant';

  @override
  String sharedByWithPermission(String name, String permission) {
    return 'Gedeeld door $name · $permission';
  }

  @override
  String shareWithName(String name) {
    return 'Delen met $name';
  }

  @override
  String sharedWithName(String name) {
    return 'Gedeeld met $name';
  }

  @override
  String get finderLocationDisabled =>
      'Zet Polder aan in Systeeminstellingen › Algemeen › Inlogonderdelen en extensies › Bestandsaanbieders om je bestanden in Finder te zien.';

  @override
  String get openSystemSettings => 'Open Systeeminstellingen';

  @override
  String get startup => 'Opstarten';

  @override
  String get launchAtLogin => 'Openen bij inloggen';

  @override
  String get launchAtLoginHint => 'Start Polder automatisch wanneer je inlogt op je computer';

  @override
  String get launchMinimized => 'Geminimaliseerd starten';

  @override
  String get launchMinimizedHint => 'Draai op de achtergrond na inloggen zonder het venster te openen';

  @override
  String get showInFinder => 'Tonen in Finder';

  @override
  String get showInFinderHint => 'Blader door je bestanden in Finder; ze worden gedownload zodra je ze opent';

  @override
  String get finderRemoveTitle => 'Verwijderen uit Finder?';

  @override
  String get finderRemoveMessage =>
      'Bestanden die voor offline gebruik zijn gedownload, worden van deze Mac verwijderd. Ze blijven op de server staan.';

  @override
  String get showInFilesApp => 'Tonen in Bestanden';

  @override
  String get showInFilesAppHint => 'Open en bewaar Polder-bestanden vanuit andere apps via de app Bestanden';

  @override
  String get filesAppRemoveTitle => 'Verwijderen uit Bestanden?';

  @override
  String get filesAppRemoveMessage =>
      'Andere apps kunnen geen bestanden meer openen of bewaren in Polder. Je bestanden blijven op de server staan.';

  @override
  String get accept => 'Accepteren';

  @override
  String get decline => 'Weigeren';

  @override
  String get appPasswords => 'App-wachtwoorden';

  @override
  String get appPasswordsHint =>
      'WebDAV- en CalDAV-apps zoals Finder, Verkenner, rclone en Apple Agenda loggen in met je gebruikersnaam en een app-wachtwoord. Je accountwachtwoord werkt daar niet.';

  @override
  String get createAppPassword => 'App-wachtwoord maken';

  @override
  String get appPasswordNameHint => 'Bijvoorbeeld: Finder op mijn laptop';

  @override
  String get appPasswordReadOnly => 'Alleen lezen';

  @override
  String get appPasswordReadOnlyHint => 'Apps die het gebruiken kunnen alleen bestanden lezen';

  @override
  String get appPasswordConfirmHint => 'Voer je accountwachtwoord in om te bevestigen dat jij het bent';

  @override
  String get appPasswordCreatedTitle => 'App-wachtwoord gemaakt';

  @override
  String get appPasswordCreatedMessage => 'Kopieer dit wachtwoord nu. Het wordt niet opnieuw getoond.';

  @override
  String get appPasswordCopied => 'App-wachtwoord gekopieerd';

  @override
  String get appPasswordNeverUsed => 'Nooit gebruikt';

  @override
  String appPasswordLastUsed(String date, String address) {
    return 'Laatst gebruikt op $date vanaf $address';
  }

  @override
  String get noAppPasswords => 'Nog geen app-wachtwoorden';

  @override
  String get revokeAppPassword => 'Intrekken';

  @override
  String revokeAppPasswordTitle(String name) {
    return '$name intrekken?';
  }

  @override
  String get revokeAppPasswordMessage => 'Apps die dit wachtwoord gebruiken werken meteen niet meer.';

  @override
  String get webdavAddress => 'WebDAV-adres';

  @override
  String get webdavAddressCopied => 'WebDAV-adres gekopieerd';

  @override
  String get caldavAddress => 'CalDAV-adres';

  @override
  String get caldavAddressCopied => 'CalDAV-adres gekopieerd';

  @override
  String get calendars => 'Agenda\'s';

  @override
  String get calendarsHint =>
      'Apps zoals Apple Agenda, Thunderbird en DAVx⁵ synchroniseren een agenda via CalDAV met je gebruikersnaam en een app-wachtwoord. Apps zoals Google Agenda en Outlook kunnen zich in plaats daarvan abonneren op een geheime link, die ze om de paar uur verversen.';

  @override
  String get noCalendars => 'Nog geen agenda\'s';

  @override
  String get calendarAddressCopied => 'Agenda-adres gekopieerd';

  @override
  String calendarSharedBy(String name) {
    return 'Gedeeld door $name';
  }

  @override
  String get calendarSubscribedFeed => 'Geabonneerde feed';

  @override
  String get subscriptionLinks => 'Abonnementslinks';

  @override
  String get noSubscriptionLinks => 'Nog geen abonnementslinks';

  @override
  String get createSubscriptionLink => 'Abonnementslink maken';

  @override
  String get subscriptionLinkModeFull => 'Alle details';

  @override
  String get subscriptionLinkModeFullHint => 'Titels, locaties, notities en deelnemers';

  @override
  String get subscriptionLinkModeBusy => 'Alleen bezette tijden';

  @override
  String get subscriptionLinkModeBusyHint => 'Toont wanneer je bezet bent en verder niets';

  @override
  String get subscriptionLinkNameHint => 'Bijvoorbeeld: Outlook op het werk';

  @override
  String get subscriptionLinkCreatedTitle => 'Abonnementslink gemaakt';

  @override
  String get subscriptionLinkCreatedMessage =>
      'Kopieer de link nu. Hij wordt niet opnieuw getoond, en iedereen die hem heeft kan deze agenda zien.';

  @override
  String get subscriptionLinkWebcal => 'Link voor agenda-apps (webcal)';

  @override
  String get subscriptionLinkCopied => 'Abonnementslink gekopieerd';

  @override
  String subscriptionLinkLastUsed(String date) {
    return 'Laatst gebruikt $date';
  }

  @override
  String get revokeSubscriptionLink => 'Intrekken';

  @override
  String get revokeSubscriptionLinkTitle => 'Deze abonnementslink intrekken?';

  @override
  String get revokeSubscriptionLinkMessage => 'Apps die ermee geabonneerd zijn krijgen meteen geen updates meer.';

  @override
  String get federation => 'Federatie';

  @override
  String get federationEnabled => 'Delen met andere servers';

  @override
  String get federationEnabledHint =>
      'Mensen kunnen delen met gebruikers op vertrouwde servers die Open Cloud Mesh ondersteunen';

  @override
  String get federationNeedsPublicUrl => 'Stel publicUrl in de serverconfiguratie in om dit aan te zetten';

  @override
  String get trustServer => 'Server vertrouwen';

  @override
  String get trustServerHint =>
      'Er wordt alleen gedeeld met servers die je vertrouwt. De ondertekeningssleutel van de server wordt vastgelegd wanneer je hem toevoegt.';

  @override
  String get serverAddress => 'Serveradres';

  @override
  String get allowPrivateNetwork => 'Privénetwerk toestaan';

  @override
  String get allowPrivateNetworkHint => 'Alleen voor een server op je eigen netwerk, bijvoorbeeld thuis';

  @override
  String get noTrustedServers => 'Nog geen vertrouwde servers';

  @override
  String get noTrustedServersHint => 'Voeg een server toe om met de gebruikers ervan te delen';

  @override
  String serverKey(String fingerprint) {
    return 'Sleutel $fingerprint';
  }

  @override
  String get rediscoverServer => 'Sleutel opnieuw ophalen';

  @override
  String rediscoverServerTitle(String name) {
    return 'De sleutel van $name opnieuw ophalen?';
  }

  @override
  String get rediscoverServerMessage =>
      'Doe dit alleen als de beheerder van de server zegt dat de sleutel is veranderd. De nieuwe sleutel wordt vanaf nu vertrouwd.';

  @override
  String removeTrustedServerTitle(String name) {
    return '$name niet meer vertrouwen?';
  }

  @override
  String get removeTrustedServerMessage => 'Alle shares met deze server stoppen.';

  @override
  String get federatedRecipients => 'Op andere servers';

  @override
  String get federatedNotSharedYet =>
      'Typ een cloud-ID, zoals alice@cloud.example.com, om te delen met iemand op een andere server';

  @override
  String get federatedShareHint =>
      'Diegene krijgt een verzoek op de eigen server en kan het item openen na accepteren.';

  @override
  String get federatedSharePending => 'Wacht tot diegene accepteert.';

  @override
  String get federatedSharePendingShort => 'In afwachting';

  @override
  String get federatedShareAccepted => 'Diegene heeft deze share geaccepteerd.';

  @override
  String get shareSearchFederatedHint => 'Naam, groep of cloud-ID';

  @override
  String get shareWithFederated => 'Delen met iemand op een andere server';

  @override
  String get sharedFromOtherServers => 'Van andere servers';

  @override
  String get noFederatedShares => 'Er is niets met je gedeeld vanaf andere servers';

  @override
  String declineFederatedTitle(String name) {
    return '$name weigeren?';
  }

  @override
  String removeFederatedTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String removeFederatedMessage(String owner) {
    return '$owner krijgt te horen dat je deze share niet meer wilt.';
  }

  @override
  String get acceptInvite => 'Uitnodiging accepteren';

  @override
  String get acceptInviteHint =>
      'Voer het uitnodigingstoken en het serveradres in dat je hebt gekregen. Jullie worden elkaars contacten en kunnen met elkaar delen.';

  @override
  String get inviteSomeone => 'Iemand uitnodigen';

  @override
  String get inviteToken => 'Uitnodigingstoken';

  @override
  String get inviteCreatedTitle => 'Uitnodiging gemaakt';

  @override
  String inviteCreatedMessage(String date) {
    return 'Stuur het token en het adres van deze server naar de ander. Diegene accepteert het op de eigen server vóór $date.';
  }

  @override
  String inviteAccepted(String name) {
    return '$name is nu een contact';
  }

  @override
  String get openInvite => 'Openstaande uitnodiging';

  @override
  String get openInvites => 'Openstaande uitnodigingen';

  @override
  String get federationContacts => 'Contacten op andere servers';

  @override
  String removeContactTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String get removeContactMessage => 'Shares blijven zoals ze zijn; jullie kunnen elkaar later opnieuw uitnodigen.';

  @override
  String get copied => 'Gekopieerd';

  @override
  String get checkSenderAddress => 'Afzenderadres controleren';

  @override
  String get checkSenderAddressHint =>
      'Voor servers die verzoeken niet ondertekenen: accepteer ze alleen vanaf adressen waar de servernaam naar verwijst';

  @override
  String get serverUnsignedChecked => 'Ondertekent geen verzoeken; afzenderadres wordt gecontroleerd';

  @override
  String get serverUnsignedAnyAddress => 'Ondertekent geen verzoeken; elk afzenderadres wordt geaccepteerd';

  @override
  String get shareDetailsTitle => 'Deelgegevens';

  @override
  String get shareDetailsSoftware => 'Software';

  @override
  String get shareDetailsSharedOn => 'Gedeeld op';

  @override
  String get sharedWithYou => 'Met jou gedeeld';

  @override
  String leaveShareMessage(String owner) {
    return 'Het verdwijnt uit je bestanden. $owner kan het opnieuw met je delen.';
  }

  @override
  String get showSharesInFiles => 'Tonen in Bestanden';

  @override
  String get showSharesInFilesHint =>
      'Gedeelde items staan tussen je eigen bestanden. Uitgeschakeld open je ze alleen hier.';

  @override
  String get sharedByYou => 'Door jou gedeeld';

  @override
  String get serverPreviewsGroup => 'Voorbeelden';

  @override
  String get regeneratePreviews => 'Voorbeelden opnieuw maken';

  @override
  String get regeneratePreviewsHint => 'Maakt op de achtergrond van elk bestand een nieuw voorbeeld';

  @override
  String get regeneratePreviewsMessage =>
      'Elk bestand krijgt op de achtergrond een nieuw voorbeeld. Tot dat klaar is, toont een bestand zijn pictogram.';

  @override
  String get regenerate => 'Opnieuw maken';

  @override
  String previewsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden wachten op een nieuw voorbeeld',
      one: '1 bestand wacht op een nieuw voorbeeld',
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
  String get tagPickerHint => 'Zoek of maak een tag';

  @override
  String get tagInvalidName => 'Gebruik letters, cijfers, -, _ of / zonder spaties';

  @override
  String get tagsEmpty => 'Nog geen tags. Typ #naam in een notitie, of voeg er een toe via het menu van een item.';

  @override
  String tagCreate(String name) {
    return 'Maak #$name';
  }

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Niet gebruikt',
    );
    return '$_temp0';
  }

  @override
  String get tagEditTitle => 'Tag bewerken';

  @override
  String get tagName => 'Naam';

  @override
  String get tagColor => 'Kleur';

  @override
  String tagDeleteTitle(String name) {
    return '#$name verwijderen?';
  }

  @override
  String tagDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hij wordt van $count items verwijderd, ook uit de tekst van je notities.',
      one: 'Hij wordt van 1 item verwijderd, ook uit de tekst van je notities.',
      zero: 'De tag wordt nergens gebruikt.',
    );
    return '$_temp0';
  }

  @override
  String get tagSuggestionCreate => 'Nieuwe tag';

  @override
  String get searchKeywordsTags => 'labels, hashtags, kleuren, categorieën';

  @override
  String get tagsDeleteUnused => 'Ongebruikte tags verwijderen';

  @override
  String get tagsDeleteUnusedTitle => 'Ongebruikte tags verwijderen?';

  @override
  String tagsDeleteUnusedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags staan op geen enkel item en in geen van je notities. Ze worden verwijderd.',
      one: '1 tag staat op geen enkel item en in geen van je notities. Deze wordt verwijderd.',
    );
    return '$_temp0';
  }

  @override
  String tagsUnusedDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags verwijderd',
      one: '1 tag verwijderd',
      zero: 'Geen ongebruikte tags',
    );
    return '$_temp0';
  }

  @override
  String get recipeImportLink => 'Link naar het recept';

  @override
  String get recipeImportMessage =>
      'De ingrediënten, stappen en afbeeldingen worden in een nieuwe notitie gezet. Je kunt hem daarna nog bijwerken.';

  @override
  String get recipeImportAction => 'Importeren';

  @override
  String get recipeStartCooking => 'Begin met koken';

  @override
  String get recipeIngredients => 'Ingrediënten';

  @override
  String get recipeServings => 'Porties';

  @override
  String get recipeFewerServings => 'Minder porties';

  @override
  String get recipeMoreServings => 'Meer porties';

  @override
  String recipeStepOf(int current, int total) {
    return 'Stap $current van $total';
  }

  @override
  String get recipeYouNeed => 'Je hebt nodig';

  @override
  String get recipePrevious => 'Vorige';

  @override
  String get recipeNext => 'Volgende';

  @override
  String get recipeBegin => 'Beginnen';

  @override
  String get recipeDone => 'Klaar';

  @override
  String get recipeNoSteps => 'Dit recept heeft nog geen stappen.';

  @override
  String recipeStartTimer(String duration) {
    return 'Start een timer van $duration';
  }

  @override
  String get recipeStopTimer => 'Timer stoppen';

  @override
  String recipeTimerDone(String label) {
    return '$label is klaar';
  }

  @override
  String get recipeImportFromLink => 'Link';

  @override
  String get recipeImportFromPaste => 'Plakken';

  @override
  String get recipeImportPasteMessage =>
      'Kopieer het recept in je browser en plak het hier. Selecteer de tekst van de titel tot en met de laatste stap, of kopieer de hele paginabron om ook de afbeeldingen mee te nemen.';

  @override
  String get recipeImportPasteButton => 'Plakken van klembord';

  @override
  String recipeImportPastedLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekens geplakt',
      one: '1 teken geplakt',
    );
    return '$_temp0';
  }

  @override
  String get recipeImportLinkOptional => 'Link naar het recept (optioneel)';

  @override
  String get recipeImportRefused =>
      'Deze site laat Polder de pagina niet laden. Open hem in je browser, kopieer het recept en plak het hier.';

  @override
  String get recipeImportClipboardEmpty => 'Er staat geen tekst op het klembord.';

  @override
  String get recipeAdd => 'Recept toevoegen';

  @override
  String get recipeFromScratch => 'Eigen recept';

  @override
  String get recipeFromScratchMessage => 'Begin met een leeg recept met ingrediënten en stappen om zelf in te vullen.';

  @override
  String get notesFilterByTag => 'Filteren op tag';

  @override
  String get notesFilterClear => 'Wissen';

  @override
  String get notesFilterNoTags => 'Nog geen tags. Maak tags aan om je notities erop te filteren.';

  @override
  String get notesFilterNoMatches => 'Geen notities in je notitiemap hebben deze tags.';

  @override
  String get notesSearchHint => 'Notities filteren';

  @override
  String get notesSearchNoResults => 'Geen notities gevonden.';

  @override
  String get notesViewOptions => 'Sorteer- en weergaveopties';

  @override
  String get notesExpandAll => 'Alles uitklappen';

  @override
  String get notesCollapseAll => 'Alles inklappen';

  @override
  String get notesRevealCurrent => 'Open notitie tonen';

  @override
  String get notesShowFamilyTree => 'Gerelateerde pagina\'s';

  @override
  String get notesViewAll => 'Alle notities';

  @override
  String get notesViewUntagged => 'Zonder tags';

  @override
  String get notesViewUntaggedEmpty => 'Elke notitie in je notitiemap heeft een tag.';

  @override
  String get durationLabel => 'Duur';

  @override
  String get slideshow => 'Diavoorstelling';

  @override
  String get previousItem => 'Vorige';

  @override
  String get nextItem => 'Volgende';

  @override
  String mediaCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String get couldNotLoadMedia => 'Dit bestand kon niet worden geladen';

  @override
  String get play => 'Afspelen';

  @override
  String get pause => 'Pauzeren';

  @override
  String get mute => 'Geluid uit';

  @override
  String get unmute => 'Geluid aan';

  @override
  String get setAsWallpaper => 'Instellen als achtergrond';

  @override
  String get wallpaperSet => 'Achtergrond ingesteld';

  @override
  String get setAs => 'Instellen als…';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get lensLabel => 'Lens';

  @override
  String get apertureLabel => 'Diafragma';

  @override
  String get shutterSpeedLabel => 'Sluitertijd';

  @override
  String get focalLengthLabel => 'Brandpuntsafstand';

  @override
  String get isoLabel => 'ISO';

  @override
  String get locationLabel => 'Locatie';

  @override
  String get videoCodecLabel => 'Videocodec';

  @override
  String get frameRateLabel => 'Framesnelheid';

  @override
  String get audioCodecLabel => 'Audiocodec';

  @override
  String get bitrateLabel => 'Bitrate';

  @override
  String get updates => 'Updates';

  @override
  String get updatesAutomatic => 'Updates automatisch installeren';

  @override
  String get updatesAutomaticHint =>
      'Download nieuwe versies op de achtergrond en installeer ze wanneer Polder afsluit';

  @override
  String get updatesNightly => 'Nightly builds ontvangen';

  @override
  String get updatesNightlyHint => 'Krijg de nieuwste ontwikkelversies eerder; ze kunnen fouten bevatten';

  @override
  String get updatesCheck => 'Controleren op updates';

  @override
  String get updatesChecking => 'Controleren op updates…';

  @override
  String get updatesUpToDate => 'Polder is up-to-date';

  @override
  String get updatesFailed => 'Kon niet controleren op updates';

  @override
  String updatesInstallFailed(String version, int build) {
    return 'Kon versie $version ($build) niet installeren';
  }

  @override
  String updatesAvailable(String version, int build) {
    return 'Versie $version ($build) is beschikbaar';
  }

  @override
  String updatesDownloading(int percent) {
    return 'Update downloaden… $percent%';
  }

  @override
  String updatesReady(String version, int build) {
    return 'Versie $version ($build) wordt geïnstalleerd wanneer Polder afsluit';
  }

  @override
  String get updatesRestart => 'Herstarten om bij te werken';

  @override
  String get updatesInstall => 'Nu bijwerken';

  @override
  String get updatesDownload => 'Downloaden';

  @override
  String get updatesReleaseNotes => 'Wat is er nieuw';

  @override
  String get aboutNightly => 'Nightly build';

  @override
  String get calendarImported => 'Geïmporteerd';

  @override
  String get calendarNoImported => 'Voeg agenda\'s toe van andere diensten, zoals Google Agenda, Outlook of iCloud.';

  @override
  String get calendarNew => 'Nieuwe agenda';

  @override
  String get calendarEdit => 'Agenda bewerken';

  @override
  String get calendarAddExternal => 'Externe agenda toevoegen';

  @override
  String get calendarName => 'Naam';

  @override
  String get calendarColorLabel => 'Kleur';

  @override
  String get calendarDefault => 'Standaard';

  @override
  String get calendarSetDefault => 'Gebruiken voor uitnodigingen';

  @override
  String calendarDeleteTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String get calendarDeleteMessage =>
      'De agenda en alle afspraken worden verwijderd, ook voor iedereen met wie hij gedeeld is.';

  @override
  String calendarLeaveTitle(String name) {
    return '$name verlaten?';
  }

  @override
  String get calendarLeaveMessage => 'Je ziet deze agenda niet meer. De eigenaar kan hem opnieuw met je delen.';

  @override
  String get calendarLeave => 'Verlaten';

  @override
  String calendarRemoveImportedTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String get calendarRemoveImportedMessage =>
      'De agenda wordt niet meer gesynchroniseerd en de afspraken verdwijnen uit Polder. Het origineel blijft ongewijzigd.';

  @override
  String get calendarRemove => 'Verwijderen';

  @override
  String get calendarSyncNow => 'Nu synchroniseren';

  @override
  String calendarSyncedAt(String time) {
    return 'Gesynchroniseerd $time';
  }

  @override
  String get calendarSyncPending => 'Wacht op de eerste synchronisatie';

  @override
  String calendarSyncFailed(String error) {
    return 'Synchroniseren mislukt: $error';
  }

  @override
  String calendarSyncRequested(String name) {
    return '$name wordt gesynchroniseerd';
  }

  @override
  String get calendarFromUrl => 'Link';

  @override
  String get calendarFromUrlHint =>
      'Blijft up-to-date. Plak een iCal- (.ics) of webcal-link, zoals het geheime adres van een Google-, Outlook- of iCloud-agenda.';

  @override
  String get calendarFromFile => 'Bestand';

  @override
  String get calendarFromFileHint =>
      'Voegt de afspraken uit een .ics-bestand eenmalig toe als nieuwe agenda. Een .zip met .ics-bestanden, zoals een export uit Google Agenda, werkt ook.';

  @override
  String get calendarLink => 'Agendalink';

  @override
  String get calendarInvalidLink => 'Vul een http-, https- of webcal-link in';

  @override
  String get calendarRefreshEvery => 'Verversen';

  @override
  String get calendarEvery15Minutes => 'Elk kwartier';

  @override
  String get calendarEveryHour => 'Elk uur';

  @override
  String get calendarEvery6Hours => 'Elke 6 uur';

  @override
  String get calendarEveryDay => 'Elke dag';

  @override
  String get calendarChooseFile => '.ics-bestand kiezen';

  @override
  String calendarImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afspraken geïmporteerd',
      one: '1 afspraak geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get calendarAccessRead => 'Kan bekijken';

  @override
  String get calendarAccessReadWrite => 'Kan bewerken';

  @override
  String get calendarAccessFreeBusy => 'Ziet alleen bezette tijden';

  @override
  String get calendarStopSharing => 'Stoppen met delen';

  @override
  String get calendarManage => 'Agenda\'s';

  @override
  String get calendarDiscover => 'Ontdekken';

  @override
  String get calendarDiscoverHint => 'Agenda\'s die zichzelf up-to-date houden.';

  @override
  String get calendarSuggested => 'Aanbevolen';

  @override
  String get calendarPublicHolidays => 'Feestdagen';

  @override
  String get calendarReligiousHolidays => 'Religieuze feestdagen';

  @override
  String get calendarMore => 'Meer';

  @override
  String get calendarSearchCountries => 'Zoek een land';

  @override
  String calendarHolidaysIn(String country) {
    return 'Feestdagen in $country';
  }

  @override
  String get calendarChristianHolidays => 'Christelijke feestdagen';

  @override
  String get calendarOrthodoxHolidays => 'Orthodox-christelijke feestdagen';

  @override
  String get calendarIslamicHolidays => 'Islamitische feestdagen';

  @override
  String get calendarJewishHolidays => 'Joodse feestdagen';

  @override
  String get calendarHinduHolidays => 'Hindoeïstische feestdagen';

  @override
  String get calendarWeekNumbers => 'Weeknummers';

  @override
  String get calendarMoonPhases => 'Maanfasen';

  @override
  String get calendarAdded => 'Toegevoegd';

  @override
  String get calendarImportInto => 'Importeren uit bestand';

  @override
  String get calendarImportIntoHint => 'Kies een .ics-bestand, of een .zip daarvan zoals een export uit Google Agenda';

  @override
  String calendarImportFailedSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afspraken konden niet worden geïmporteerd',
      one: '1 afspraak kon niet worden geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get calendarFeedLanguage => 'Taal van de agenda\'s';

  @override
  String get calendarFeedLanguageHint =>
      'Google vertaalt de namen van agenda\'s en de meeste feestdagen; sommige afspraken blijven Engels.';

  @override
  String get notifications => 'Meldingen';

  @override
  String get notificationsHint => 'Delen, herinneringen en uploads';

  @override
  String get notificationsEnable => 'Meldingen tonen';

  @override
  String get notificationsEnableHint => 'Op dit apparaat';

  @override
  String get notificationsWebHint => 'Je browser toont ze zolang Polder in een tabblad open is';

  @override
  String get notificationsBlocked =>
      'Meldingen zijn geblokkeerd. Sta ze voor Polder toe in de instellingen van je systeem of browser.';

  @override
  String get notificationsNotAllowed => 'Meldingen staan aan, maar dit apparaat staat Polder nog niet toe ze te tonen.';

  @override
  String get notificationsAllow => 'Toestaan';

  @override
  String get notificationsOpenSettings => 'Instellingen openen';

  @override
  String get notificationsReminderOff => 'Meldingen voor agendaherinneringen staan uit, dus je krijgt deze niet.';

  @override
  String get notificationsTurnOn => 'Aanzetten';

  @override
  String get notificationsAbout => 'Waarover je meldingen krijgt';

  @override
  String get notificationsShares => 'Nieuwe gedeelde items';

  @override
  String get notificationsSharesHint =>
      'Als iemand een bestand of map met je deelt, met knoppen om te accepteren of te weigeren';

  @override
  String get notificationsCalendar => 'Agendaherinneringen';

  @override
  String get notificationsCalendarHint =>
      'Op de herinneringstijden van elke afspraak; zet agenda\'s aan of uit via hun menu in de agenda';

  @override
  String get notificationsUploadProgress => 'Uploadvoortgang';

  @override
  String get notificationsUploadProgressHint => 'Eén melding die bijwerkt zolang automatisch uploaden bezig is';

  @override
  String get notificationsUploadSummary => 'Uploadresultaat';

  @override
  String get notificationsUploadSummaryHint => 'Hoeveel er is geüpload, en wat er misging';

  @override
  String get notificationsUploadCheck => 'Zoeken naar nieuwe foto\'s';

  @override
  String get notificationsUploadCheckHint =>
      'Een stille melding terwijl automatisch uploaden naar nieuwe foto\'s en video\'s zoekt';

  @override
  String get notificationsReliability => 'Betrouwbaarheid';

  @override
  String get notificationsBattery => 'Op de achtergrond uitvoeren';

  @override
  String get notificationsBatteryHint =>
      'Voorkomt dat het systeem herinneringen, gedeelde items en uploads uitstelt om batterij te sparen';

  @override
  String get notificationsAllowed => 'Toegestaan';

  @override
  String get notificationChannelUploads => 'Uploads';

  @override
  String get notificationChannelCalendar => 'Agendaherinneringen';

  @override
  String get notificationChannelSharing => 'Gedeelde items';

  @override
  String notificationShareTitle(String owner, String name) {
    return '$owner heeft $name met je gedeeld';
  }

  @override
  String notificationShareGroupTitle(String owner, String name, String group) {
    return '$owner heeft $name gedeeld met $group';
  }

  @override
  String notificationFederatedShareBody(String server) {
    return 'Van $server';
  }

  @override
  String notificationUploadingTitle(int done, int total) {
    return '$done van $total uploaden';
  }

  @override
  String notificationUploadDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden geüpload',
      one: '1 bestand geüpload',
    );
    return '$_temp0';
  }

  @override
  String notificationUploadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden konden niet worden geüpload',
      one: '1 bestand kon niet worden geüpload',
    );
    return '$_temp0';
  }

  @override
  String get notificationUploadFailedBody => 'Open automatisch uploaden om te zien wat er misging';

  @override
  String get notificationUploadChecking => 'Zoeken naar nieuwe foto\'s en video\'s';

  @override
  String notificationReminderAt(String time) {
    return '$time';
  }

  @override
  String get notificationReminderAllDay => 'Hele dag';

  @override
  String get calendarRemindersOn => 'Herinneringen aanzetten';

  @override
  String get calendarRemindersOff => 'Herinneringen uitzetten';

  @override
  String get sharedWaiting => 'Wacht op jou';

  @override
  String get sharedWaitingHint => 'Accepteer om ze aan je bestanden toe te voegen';

  @override
  String shareAccepted(String name) {
    return '$name staat nu in je bestanden';
  }

  @override
  String shareDeclined(String name) {
    return '$name geweigerd';
  }

  @override
  String get errorStorageFull => 'De server heeft geen schijfruimte meer en kon dit niet opslaan.';

  @override
  String get errorTimedOut => 'De server reageert niet meer.';

  @override
  String get connectionNoNetwork => 'Geen netwerkverbinding';

  @override
  String get connectionServerUnreachable => 'Niet verbonden met de server';

  @override
  String get connectionServerFull => 'De opslag van de server is vol';

  @override
  String get connectionServerReadOnly => 'De server kan geen wijzigingen opslaan';

  @override
  String changesSavedOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wijzigingen op dit apparaat bewaard',
      one: '1 wijziging op dit apparaat bewaard',
      zero: 'Wijzigingen worden op dit apparaat bewaard',
    );
    return '$_temp0';
  }

  @override
  String get hintUnreachable =>
      'Controleer je netwerkverbinding, of de server draait. Wijzigingen worden automatisch gesynchroniseerd zodra hij terug is.';

  @override
  String get hintStorageFull =>
      'De server kon de wijziging niet opslaan; mogelijk is de schijf vol. Vraag de beheerder van de server om ruimte vrij te maken en probeer het opnieuw.';

  @override
  String get hintQuota => 'Je opslagquotum is vol. Verwijder bestanden of leeg de prullenbak en probeer het opnieuw.';

  @override
  String get hintServerError =>
      'Er ging iets mis op de server. Probeer het later opnieuw, of vraag de beheerder om de serverlogs te controleren.';

  @override
  String get hintConflict => 'Dit is ook ergens anders gewijzigd. Kies welke versie je wilt houden.';

  @override
  String get hintRejected =>
      'De server weigerde deze wijziging. Verwijder hem, of bewaar een kopie en probeer het opnieuw.';

  @override
  String get noteSynced => 'Opgeslagen en gesynchroniseerd';

  @override
  String get noteSavedOnDevice => 'Op dit apparaat opgeslagen; wacht op synchronisatie. Tik om nu te synchroniseren';

  @override
  String get noteNotSynced => 'Op dit apparaat opgeslagen, maar niet met de server gesynchroniseerd';

  @override
  String get retrySync => 'Opnieuw';

  @override
  String get retryAll => 'Alles opnieuw';

  @override
  String get discardChange => 'Verwijderen';

  @override
  String get discardChangeTitle => 'Deze wijziging verwijderen?';

  @override
  String get discardChangeMessage =>
      'De versie op dit apparaat wordt weggegooid en de versie op de server blijft bewaard.';

  @override
  String get offlineGroupNotes => 'Notities';

  @override
  String get offlineGroupFiles => 'Bestanden';

  @override
  String get offlineGroupCalendar => 'Agenda';

  @override
  String get syncWaitingForServer => 'Wacht op de server';

  @override
  String get syncFailedItem => 'Niet gesynchroniseerd';

  @override
  String get keepOffline => 'Offline beschikbaar maken';

  @override
  String get removeFromDevice => 'Verwijderen van dit apparaat';

  @override
  String get availableOffline => 'Offline beschikbaar';

  @override
  String get errorDeviceFull => 'Niet genoeg vrije ruimte op dit apparaat';

  @override
  String get hintDeviceFull =>
      'Maak ruimte vrij op dit apparaat, of verwijder offline bestanden met \"Verwijderen van dit apparaat\".';

  @override
  String offlineDownloadFailed(String reason) {
    return 'Downloaden voor offline gebruik mislukt: $reason';
  }

  @override
  String offlineDownloadingTag(int percent) {
    return 'Downloaden $percent%';
  }

  @override
  String offlineDownloadsFailedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden konden niet offline beschikbaar worden gemaakt',
      one: '1 bestand kon niet offline beschikbaar worden gemaakt',
    );
    return '$_temp0';
  }

  @override
  String get waitingForOffline => 'Wacht op downloaden voor offline gebruik';

  @override
  String downloadingForOffline(int percent) {
    return 'Downloaden voor offline gebruik, $percent%';
  }

  @override
  String downloadingFilesForOffline(int done, int total) {
    return 'Downloaden voor offline gebruik, $done van $total bestanden';
  }

  @override
  String get sessionEndedTitle => 'Opnieuw inloggen';

  @override
  String get sessionEndedMessage =>
      'Je sessie op dit apparaat is beëindigd. Log opnieuw in om verder te synchroniseren. Er gaat niets verloren op dit apparaat.';

  @override
  String get sessionEndedStatus => 'Sessie beëindigd';

  @override
  String get sessionEndedSignIn => 'Inloggen';

  @override
  String get continueOffline => 'Offline verdergaan';

  @override
  String get firstDayOfWeek => 'Eerste dag van de week';

  @override
  String firstDayOfWeekRegional(String day) {
    return 'Regionale standaard ($day)';
  }

  @override
  String get calendarSettings => 'Agenda-instellingen';

  @override
  String fileOperationMoving(String subject) {
    return '$subject verplaatsen';
  }

  @override
  String fileOperationMoved(String subject) {
    return '$subject verplaatst';
  }

  @override
  String fileOperationCopying(String subject) {
    return '$subject kopiëren';
  }

  @override
  String fileOperationCopied(String subject) {
    return '$subject gekopieerd';
  }

  @override
  String fileOperationDeleting(String subject) {
    return '$subject verwijderen';
  }

  @override
  String fileOperationDeleted(String subject) {
    return '$subject verwijderd';
  }

  @override
  String fileOperationRenaming(String subject) {
    return '$subject hernoemen';
  }

  @override
  String fileOperationRenamed(String subject) {
    return '$subject hernoemd';
  }

  @override
  String fileOperationRestoring(String subject) {
    return '$subject terugzetten';
  }

  @override
  String fileOperationRestored(String subject) {
    return '$subject teruggezet';
  }

  @override
  String fileOperationPurging(String subject) {
    return '$subject definitief verwijderen';
  }

  @override
  String fileOperationPurged(String subject) {
    return '$subject definitief verwijderd';
  }

  @override
  String fileOperationItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0';
  }

  @override
  String fileOperationInto(String folder) {
    return 'Naar $folder';
  }

  @override
  String get fileOperationIncomplete => 'Niet alles is gelukt';

  @override
  String get fileOperationTagMoving => 'Verplaatsen…';

  @override
  String get fileOperationTagCopying => 'Kopiëren…';

  @override
  String get fileOperationTagDeleting => 'Verwijderen…';

  @override
  String get fileOperationTagRenaming => 'Hernoemen…';

  @override
  String get fileOperationTagWaiting => 'Wacht';

  @override
  String get fileOperationTagMovingHere => 'Hierheen verplaatsen…';

  @override
  String get fileOperationTagCopyingHere => 'Hierheen kopiëren…';

  @override
  String fileOperationsMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'nog $count acties', one: 'nog 1 actie');
    return '$_temp0';
  }

  @override
  String get fileOperationTagRestoring => 'Terugzetten…';

  @override
  String get emailSettings => 'E-mail';

  @override
  String get emailSettingsHint => 'Mailserver voor wachtwoordherstel, meldingen en delen';

  @override
  String get emailOn => 'E-mails staan aan';

  @override
  String get emailOff => 'E-mails staan uit';

  @override
  String get emailOnHint =>
      'Polder stuurt wachtwoordherstel, aanmeldmeldingen, opslagwaarschuwingen en gedeelde items, in je huisstijl.';

  @override
  String get emailOffHint =>
      'Stel een SMTP-server en afzenderadres in om wachtwoordherstel, aanmeldmeldingen, opslagwaarschuwingen en gedeelde items te versturen.';

  @override
  String get emailManagedByConfig =>
      'Deze instellingen komen uit de configuratie of omgeving van de server en zijn hier niet te wijzigen.';

  @override
  String get mailServerGroup => 'SMTP';

  @override
  String get mailServerHost => 'SMTP-server';

  @override
  String get notSet => 'Niet ingesteld';

  @override
  String get mailSecurity => 'Beveiliging';

  @override
  String get mailServerPort => 'SMTP-poort';

  @override
  String mailServerPortDefault(int port) {
    return 'Standaard ($port)';
  }

  @override
  String get mailServerPortLabel => 'Poort, of leeg voor de standaard';

  @override
  String get mailUsername => 'SMTP-gebruikersnaam';

  @override
  String get mailUsernameNone => 'Geen; de SMTP-server vraagt niet om aanmelden';

  @override
  String get mailPasswordSaved => 'Opgeslagen';

  @override
  String get mailPassword => 'SMTP-wachtwoord';

  @override
  String get mailPasswordHint =>
      'Wordt op de server bewaard en nooit meer getoond. Verwijder het als de SMTP-server geen aanmelding nodig heeft.';

  @override
  String get mailSenderGroup => 'Afzender';

  @override
  String get mailFrom => 'Afzenderadres';

  @override
  String get mailFromHint => 'Het adres waar e-mails vandaan komen';

  @override
  String get mailFromLabel => 'Adres, zoals Polder <polder@example.com>';

  @override
  String get mailTestGroup => 'Testen';

  @override
  String get sendTestEmail => 'Testmail versturen';

  @override
  String get sendTestEmailHint => 'Controleer de instellingen met een e-mail in de stijl van je server';

  @override
  String get sendTestEmailNeedsServer => 'Stel eerst een SMTP-server en afzenderadres in';

  @override
  String get mailTestRecipient => 'Versturen naar';

  @override
  String get send => 'Versturen';

  @override
  String testEmailSent(String address) {
    return 'Testmail verstuurd naar $address';
  }

  @override
  String get mailSecurityStartTls => 'STARTTLS';

  @override
  String get mailSecurityTls => 'TLS';

  @override
  String get mailSecurityNone => 'Geen';

  @override
  String get mailSecurityStartTlsHint => 'Schakelt over op een versleutelde verbinding; meestal poort 587';

  @override
  String get mailSecurityTlsHint => 'Vanaf het begin versleuteld; meestal poort 465';

  @override
  String get mailSecurityNoneHint => 'Onversleuteld; alleen voor een SMTP-server op een vertrouwd netwerk';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get forgotPasswordTitle => 'Wachtwoord herstellen';

  @override
  String get forgotPasswordHint =>
      'Vul je gebruikersnaam of e-mailadres in. Heeft je account een e-mailadres, dan sturen we daar een code naartoe om een nieuw wachtwoord te kiezen.';

  @override
  String get usernameOrEmail => 'Gebruikersnaam of e-mail';

  @override
  String get resetUnavailable =>
      'Deze server kan geen e-mails voor wachtwoordherstel versturen. Vraag een beheerder om een nieuw wachtwoord voor je in te stellen.';

  @override
  String get sendResetCode => 'Code versturen';

  @override
  String get resetCodeTitle => 'Vul je code in';

  @override
  String get resetCodeSent =>
      'Als er een account met een e-mailadres bij past, hebben we daar een code naartoe gestuurd. Hij werkt één keer, een uur lang.';

  @override
  String get resetCode => 'Code uit de e-mail';

  @override
  String get resetCodeNeverLinks => 'We sturen nooit herstellinks. Typ de code hier zelf in.';

  @override
  String get sendResetCodeAgain => 'Nieuwe code versturen';

  @override
  String get passwordResetDoneTitle => 'Wachtwoord gewijzigd';

  @override
  String get passwordResetDone => 'Meld je aan met je nieuwe wachtwoord. Je bent afgemeld op je andere apparaten.';

  @override
  String get emailNotifications => 'E-mail';

  @override
  String get emailNotificationsNoAddress => 'Voeg een e-mailadres toe';

  @override
  String get emailNotificationsNoAddressHint => 'Voor e-mails is een adres in je account nodig';

  @override
  String get emailSecurity => 'Beveiligingsmeldingen';

  @override
  String get emailSecurityHint => 'Aanmeldingen vanaf nieuwe adressen en wijzigingen van je e-mailadres';

  @override
  String get emailQuota => 'Opslagwaarschuwingen';

  @override
  String get emailQuotaHint => 'Als je opslag bijna of helemaal vol is';

  @override
  String get emailShares => 'Gedeelde items';

  @override
  String get emailSharesHint => 'Als iemand een bestand of map met je deelt';

  @override
  String get emailAlwaysSent => 'Wachtwoordherstel en wachtwoordwijzigingen worden altijd gemaild.';

  @override
  String get emailOptional => 'E-mail (optioneel)';

  @override
  String get newUserEmailHint => 'Krijgt een welkomstmail en kan een vergeten wachtwoord herstellen';

  @override
  String get invalidEmail => 'Geen e-mailadres';

  @override
  String get waitingForBrowser => 'Rond het inloggen af in je browser';

  @override
  String get signInOr => 'of';

  @override
  String signInWithProvider(String provider) {
    return 'Inloggen met $provider';
  }

  @override
  String get signInWithAnotherDevice => 'Inloggen met een ander apparaat';

  @override
  String get twoFactorCodePrompt => 'Voer de 6-cijferige code uit je authenticator-app in.';

  @override
  String get twoFactorRecoveryPrompt => 'Voer een van je herstelcodes in. Elke code werkt één keer.';

  @override
  String get authenticatorCode => 'Verificatiecode';

  @override
  String get recoveryCode => 'Herstelcode';

  @override
  String get verify => 'Controleren';

  @override
  String get back => 'Terug';

  @override
  String get approveOnAnotherDevice => 'Liever goedkeuren op een ander apparaat';

  @override
  String get useRecoveryCode => 'Herstelcode gebruiken';

  @override
  String get useAuthenticatorCode => 'Authenticator-app gebruiken';

  @override
  String get deviceApprovalPrompt => 'Open Polder op een apparaat waarop je bent ingelogd en typ dit getal:';

  @override
  String get deviceApprovalHint => 'Het verzoek komt alleen aan op apparaten waarop Polder open is.';

  @override
  String get loginErrorInvalidCode => 'Die code is onjuist of verlopen.';

  @override
  String get loginErrorTooManyAttempts => 'Te veel pogingen. Wacht een minuut en probeer het opnieuw.';

  @override
  String get loginErrorApprovalDenied => 'Het inloggen is geweigerd op je andere apparaat.';

  @override
  String get loginErrorApprovalExpired => 'Geen enkel apparaat heeft het inloggen op tijd goedgekeurd.';

  @override
  String get loginErrorSsoSignupDisabled =>
      'Er is nog geen account voor je op deze server. Vraag je beheerder er een aan te maken of te koppelen.';

  @override
  String get loginErrorSsoLinkRequired =>
      'Er bestaat al een account met dit e-mailadres. Log in met het wachtwoord daarvan en koppel deze provider bij Instellingen → Account.';

  @override
  String get loginErrorSsoFailed =>
      'Inloggen via de provider is niet gelukt. Probeer het opnieuw of vraag het je beheerder.';

  @override
  String get loginApprovalTitle => 'Inlogverzoek';

  @override
  String loginApprovalBody(String device, String address) {
    return '$device wil inloggen op je account vanaf $address.';
  }

  @override
  String get loginApprovalTypeNumber => 'Typ het getal dat op dat apparaat staat';

  @override
  String get loginApprovalApprove => 'Goedkeuren';

  @override
  String get loginApprovalDeny => 'Dit was ik niet';

  @override
  String get loginApprovalWrongNumber => 'Dat was niet het juiste getal, dus het inloggen is geweigerd.';

  @override
  String loginApprovalNotificationTitle(String device) {
    return '$device wil inloggen';
  }

  @override
  String loginApprovalNotificationBody(String address) {
    return 'Open Polder om het inloggen vanaf $address goed te keuren of te weigeren.';
  }

  @override
  String get notificationChannelSecurity => 'Beveiliging';

  @override
  String get twoFactorTitle => 'Tweestapsverificatie';

  @override
  String get twoFactorOn => 'Aan';

  @override
  String get twoFactorOff => 'Uit';

  @override
  String get twoFactorOffHint => 'Vraag om een code uit een authenticator-app als je met je wachtwoord inlogt.';

  @override
  String twoFactorRequiredBy(String date) {
    return 'Vereist door je beheerder vóór $date';
  }

  @override
  String get twoFactorRequiredByAdmin => 'Je beheerder vereist het';

  @override
  String recoveryCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count herstelcodes',
      one: 'Nog 1 herstelcode',
    );
    return '$_temp0';
  }

  @override
  String get regenerateRecoveryCodes => 'Nieuwe herstelcodes';

  @override
  String get regenerateRecoveryCodesHint => 'Je huidige herstelcodes werken dan niet meer.';

  @override
  String get turnOffTwoFactor => 'Tweestapsverificatie uitzetten';

  @override
  String get turnOffTwoFactorHint => 'Inloggen vraagt dan alleen nog je wachtwoord.';

  @override
  String get twoFactorSetupTitle => 'Tweestapsverificatie instellen';

  @override
  String get twoFactorSetupIntro => 'Voer je wachtwoord in om te beginnen.';

  @override
  String get twoFactorContinue => 'Doorgaan';

  @override
  String get twoFactorScanIntro =>
      'Scan deze QR-code met een authenticator-app zoals Aegis, 2FAS of Google Authenticator en voer de code in die verschijnt.';

  @override
  String get twoFactorOpenAuthenticator => 'Openen in authenticator-app';

  @override
  String get twoFactorManualKey => 'Of voer deze sleutel in';

  @override
  String get twoFactorCodeMismatch => 'Die code klopt niet. Controleer de tijd op je apparaat en probeer het opnieuw.';

  @override
  String get recoveryCodesTitle => 'Bewaar je herstelcodes';

  @override
  String get recoveryCodesIntro =>
      'Als je je telefoon kwijtraakt, kun je met elk van deze codes één keer inloggen. Bewaar ze op een veilige plek; je ziet ze niet nog eens.';

  @override
  String get copyRecoveryCodes => 'Codes kopiëren';

  @override
  String get recoveryCodesSaved => 'Ik heb ze bewaard';

  @override
  String get setUp => 'Instellen';

  @override
  String twoFactorDeadlineBanner(String date) {
    return 'Stel tweestapsverificatie in vóór $date.';
  }

  @override
  String get twoFactorRequiredTitle => 'Tweestapsverificatie is vereist';

  @override
  String get twoFactorRequiredBody =>
      'Je beheerder vereist het voor elk account. Stel het in om Polder te blijven gebruiken.';

  @override
  String get setPassword => 'Wachtwoord instellen';

  @override
  String get connectedAccounts => 'Gekoppelde accounts';

  @override
  String get notConnected => 'Niet gekoppeld';

  @override
  String get unlink => 'Ontkoppelen';

  @override
  String unlinkTitle(String provider) {
    return '$provider ontkoppelen?';
  }

  @override
  String unlinkMessage(String provider) {
    return 'Je kunt niet meer inloggen met $provider totdat je het opnieuw koppelt.';
  }

  @override
  String get ssoAlreadyLinked => 'Dat account is al aan iemand anders gekoppeld.';

  @override
  String get adminAuthentication => 'Authenticatie';

  @override
  String get adminAuthenticationHint => 'Tweestapsverificatie en single sign-on';

  @override
  String get requireTwoFactor => 'Tweestapsverificatie vereisen';

  @override
  String get requireTwoFactorHint =>
      'Iedereen die met een wachtwoord inlogt moet het instellen. Single sign-on is uitgezonderd.';

  @override
  String requireTwoFactorConfirm(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'heeft $days dagen om het in te stellen',
      one: 'heeft 1 dag om het in te stellen',
      zero: 'moet het direct instellen',
    );
    return 'Iedereen zonder krijgt een e-mail en $_temp0. Daarna kunnen ze alleen nog dat doen.';
  }

  @override
  String get require => 'Vereisen';

  @override
  String get twoFactorGracePeriod => 'Overgangsperiode';

  @override
  String twoFactorGracePeriodHint(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen om het in te stellen',
      one: '1 dag om het in te stellen',
      zero: 'Geen overgangsperiode',
    );
    return '$_temp0; wijzigingen gelden voor nieuwe deadlines';
  }

  @override
  String get days => 'Dagen';

  @override
  String get twoFactorNoMailWarning =>
      'Er is geen mailserver ingesteld, dus gebruikers krijgen geen e-mail over de deadline. Ze zien het wel in de apps.';

  @override
  String get singleSignOn => 'Single sign-on';

  @override
  String get singleSignOnHint =>
      'Laat mensen inloggen met een identiteitsprovider zoals Pocket ID, authentik, Keycloak, Google, Microsoft of GitHub.';

  @override
  String get addProvider => 'Provider toevoegen';

  @override
  String addProviderNamed(String provider) {
    return '$provider toevoegen';
  }

  @override
  String get noProviders => 'Nog geen providers';

  @override
  String get managedByConfig => 'Ingesteld in de serverconfiguratie';

  @override
  String linkedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gekoppelde accounts',
      one: '1 gekoppeld account',
      zero: 'Geen gekoppelde accounts',
    );
    return '$_temp0';
  }

  @override
  String get providerManagedByConfigHint =>
      'Deze provider is ingesteld in de serverconfiguratie. Je kunt hem hier alleen aan- of uitzetten.';

  @override
  String get buttonLabel => 'Tekst op de knop';

  @override
  String get issuerUrl => 'Issuer-URL';

  @override
  String get clientId => 'Client-ID';

  @override
  String get clientSecret => 'Client-secret';

  @override
  String get clientSecretKept => 'Laat leeg om het opgeslagen secret te houden';

  @override
  String get callbackUrl => 'Callback-URL';

  @override
  String get providerServerUrl => 'Server-URL';

  @override
  String get providerRealm => 'Realm';

  @override
  String get providerSlug => 'Applicatie-slug';

  @override
  String get providerTenantId => 'Tenant-ID';

  @override
  String get identityProvider => 'de identiteitsprovider';

  @override
  String providerUrlNamed(String provider) {
    return '$provider-URL';
  }

  @override
  String get providerTenantIdHint =>
      'Je directory-ID (tenant-ID), of common, organizations of consumers om andere directory\'s toe te laten';

  @override
  String callbackUrlHint(String provider, String field) {
    return 'Plak dit bij $provider onder ‘$field’';
  }

  @override
  String get providerAllowSignup => 'Accounts aanmaken';

  @override
  String get providerAllowSignupHint => 'Mensen zonder account krijgen er een als ze voor het eerst inloggen';

  @override
  String get providerLinkByEmail => 'Koppelen op e-mailadres';

  @override
  String get providerLinkByEmailHint => 'Inloggen op het bestaande account met hetzelfde geverifieerde e-mailadres';

  @override
  String get testConnection => 'Testen';

  @override
  String get providerTestOk => 'De provider antwoordde correct.';

  @override
  String providerTestFailed(String reason) {
    return 'De provider is niet bereikbaar: $reason';
  }

  @override
  String deleteProviderTitle(String provider) {
    return '$provider verwijderen?';
  }

  @override
  String deleteProviderMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'De inlogknop verdwijnt en $count accounts worden ontkoppeld. Accounts zonder wachtwoord kunnen dan niet meer inloggen.',
      one: 'De inlogknop verdwijnt en 1 account wordt ontkoppeld. Accounts zonder wachtwoord kunnen dan niet meer inloggen.',
      zero: 'De inlogknop verdwijnt.',
    );
    return '$_temp0';
  }

  @override
  String get twoFactorTag => '2FA';

  @override
  String twoFactorDueTag(String date) {
    return '2FA vóór $date';
  }

  @override
  String get twoFactorOverdueTag => '2FA te laat';

  @override
  String get ssoTag => 'SSO';

  @override
  String get resetTwoFactor => 'Tweestapsverificatie resetten';

  @override
  String resetTwoFactorTitle(String username) {
    return 'Tweestapsverificatie van $username resetten?';
  }

  @override
  String get resetTwoFactorMessage =>
      'Gebruik dit als ze hun authenticator-app kwijt zijn. Ze worden overal uitgelogd en kunnen het opnieuw instellen.';

  @override
  String get extendTwoFactorDeadline => 'Meer tijd geven voor 2FA';
}
