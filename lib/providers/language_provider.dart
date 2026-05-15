import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class LanguageProvider extends ChangeNotifier {
  final SettingsService _settings;
  Locale _locale = const Locale('ar');

  LanguageProvider(this._settings);

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> load() async {
    final code = await _settings.getLanguage();
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code != 'ar' && code != 'en') return;
    _locale = Locale(code);
    await _settings.setLanguage(code);
    notifyListeners();
  }
}
