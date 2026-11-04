/// ============================================
/// API CONFIGURATION
/// ============================================
/// 
/// এখানে আপনার আসল API Key গুলো বসাবেন।
/// 
/// ১. MongoDB Atlas → App Services → Data API → Endpoint URL + API Key
/// ২. DoodStream → https://doodstream.com → API Key
/// 
/// গুরুত্বপূর্ণ:
/// - এই ফাইলটি GitHub-এ পাবলিক করবেন না যদি Key রাখেন।
/// - অথবা --dart-define ব্যবহার করুন (নিচে দেখুন)।
/// 
/// Build করার সময়:
/// flutter run --dart-define=MONGO_API_KEY=your_key --dart-define=DOOD_API_KEY=your_key
/// 
/// অথবা সরাসরি নিচের placeholder গুলো পরিবর্তন করুন।
/// ============================================

class ApiConfig {
  // ---------- MongoDB Atlas Data API ----------
  static const String mongoCluster = "Cluster0";           // আপনার Cluster নাম
  static const String mongoDatabase = "stories_db";        // Database নাম
  static const String mongoCollection = "stories";         // Collection নাম

  // MongoDB Data API Base URL (App Services থেকে কপি করুন)
  // উদাহরণ: https://ap-south-1.aws.data.mongodb-api.com/app/data-xxxxx/endpoint/data/v1
  static const String mongoBaseUrl = String.fromEnvironment(
    'MONGO_BASE_URL',
    defaultValue: 'https://ap-south-1.aws.data.mongodb-api.com/app/data-XXXXX/endpoint/data/v1',
  );

  static const String mongoApiKey = String.fromEnvironment(
    'MONGO_API_KEY',
    defaultValue: 'YOUR_MONGODB_DATA_API_KEY',  // ← এখানে আপনার MongoDB API Key বসান
  );

  // ---------- DoodStream API ----------
  static const String doodStreamApiKey = String.fromEnvironment(
    'DOOD_API_KEY',
    defaultValue: 'YOUR_DOODSTREAM_API_KEY',    // ← এখানে আপনার DoodStream API Key বসান
  );

  // DoodStream API endpoints
  static const String doodListUrl = 'https://doodapi.com/api/file/list';
  static const String doodFileInfoUrl = 'https://doodapi.com/api/file/info';
}
