import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/calendar.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/screens/calendar/widgets/agenda_dialog.dart";
import "package:polder/screens/calendar/widgets/calendar_files.dart";
import "package:polder/screens/calendar/widgets/calendar_panel.dart";
import "package:polder/services/calendar/calendar_catalog.dart";
import "package:polder/services/transfer/file_picker_service.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder_calendar/polder_calendar.dart";

Future<void> showExternalCalendarDialog(BuildContext context, List<CalendarInfo> calendars) => showCalendarPanel<void>(
  context,
  builder: (context, controller) =>
      _ExternalCalendarForm(color: unusedCalendarColor(calendars), controller: controller),
);

String importNotice(BuildContext context, CalendarImportResult result) {
  final localized = context.localized;
  final done = localized.calendarImportDone(result.created + result.updated + result.skipped);
  return result.errors.isEmpty ? done : "$done · ${localized.calendarImportFailedSome(result.errors.length)}";
}

enum _Origin { discover, link, file }

class _ExternalCalendarForm extends ConsumerStatefulWidget {
  const _ExternalCalendarForm({required this.color, this.controller});

  final Color color;
  final ScrollController? controller;

  @override
  ConsumerState<_ExternalCalendarForm> createState() => _ExternalCalendarFormState();
}

class _ExternalCalendarFormState extends ConsumerState<_ExternalCalendarForm> {
  static const _intervals = [15 * 60, 60 * 60, 6 * 60 * 60, 24 * 60 * 60];

  final _link = TextEditingController();
  final _name = TextEditingController();
  var _origin = _Origin.discover;
  late var _color = widget.color;
  var _interval = 60 * 60;
  PickedFile? _file;
  var _busy = false;

  @override
  void dispose() {
    _link.dispose();
    _name.dispose();
    super.dispose();
  }

  static bool isCalendarLink(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && uri.host.isNotEmpty && const {"http", "https", "webcal", "webcals"}.contains(uri.scheme);
  }

  bool get _valid => switch (_origin) {
    _Origin.discover => false,
    _Origin.link => isCalendarLink(_link.text),
    _Origin.file => _file != null && _name.text.trim().isNotEmpty,
  };

  String _intervalLabel(int seconds) {
    final localized = context.localized;
    return switch (seconds) {
      900 => localized.calendarEvery15Minutes,
      3600 => localized.calendarEveryHour,
      21600 => localized.calendarEvery6Hours,
      _ => localized.calendarEveryDay,
    };
  }

  Future<void> _pickFile() async {
    final file = await pickCalendarFile(ref);
    if (file == null || !mounted) return;
    setState(() {
      _file = file;
      if (_name.text.trim().isEmpty) _name.text = calendarNameFromFile(file.name);
    });
  }

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    setState(() => _busy = true);
    final agendas = ref.read(calendarAgendasProvider);
    final messenger = ScaffoldMessenger.maybeOf(context);
    CalendarImportResult? imported;
    final ok = await context.runWithFeedback(() async {
      switch (_origin) {
        case _Origin.discover:
          return;
        case _Origin.link:
          await agendas.subscribe(
            url: _link.text.trim(),
            name: _name.text.trim(),
            color: _color,
            refreshSeconds: _interval,
          );
        case _Origin.file:
          imported = await agendas.importFile(
            name: _name.text.trim(),
            color: _color,
            content: await readCalendarFile(_file!),
          );
      }
    }());
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    final notice = imported == null ? null : importNotice(context, imported!);
    Navigator.pop(context);
    if (notice != null) messenger?.showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final hint = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return CalendarPanelBody(
      title: localized.calendarAddExternal,
      controller: widget.controller,
      actions: _origin == _Origin.discover
          ? null
          : [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
              FilledButton(
                onPressed: _valid && !_busy ? _submit : null,
                child: _busy
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(localized.add),
              ),
            ],
      children: [
        SegmentedButton<_Origin>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _Origin.discover,
              icon: const Icon(IconsaxPlusLinear.discover),
              label: Text(localized.calendarDiscover),
            ),
            ButtonSegment(
              value: _Origin.link,
              icon: const Icon(IconsaxPlusLinear.link_21),
              label: Text(localized.calendarFromUrl),
            ),
            ButtonSegment(
              value: _Origin.file,
              icon: const Icon(IconsaxPlusLinear.document_upload),
              label: Text(localized.calendarFromFile),
            ),
          ],
          selected: {_origin},
          onSelectionChanged: (selection) => setState(() => _origin = selection.first),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Text(switch (_origin) {
            _Origin.discover => localized.calendarDiscoverHint,
            _Origin.link => localized.calendarFromUrlHint,
            _Origin.file => localized.calendarFromFileHint,
          }, style: hint),
        ),
        if (_origin == _Origin.discover)
          const _Discover()
        else ...[
          if (_origin == _Origin.link)
            TextField(
              controller: _link,
              autofocus: true,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: localized.calendarLink,
                hintText: "webcal://",
                errorText: _link.text.trim().isEmpty || isCalendarLink(_link.text)
                    ? null
                    : localized.calendarInvalidLink,
              ),
              onChanged: (_) => setState(() {}),
            )
          else
            OutlinedButton.icon(
              icon: const Icon(IconsaxPlusLinear.folder_open),
              label: Text(_file?.name ?? localized.calendarChooseFile, overflow: TextOverflow.ellipsis),
              onPressed: _busy ? null : _pickFile,
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: localized.calendarName),
            onChanged: (_) => setState(() {}),
          ),
          if (_origin == _Origin.link) ...[
            CalendarFieldLabel(localized.calendarRefreshEvery),
            DropdownButtonFormField<int>(
              initialValue: _interval,
              items: [
                for (final seconds in _intervals)
                  DropdownMenuItem(value: seconds, child: Text(_intervalLabel(seconds))),
              ],
              onChanged: (seconds) => setState(() => _interval = seconds ?? _interval),
            ),
          ],
          CalendarFieldLabel(localized.calendarColorLabel),
          CalendarColorPicker(selected: _color, onChanged: (color) => setState(() => _color = color)),
        ],
      ],
    );
  }
}

