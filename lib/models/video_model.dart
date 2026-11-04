class VideoModel {
  final String title;
  final String directLink;
  final String? length;
  final String? thumbnail;

  VideoModel({
    required this.title,
    required this.directLink,
    this.length,
    this.thumbnail,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'] ?? 'Untitled Video',
      directLink: json['protected_embed'] ?? json['url'] ?? '',
      length: json['length']?.toString(),
      thumbnail: json['thumbnail'],
    );
  }
}
