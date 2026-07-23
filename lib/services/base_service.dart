import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';

class BaseService {
  // Use AppConfig for base URL
  static const String baseUrl = AppConfig.apiBaseUrl;

  static const String _tokenKey = 'auth_token';
  static const String _languageKey = 'language_code';
  static const Set<String> _supportedLanguageCodes = <String>{
    'fr',
    'nl',
    'de',
    'en',
  };

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final savedLanguageCode = prefs.getString(_languageKey);
    final languageCode = _supportedLanguageCodes.contains(savedLanguageCode)
        ? savedLanguageCode!
        : 'en';

    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': languageCode,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
