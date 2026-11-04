/// ============================================
/// API CONFIGURATION
/// ============================================

class ApiConfig {
  // Render FastAPI Backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://story-vault-5gu2.onrender.com',
  );

  // DoodStream
  static const String doodStreamApiKey = String.fromEnvironment(
    'DOOD_API_KEY',
    defaultValue: '581331rkkizkdxrqwo6m5a',
  );

  static const String doodListUrl = 'https://doodapi.com/api/file/list';
  static const String doodFileInfoUrl = 'https://doodapi.com/api/file/info';
}
