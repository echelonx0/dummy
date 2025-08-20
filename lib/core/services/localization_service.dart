// lib/core/services/localization_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  // Supported languages
  static final List<Locale> supportedLocales = [
    const Locale('en'), // English
    const Locale('fr'), // French
    const Locale('sw'), // Swahili
  ];

  // This is a wrapper to get the same locales as the generated AppLocalizations
  static List<Locale> get appSupportedLocales => supportedLocales;

  // Names of languages for display
  static final Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'sw': 'Kiswahili',
  };

  // Storage keys
  static const String _languageCodeKey = 'language_code';
  static const String _hasSelectedLanguageKey = 'user_has_selected_language';

  // Get the current locale
  static Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);

    if (languageCode != null &&
        supportedLocales.map((e) => e.languageCode).contains(languageCode)) {
      return Locale(languageCode);
    }

    // Default to device locale or English if device locale not supported
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (supportedLocales
        .map((e) => e.languageCode)
        .contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }

    return const Locale('en'); // Default to English
  }

  // Set the app locale
  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);

    // Mark that the user has selected a language
    await prefs.setBool(_hasSelectedLanguageKey, true);
  }

  // Check if the user has already selected a language
  static Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSelectedLanguageKey) ?? false;
  }

  // Reset language selection status (for testing)
  static Future<void> resetLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSelectedLanguageKey, false);
  }

  // Check if a locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  // Get language name from code
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }

  // Get all supported languages for display
  static List<Map<String, String>> getSupportedLanguages() {
    final List<Map<String, String>> languages = [];

    for (final locale in supportedLocales) {
      languages.add({
        'code': locale.languageCode,
        'name': getLanguageName(locale.languageCode),
      });
    }

    return languages;
  }
}
