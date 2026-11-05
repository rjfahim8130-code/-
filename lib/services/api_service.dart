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

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List data = decoded is List ? decoded : (decoded['stories'] ?? []);
        return data
            .whereType()
            .map((doc) => StoryModel.fromJson(Map<String, dynamic>.from(doc)))
            .toList();
      } else {
        print('Backend error: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      print('Story fetch error: $e');
    }
    return [];
  }

  static Future<List<VideoModel>> fetchVideos({int page = 1, int perPage = 50}) async {
    try {
      // সঠিক ইউআরএল স্ট্রিং ইন্টারপোলেশন
      final url = '${ApiConfig.doodListUrl}?key=${ApiConfig.doodStreamApiKey}&page=$page&per_page=$perPage';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 || data['result'] != null) {
          final List files = data['result']?['files'] ?? data['result'] ?? [];
          return files
              .whereType()
              .map((file) => VideoModel.fromJson(Map<String, dynamic>.from(file)))
              .toList();
        }
      } else {
        print('DoodStream error: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      print('Video fetch error: $e');
    }
    return [];
  }
}
