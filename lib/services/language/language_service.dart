import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _localeKey = 'selected_locale';

  static Future<String> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en';
  }

  static Future<bool> saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_localeKey, locale);
  }

  static Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}
