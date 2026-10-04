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
  String get aboutLegalese => 'Bestanden, synchronisatie en automatisch uploaden voor je eigen server.';

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
  String get appTitle => 'Nomad';

  @override
  String get autoUploadDescription => 'Nieuwe foto\'s en bestanden uit de gekozen mappen automatisch uploaden.';

  @override
  String get autoUploadEnabled => 'Automatisch uploaden';

  @override
  String get backToFiles => 'Terug naar bestanden';

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
  String deletedCount(int count) {
    return '$count verwijderd';
  }

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
  String downloadedCount(int count) {
    return '$count gedownload';
  }

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
  String get enforceTrashRetention => 'Voor alle gebruikers afdwingen';

  @override
  String get enforceTrashRetentionHint =>
      'Gebruikers kunnen zelf niets kiezen. Een termijn voor één gebruiker gaat nog steeds voor.';

  @override
  String get errorAlreadyExists => 'Er bestaat al iets met die naam.';

  @override
  String get errorConflict => 'Het item is door iemand anders gewijzigd. Vernieuw en probeer het opnieuw.';

  @override
  String get errorForbidden => 'Je hebt hier geen toestemming voor.';

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
  String get errorUnauthorized => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get errorUnknown => 'Er is iets misgegaan.';

  @override
  String get expandSidebar => 'Zijbalk uitklappen';

  @override
  String failedCount(int count) {
    return '$count mislukt';
  }

  @override
  String get folders => 'Mappen';

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
  String get loginErrorUnreachable => 'Geen Nomad-server bereikbaar op dit adres.';

  @override
  String get loginServerIntro => 'Voer het adres van je Nomad-server in.';

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
  String get revision => 'Revisie';

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
  String get server => 'Server';

  @override
  String get serverFolder => 'Map op de server';

  @override
  String get serverTrashRetention => 'Bewaartermijn prullenbak';

  @override
  String serverTrashRetentionHint(String duration) {
    return 'Standaard voor alle gebruikers: $duration';
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
  String get trashRetentionSetByAdmin => 'Ingesteld door je beheerder';

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
  String uploadedCount(int count) {
    return '$count geüpload';
  }

  @override
  String get uploadFiles => 'Bestanden uploaden';

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
  String get userTrashRetentionUsersChoice => 'Keuze van gebruiker';

  @override
  String get wifiOnly => 'Alleen via wifi';
}
