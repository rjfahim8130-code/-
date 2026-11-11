enum LocalMediaType { image, video }

class LocalMediaModel {
  final String id;
  final String filePath;
  final LocalMediaType type;
  final String name;
  final DateTime addedAt;

  LocalMediaModel({
    required this.id,
    required this.filePath,
    required this.type,
    required this.name,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'type': type.name,
        'name': name,
        'addedAt': addedAt.toIso8601String(),
      };

  factory LocalMediaModel.fromJson(Map<String, dynamic> json) {
    return LocalMediaModel(
      id: json['id']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      type: json['type'] == 'video' ? LocalMediaType.video : LocalMediaType.image,
      name: json['name']?.toString() ?? 'file',
      addedAt: DateTime.tryParse(json['addedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isImage => type == LocalMediaType.image;
  bool get isVideo => type == LocalMediaType.video;
}
