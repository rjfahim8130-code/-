import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'story_model.dart';
import 'video_model.dart';

class ApiService {
  static Future<List<StoryModel>> fetchStories() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/stories'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) return [];

      final dynamic decoded = json.decode(response.body);
      final List data = decoded is List
          ? decoded
          : (decoded is Map ? (decoded['stories'] ?? decoded['data'] ?? []) : []);

      return data
          .whereType<Map>()
          .map((e) => StoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('fetchStories error: $e');
      return [];
    }
  }

  static Future<List<VideoModel>> fetchVideos() async {
    try {
      final uri = Uri.parse(ApiConfig.doodListUrl).replace(queryParameters: {
        'key': ApiConfig.doodStreamApiKey,
        'per_page': '50',
      });
      final response =
          await http.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) return [];

      final dynamic decoded = json.decode(response.body);
      List list = [];
      if (decoded is Map) {
        final result = decoded['result'];
        if (result is Map && result['files'] is List) {
          list = result['files'];
        } else if (decoded['files'] is List) {
          list = decoded['files'];
        } else if (decoded['result'] is List) {
          list = decoded['result'];
        }
      }

      return list
          .whereType<Map>()
          .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('fetchVideos error: $e');
      return [];
    }
  }
}
