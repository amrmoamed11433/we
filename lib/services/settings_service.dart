import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'we_app_language';

  /// Returns 'ar' or 'en'. Default is 'ar'.
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ar';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}
