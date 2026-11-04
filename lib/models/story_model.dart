class StoryModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String author;
  final String category;
  final String code;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.title,
    this.description = '',
    this.content = '',
    this.imageUrl = '',
    this.author = 'Unknown',
    this.category = 'গল্প',
    this.code = '',
    this.createdAt,
  });

  /// যতটুকু তথ্য পায়, ততটুকু দিয়েই অবজেক্ট বানায়
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // title fallback চেইন
    final title = _firstNonEmpty([
      json['title'],
      json['name'],
      json['code'],
      'Untitled',
    ]);

    // content fallback
    final content = _firstNonEmpty([
      json['content'],
      json['content_text'],
      json['body'],
      json['text'],
      json['story'],
      '',
    ]);

    // image fallback
    final imageUrl = _firstNonEmpty([
      json['imageUrl'],
      json['thumbnail_url'],
      json['thumbnail'],
      json['image'],
      json['cover'],
      json['poster'],
      '',
    ]);

    // description — না থাকলে content-এর প্রথম ১২০ অক্ষর
    String description = _firstNonEmpty([
      json['description'],
      json['summary'],
      json['code'],
      '',
    ]);
    if (description.isEmpty && content.isNotEmpty) {
      description = content.length > 120 ? '${content.substring(0, 120)}...' : content;
    }

    return StoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: title,
      description: description,
      content: content,
      imageUrl: imageUrl,
      author: _firstNonEmpty([json['author'], json['writer'], 'Unknown']),
      category: _firstNonEmpty([json['category'], json['type'], 'গল্প']),
      code: json['code']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  /// null / খালি স্ট্রিং এড়িয়ে প্রথম ভ্যালিড মান নেয়
  static String _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  /// কার্ডে দেখানোর জন্য সংক্ষিপ্ত টেক্সট
  String get cardSubtitle {
    if (description.isNotEmpty) return description;
    if (code.isNotEmpty) return code;
    if (author.isNotEmpty && author != 'Unknown') return author;
    return category;
  }

  /// ইমেজ আছে কিনা
  bool get hasImage => imageUrl.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'content': content,
        'imageUrl': imageUrl,
        'author': author,
        'category': category,
        'code': code,
        'createdAt': createdAt?.toIso8601String(),
      };
}
