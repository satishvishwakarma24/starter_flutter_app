import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales — strong global coverage (11 languages)
class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('hi'), // Hindi
    Locale('zh'), // Chinese Simplified
    Locale('ar'), // Arabic
    Locale('fr'), // French
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
    Locale('de'), // German
    Locale('id'), // Indonesian
    Locale('ja'), // Japanese
  ];

  static const Map<String, String> localeNames = {
    'en': 'English',
    'es': 'Español',
    'hi': 'हिन्दी',
    'zh': '中文',
    'ar': 'العربية',
    'fr': 'Français',
    'pt': 'Português',
    'ru': 'Русский',
    'de': 'Deutsch',
    'id': 'Indonesia',
    'ja': '日本語',
  };

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_key);
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
