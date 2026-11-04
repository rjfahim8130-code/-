import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';

class ApiService {
  // MongoDB থেকে গল্প ফেচ করা
  static Future<List<StoryModel>> fetchStories() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.mongoBaseUrl}/action/find'),
        headers: {
          'Content-Type': 'application/json',
          'api-key': ApiConfig.mongoApiKey,
        },
        body: jsonEncode({
          "dataSource": ApiConfig.mongoCluster,
          "database": ApiConfig.mongoDatabase,
          "collection": ApiConfig.mongoCollection,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List documents = data['documents'] ?? [];
        return documents.map((doc) => StoryModel.fromJson(doc)).toList();
      }
    } catch (e) {
      print("Story fetch error: $e");
    }
    return [];
  }

  // DoodStream API থেকে ভিডিও ফেচ করা
  static Future<List<VideoModel>> fetchVideos() async {
    try {
      final response = await http.get(
        Uri.parse('https://doodapi.com/api/file/list?key=${ApiConfig.doodStreamApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List files = data['result']['files'] ?? [];
        return files.map((file) => VideoModel.fromJson(file)).toList();
      }
    } catch (e) {
      print("Video fetch error: $e");
    }
    return [];
  }
}
