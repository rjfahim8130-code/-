import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';

class ApiService {
  static Future<List<StoryModel>> fetchStories() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/stories'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('Backend error: ${response.statusCode} → ${response.body}');
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      final List raw = decoded is List
          ? decoded
          : decoded is Map && decoded['stories'] is List
              ? decoded['stories'] as List
              : [];

      return raw
          .whereType<Map>()
          .map((doc) => StoryModel.fromJson(Map<String, dynamic>.from(doc)))
          .toList();
    } catch (e) {
      print('Story fetch error: $e');
      return [];
    }
  }

  static Future<List<VideoModel>> fetchVideos({
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final url =
          '${ApiConfig.doodListUrl}?key=${ApiConfig.doodStreamApiKey}&page=$page&per_page=$perPage';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        print('DoodStream error: ${response.statusCode} → ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      if (data is! Map) return [];

      final statusOk = data['status'] == 200;
      final result = data['result'];
      if (!statusOk && result == null) return [];

      final List raw = result is List
          ? result
          : result is Map && result['files'] is List
              ? result['files'] as List
              : [];

      return raw
          .whereType<Map>()
          .map((file) => VideoModel.fromJson(Map<String, dynamic>.from(file)))
          .toList();
    } catch (e) {
      print('Video fetch error: $e');
      return [];
    }
  }
}
