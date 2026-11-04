class ApiConfig {
  // MongoDB Atlas Data API Configuration (আপনার পাথ অনুযায়ী)
  static const String mongoCluster = "Cluster0";
  static const String mongoDatabase = "stories_db";
  static const String mongoCollection = "stories";
  
  // MongoDB Data API Endpoints (আপনার MongoDB App Services থেকে পাবেন)
  static const String mongoBaseUrl = "https://region.aws.services.cloud.mongodb.com/api/client/v2.0/app/YOUR_APP_ID/endpoint/data/v1";
  static const String mongoApiKey = "YOUR_MONGODB_DATA_API_KEY"; // গিটহাবে সিক্রেট হিসেবে রাখতে পারেন

  // DoodStream API Key
  static const String doodStreamApiKey = "YOUR_DOODSTREAM_API_KEY";
}
