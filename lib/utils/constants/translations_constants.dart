import 'dart:ui';

class TranslationsConstants {

  // The path of the localization files
  static const String localizationPath = 'assets/translations';

  // Supported locales of the app
  static List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  // Fallback locale, english
  static Locale fallbackLocale = supportedLocales[0];

}