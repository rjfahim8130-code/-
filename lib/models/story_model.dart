class StoryModel {
  final String id;
  final String code;
  final String title;
  final String category;
  final String thumbnailUrl;
  final String contentText;
  final String partNumber;
  final String nextPartCode;

  StoryModel({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.contentText,
    required this.partNumber,
    required this.nextPartCode,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      contentText: json['content_text'] ?? '',
      partNumber: json['partNumber'] ?? '1',
      nextPartCode: json['nextPartCode'] ?? '',
    );
  }
}