typedef _Offer = ({String title, String name, String url, IconData icon});

class _Discover extends StatefulWidget {
  const _Discover();

  @override
  State<_Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<_Discover> {
  var _query = "";
  String? _language;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final locale = Localizations.localeOf(context);
    final appLanguage = locale.languageCode;
    final language = _language ?? CalendarCatalog.languageFor(appLanguage);
    final ownNames = language == appLanguage;
    String named(String name) => ownNames ? name : "";
    final region = locale.countryCode ?? WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    final home = CalendarCatalog.countryFor(region: region, language: appLanguage);
    _Offer holidays(CatalogCountry country) => (
      title: localized.calendarHolidaysIn(country.nameIn(appLanguage)),
      name: named(localized.calendarHolidaysIn(country.nameIn(appLanguage))),
      url: CalendarCatalog.holidays(country, language),
      icon: IconsaxPlusLinear.flag,
    );
    final weekNumbers = (
      title: localized.calendarWeekNumbers,
      name: named(localized.calendarWeekNumbers),
      url: CalendarCatalog.weekNumbers(language),
      icon: IconsaxPlusLinear.hashtag,
    );
    final query = _query.toLowerCase();
    final countries =
        CalendarCatalog.countries
            .where((country) => query.isEmpty || country.nameIn(appLanguage).toLowerCase().contains(query))
            .toList()
          ..sort((a, b) => a.nameIn(appLanguage).compareTo(b.nameIn(appLanguage)));
    final religions = [
      (localized.calendarChristianHolidays, CatalogReligion.christian),
      (localized.calendarOrthodoxHolidays, CatalogReligion.orthodoxChristian),
      (localized.calendarIslamicHolidays, CatalogReligion.islamic),
      (localized.calendarJewishHolidays, CatalogReligion.jewish),
      (localized.calendarHinduHolidays, CatalogReligion.hindu),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: language,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: localized.calendarFeedLanguage,
            helperText: localized.calendarFeedLanguageHint,
            helperMaxLines: 3,
            prefixIcon: const Icon(IconsaxPlusLinear.language_square),
          ),
          items: [
            for (final MapEntry(key: code, value: name) in CalendarCatalog.languages.entries)
              DropdownMenuItem(value: code, child: Text(name)),
          ],
          onChanged: (code) => setState(() => _language = code),
        ),
        if (query.isEmpty) ...[
          _Heading(localized.calendarSuggested),
          if (home != null) _OfferTile(offer: holidays(home)),
          _OfferTile(offer: weekNumbers),
          _Heading(localized.calendarReligiousHolidays),
          for (final (name, religion) in religions)
            _OfferTile(
              offer: (
                title: name,
                name: named(name),
                url: CalendarCatalog.religion(religion, language),
                icon: IconsaxPlusLinear.star_1,
              ),
            ),
          _Heading(localized.calendarMore),
          _OfferTile(
            offer: (
              title: localized.calendarMoonPhases,
              name: localized.calendarMoonPhases,
              url: CalendarCatalog.moonPhases,
              icon: IconsaxPlusLinear.moon,
            ),
          ),
        ],
        _Heading(localized.calendarPublicHolidays),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1),
            hintText: localized.calendarSearchCountries,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 4),
        for (final country in countries) _OfferTile(offer: holidays(country)),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _OfferTile extends ConsumerStatefulWidget {
  const _OfferTile({required this.offer});

  final _Offer offer;

  @override
  ConsumerState<_OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends ConsumerState<_OfferTile> {
  var _busy = false;

  Future<void> _add(List<CalendarInfo> calendars) async {
    setState(() => _busy = true);
    await context.runWithFeedback(
      ref
          .read(calendarAgendasProvider)
          .subscribe(
            url: widget.offer.url,
            name: widget.offer.name,
            color: unusedCalendarColor(calendars),
            refreshSeconds: CalendarCatalog.refreshSeconds,
          ),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final calendars = ref.watch(calendarListProvider).value ?? const <CalendarInfo>[];
    final wanted = CalendarCatalog.normalized(widget.offer.url);
    final added = calendars.any(
      (calendar) => calendar.sourceUrl != null && CalendarCatalog.normalized(calendar.sourceUrl!) == wanted,
    );
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(widget.offer.icon, color: colors.onSurfaceVariant),
      title: Text(widget.offer.title, overflow: TextOverflow.ellipsis),
      trailing: added
          ? Tooltip(
              message: context.localized.calendarAdded,
              child: Icon(IconsaxPlusBold.tick_circle, color: colors.primary),
            )
          : _busy
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(IconsaxPlusLinear.add),
      onTap: added || _busy ? null : () => _add(calendars),
    );
  }
}
