enum CatalogReligion { christian, orthodoxChristian, islamic, jewish, hindu }

class CatalogCountry {
  const CatalogCountry(this.region, this.googleId, this.english, this.dutch);

  final String region;
  final String googleId;
  final String english;
  final String dutch;

  String nameIn(String language) => language == "nl" ? dutch : english;
}

abstract final class CalendarCatalog {
  static const refreshSeconds = 24 * 60 * 60;

  static const languages = {
    "ar": "العربية",
    "cs": "Čeština",
    "da": "Dansk",
    "de": "Deutsch",
    "el": "Ελληνικά",
    "en": "English",
    "es": "Español",
    "fi": "Suomi",
    "fr": "Français",
    "he": "עברית",
    "hi": "हिन्दी",
    "hu": "Magyar",
    "id": "Bahasa Indonesia",
    "it": "Italiano",
    "ja": "日本語",
    "ko": "한국어",
    "nl": "Nederlands",
    "no": "Norsk",
    "pl": "Polski",
    "pt": "Português",
    "ro": "Română",
    "ru": "Русский",
    "sv": "Svenska",
    "th": "ไทย",
    "tr": "Türkçe",
    "uk": "Українська",
    "vi": "Tiếng Việt",
    "zh-CN": "中文",
  };

  static String languageFor(String appLanguage) {
    final code = appLanguage == "zh" ? "zh-CN" : appLanguage;
    return languages.containsKey(code) ? code : "en";
  }

