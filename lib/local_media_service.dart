import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'local_media_model.dart';

/// Copies media into app-private storage (not visible in gallery).
class LocalMediaService {
  static const _metaKey = 'local_media_meta_v1';
  static const _uuid = Uuid();

  static Future<Directory> _mediaDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'private_vault_media'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<List<LocalMediaModel>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      final items = list
          .whereType<Map>()
          .map((e) => LocalMediaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      // drop missing files
      final existing = <LocalMediaModel>[];
      for (final m in items) {
        if (await File(m.filePath).exists()) {
          existing.add(m);
        }
      }
      if (existing.length != items.length) {
        await _saveMeta(existing);
      }
      existing.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return existing;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveMeta(List<LocalMediaModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _metaKey,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<LocalMediaModel?> importFile({
    required String sourcePath,
    required LocalMediaType type,
    String? displayName,
  }) async {
    final src = File(sourcePath);
    if (!await src.exists()) return null;

    final dir = await _mediaDir();
    final id = _uuid.v4();
    final ext = p.extension(sourcePath);
    final name = displayName ?? p.basename(sourcePath);
    final destPath = p.join(dir.path, '$id$ext');
    await src.copy(destPath);

    final model = LocalMediaModel(
      id: id,
      filePath: destPath,
      type: type,
      name: name,
      addedAt: DateTime.now(),
    );

    final all = await listAll();
    all.insert(0, model);
    await _saveMeta(all);
    return model;
  }

  static Future<bool> delete(String id) async {
    final all = await listAll();
    final idx = all.indexWhere((e) => e.id == id);
    if (idx < 0) return false;
    final item = all[idx];
    try {
      final f = File(item.filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    all.removeAt(idx);
    await _saveMeta(all);
    return true;
  }
}
