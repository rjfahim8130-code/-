/// ============================================
/// API CONFIGURATION
/// ============================================
/// 
/// এখানে আপনার আসল API Key গুলো বসাবেন।
/// 
/// ১. FastAPI Backend URL (Render.com থেকে পাওয়া লাইভ URL)
/// ২. DoodStream → https://doodstream.com → API Key (581331rkkizkdxrqwo6m5a)
/// ============================================

class ApiConfig {
  // ---------- FastAPI Backend (MongoDB Middleware) ----------
  // আপনার Render বা লাইভ সার্ভারের ব্যাকএন্ড বেস ইউআরএল এখানে বসাবেন
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://your-app.onrender.com', // ← এখানে আপনার Render-এর লাইভ URL বসাবেন
  );

  // ---------- DoodStream API ----------
  static const String doodStreamApiKey = String.fromEnvironment(
    'DOOD_API_KEY',
    defaultValue: '581331rkkizkdxrqwo6m5a',    // ← আপনার DoodStream API Key
  );

  // DoodStream API endpoints
  static const String doodListUrl = 'https://doodapi.com/api/file/list';
  static const String doodFileInfoUrl = 'https://doodapi.com/api/file/info';
}
