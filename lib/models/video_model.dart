class VideoModel {
  final String fileCode;
  final String title;
  final String thumbnail;
  final int length;          // সেকেন্ডে
  final int views;
  final String uploaded;

  VideoModel({
    required this.fileCode,
    required this.title,
    required this.thumbnail,
    this.length = 0,
    this.views = 0,
    this.uploaded = '',
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      fileCode: json['file_code']?.toString() ?? json['filecode']?.toString() ?? '',
      title: json['title'] ?? json['file_title'] ?? 'Untitled Video',
      thumbnail: json['single_img'] ?? json['splash_img'] ?? json['thumbnail'] ?? '',
      length: int.tryParse(json['length']?.toString() ?? '0') ?? 0,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      uploaded: json['uploaded'] ?? json['upload_date'] ?? '',
    );
  }

  /// DoodStream embed / play URL
  String get playUrl => 'https://dood.ws/e/$fileCode';
  String get downloadUrl => 'https://dood.ws/d/$fileCode';
}
