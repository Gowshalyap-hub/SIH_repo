import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/localization/${locale.languageCode}.json', cache: false);
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      return true;
    } catch (e) {
      print('DEBUG_LANG: Failed to load localization for ${locale.languageCode}: $e');
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ta', 'ml', 'te', 'kn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    print('DEBUG_LANG: _AppLocalizationsDelegate.load called with locale: ${locale.languageCode}');
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    print('DEBUG_LANG: _AppLocalizationsDelegate.load finished with locale: ${locale.languageCode}');
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true; // FORCE RELOAD TO TRUE
}

