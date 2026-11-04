import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';

class ApiService {
  /// FastAPI থেকে সব গল্প ফেচ
  static Future<List<StoryModel>> fetchStories() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/stories'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List data = decoded is List ? decoded : (decoded['stories'] ?? []);
        return data
            .whereType() // শুধু ম্যাপ আইটেম
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

  /// DoodStream থেকে ভিডিও লিস্ট
  static Future<List<VideoModel>> fetchVideos({int page = 1, int perPage = 50}) async {
    try {
      final url =
          '${ApiConfig.doodListUrl}?key=${ApiConfig.doodStreamApiKey}&page=$page&per_page=$perPage';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

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
