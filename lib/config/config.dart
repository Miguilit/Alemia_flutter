class AppConfig {
  const AppConfig._();

  /// Global app title
  static const String appTitle = 'Alemia';

  /// App version
  static const String appVersion = '1.3.0';

  /// Support email
  static const String supportEmail = 'support@alemia.org';

  /// Support phone number
  static const String supportPhone = '+32487012156';

  /// Base URL of the backend
  static const String baseUrl = 'https://alemia.org';

  /// API Base URL
  static const String apiBaseUrl = '$baseUrl/api';

  /// Helper to get full image URL
  static String getImageUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl/storage/$path';
  }
}
