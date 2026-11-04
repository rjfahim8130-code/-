class StoryModel {
  final String id;
  final String title;
  final String description;
  final String content;      // সম্পূর্ণ গল্পের টেক্সট
  final String imageUrl;     // ডাইরেক্ট ইমেজ লিংক (ImgBB / PostImages)
  final String author;
  final String category;     // গল্প / উপন্যাস
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    this.author = 'Unknown',
    this.category = 'গল্প',
    this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      content: json['content'] ?? json['body'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['cover'] ?? '',
      author: json['author'] ?? 'Unknown',
      category: json['category'] ?? 'গল্প',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'content': content,
        'imageUrl': imageUrl,
        'author': author,
        'category': category,
        'createdAt': createdAt?.toIso8601String(),
      };
}
