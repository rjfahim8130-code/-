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

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final content = _pick(json, ['content', 'content_text', 'body', 'text', 'story']);
    final imageUrl = _pick(json, [
      'imageUrl',
      'thumbnail_url',
      'thumbnail',
      'image',
      'cover',
      'poster',
    ]);
    String description = _pick(json, ['description', 'summary', 'code']);
    if (description.isEmpty && content.isNotEmpty) {
      description =
          content.length > 120 ? '${content.substring(0, 120)}...' : content;
    }

    return StoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: _pick(json, ['title', 'name', 'code'], fallback: 'Untitled'),
      description: description,
      content: content,
      imageUrl: imageUrl,
      author: _pick(json, ['author', 'writer'], fallback: 'Unknown'),
      category: _pick(json, ['category', 'type'], fallback: 'গল্প'),
      code: json['code']?.toString() ?? '',
      createdAt: _parseDate(
        json['createdAt'] ?? json['created_at'] ?? json['date'],
      ),
    );
  }

  static String _pick(
    Map json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final k in keys) {
      final v = json[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return fallback;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  String get cardSubtitle {
    if (description.isNotEmpty) return description;
    if (code.isNotEmpty) return code;
    return category;
  }

  bool get hasImage => imageUrl.isNotEmpty;

  String get episodeLabel {
    final m = RegExp(
      r'পর্ব\s*(\d+)|part\s*(\d+)|episode\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(title);
    if (m != null) {
      final n = m.group(1) ?? m.group(2) ?? m.group(3);
      return 'পর্ব $n';
    }
    if (code.isNotEmpty) return code;
    return category;
  }
}
