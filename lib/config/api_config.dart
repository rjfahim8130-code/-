/// ============================================
/// API CONFIGURATION
/// ============================================
///
/// Render.com-এ চলা FastAPI ব্যাকএন্ডের লাইভ URL
/// এবং DoodStream API Key এখানে আছে।
/// ============================================

class ApiConfig {
  // ---------- FastAPI Backend (Render) ----------
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://story-vault-5gu2.onrender.com',
  );

  // ---------- DoodStream API ----------
  static const String doodStreamApiKey = String.fromEnvironment(
    'DOOD_API_KEY',
    defaultValue: '581331rkkizkdxrqwo6m5a',
  );

  // DoodStream API endpoints
  static const String doodListUrl = 'https://doodapi.com/api/file/list';
  static const String doodFileInfoUrl = 'https://doodapi.com/api/file/info';
}