  static const countries = [
    CatalogCountry("AE", "ae", "United Arab Emirates", "Verenigde Arabische Emiraten"),
    CatalogCountry("AR", "ar", "Argentina", "Argentinië"),
    CatalogCountry("AT", "austrian", "Austria", "Oostenrijk"),
    CatalogCountry("AU", "australian", "Australia", "Australië"),
    CatalogCountry("BE", "be", "Belgium", "België"),
    CatalogCountry("BG", "bulgarian", "Bulgaria", "Bulgarije"),
    CatalogCountry("BR", "brazilian", "Brazil", "Brazilië"),
    CatalogCountry("CA", "canadian", "Canada", "Canada"),
    CatalogCountry("CH", "ch", "Switzerland", "Zwitserland"),
    CatalogCountry("CL", "cl", "Chile", "Chili"),
    CatalogCountry("CN", "china", "China", "China"),
    CatalogCountry("CO", "co", "Colombia", "Colombia"),
    CatalogCountry("CZ", "czech", "Czechia", "Tsjechië"),
    CatalogCountry("DE", "german", "Germany", "Duitsland"),
    CatalogCountry("DK", "danish", "Denmark", "Denemarken"),
    CatalogCountry("EE", "ee", "Estonia", "Estland"),
    CatalogCountry("EG", "eg", "Egypt", "Egypte"),
    CatalogCountry("ES", "spain", "Spain", "Spanje"),
    CatalogCountry("FI", "finnish", "Finland", "Finland"),
    CatalogCountry("FR", "french", "France", "Frankrijk"),
    CatalogCountry("GB", "uk", "United Kingdom", "Verenigd Koninkrijk"),
    CatalogCountry("GR", "greek", "Greece", "Griekenland"),
    CatalogCountry("HK", "hong_kong", "Hong Kong", "Hongkong"),
    CatalogCountry("HR", "croatian", "Croatia", "Kroatië"),
    CatalogCountry("HU", "hungarian", "Hungary", "Hongarije"),
    CatalogCountry("ID", "indonesian", "Indonesia", "Indonesië"),
    CatalogCountry("IE", "irish", "Ireland", "Ierland"),
    CatalogCountry("IL", "jewish", "Israel", "Israël"),
    CatalogCountry("IN", "indian", "India", "India"),
    CatalogCountry("IS", "is", "Iceland", "IJsland"),
    CatalogCountry("IT", "italian", "Italy", "Italië"),
    CatalogCountry("JP", "japanese", "Japan", "Japan"),
    CatalogCountry("KE", "ke", "Kenya", "Kenia"),
    CatalogCountry("KR", "south_korea", "South Korea", "Zuid-Korea"),
    CatalogCountry("LT", "lithuanian", "Lithuania", "Litouwen"),
    CatalogCountry("LU", "lu", "Luxembourg", "Luxemburg"),
    CatalogCountry("LV", "latvian", "Latvia", "Letland"),
    CatalogCountry("MA", "ma", "Morocco", "Marokko"),
    CatalogCountry("MX", "mexican", "Mexico", "Mexico"),
    CatalogCountry("MY", "malaysia", "Malaysia", "Maleisië"),
    CatalogCountry("NG", "ng", "Nigeria", "Nigeria"),
    CatalogCountry("NL", "dutch", "Netherlands", "Nederland"),
    CatalogCountry("NO", "norwegian", "Norway", "Noorwegen"),
    CatalogCountry("NZ", "new_zealand", "New Zealand", "Nieuw-Zeeland"),
    CatalogCountry("PE", "pe", "Peru", "Peru"),
    CatalogCountry("PH", "philippines", "Philippines", "Filipijnen"),
    CatalogCountry("PL", "polish", "Poland", "Polen"),
    CatalogCountry("PT", "portuguese", "Portugal", "Portugal"),
    CatalogCountry("RO", "romanian", "Romania", "Roemenië"),
    CatalogCountry("RS", "rs", "Serbia", "Servië"),
    CatalogCountry("RU", "russian", "Russia", "Rusland"),
    CatalogCountry("SA", "saudiarabian", "Saudi Arabia", "Saoedi-Arabië"),
    CatalogCountry("SE", "swedish", "Sweden", "Zweden"),
    CatalogCountry("SG", "singapore", "Singapore", "Singapore"),
    CatalogCountry("SI", "slovenian", "Slovenia", "Slovenië"),
    CatalogCountry("SK", "slovak", "Slovakia", "Slowakije"),
    CatalogCountry("TH", "th", "Thailand", "Thailand"),
    CatalogCountry("TR", "turkish", "Türkiye", "Turkije"),
    CatalogCountry("TW", "taiwan", "Taiwan", "Taiwan"),
    CatalogCountry("UA", "ukrainian", "Ukraine", "Oekraïne"),
    CatalogCountry("US", "usa", "United States", "Verenigde Staten"),
    CatalogCountry("VN", "vietnamese", "Vietnam", "Vietnam"),
    CatalogCountry("ZA", "sa", "South Africa", "Zuid-Afrika"),
  ];

  static const _languageRegions = {"nl": "NL", "de": "DE", "fr": "FR", "es": "ES", "it": "IT", "pt": "PT", "pl": "PL"};

  static CatalogCountry? countryFor({String? region, required String language}) {
    final code = (region ?? _languageRegions[language])?.toUpperCase();
    return countries.where((country) => country.region == code).firstOrNull;
  }

  static String _google(String calendarId) =>
      "https://calendar.google.com/calendar/ical/${Uri.encodeComponent(calendarId)}/public/basic.ics";

  static String holidays(CatalogCountry country, String language) =>
      _google("$language.${country.googleId}#holiday@group.v.calendar.google.com");

  static String religion(CatalogReligion religion, String language) => _google(
    "$language.${switch (religion) {
      CatalogReligion.christian => "christian",
      CatalogReligion.orthodoxChristian => "orthodox_christianity",
      CatalogReligion.islamic => "islamic",
      CatalogReligion.jewish => "judaism",
      CatalogReligion.hindu => "hinduism",
    }}#holiday@group.v.calendar.google.com",
  );

  static String weekNumbers(String language) => _google("e_2_$language#weeknum@group.v.calendar.google.com");

  static final moonPhases = _google("ht3jlfaac5lfd6263ulfh4tql8@group.calendar.google.com");

  static String normalized(String url) => Uri.decodeFull(url.trim()).replaceFirst(RegExp("^webcals?://"), "https://");
}
