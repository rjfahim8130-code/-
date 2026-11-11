import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'local_media_model.dart';
import 'local_media_service.dart';

class LocalVaultScreen extends StatefulWidget {
  final bool embedded;
  const LocalVaultScreen({super.key, this.embedded = false});

  @override
  State<LocalVaultScreen> createState() => _LocalVaultScreenState();
}

class _LocalVaultScreenState extends State<LocalVaultScreen> {
  List<LocalMediaModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final list = await LocalMediaService.listAll();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    await LocalMediaService.importFile(
      sourcePath: x.path,
      type: LocalMediaType.image,
      displayName: x.name,
    );
    await _reload();
  }

  Future<void> _addVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    await LocalMediaService.importFile(
      sourcePath: path,
      type: LocalMediaType.video,
      displayName: result.files.single.name,
    );
    await _reload();
  }

  Future<void> _delete(LocalMediaModel m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('মুছবেন?'),
        content: Text(m.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('না')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('হ্যাঁ')),
        ],
      ),
    );
    if (ok == true) {
      await LocalMediaService.delete(m.id);
      await _reload();
    }
  }

  void _open(LocalMediaModel m) {
    if (m.isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageViewer(path: m.filePath, title: m.name),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _VideoViewer(path: m.filePath, title: m.name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off, size: 64, color: Colors.grey[700]),
                    const SizedBox(height: 12),
                    Text('কোনো লোকাল ফাইল নেই',
                        style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 8),
                    Text('নিচের + দিয়ে ছবি/ভিডিও যোগ করুন',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final m = _items[i];
                  return GestureDetector(
                    onTap: () => _open(m),
                    onLongPress: () => _delete(m),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: m.isImage
                                ? Image.file(
                                    File(m.filePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey),
                                  )
                                : Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: Icon(Icons.videocam,
                                          color: Colors.white54, size: 36),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

    if (widget.embedded) {
      return Stack(
        children: [
          body,
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'img',
                  onPressed: _addImage,
                  child: const Icon(Icons.image),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'vid',
                  onPressed: _addVideo,
                  child: const Icon(Icons.videocam),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('লোকাল ভল্ট'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'img2',
            onPressed: _addImage,
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'vid2',
            onPressed: _addVideo,
            child: const Icon(Icons.videocam),
          ),
        ],
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String path;
  final String title;
  const _ImageViewer({required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String path;
  final String title;
  const _VideoViewer({required this.path, required this.title});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  VideoPlayerController? _vpc;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _vpc = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        _chewie = ChewieController(
          videoPlayerController: _vpc!,
          autoPlay: true,
          looping: false,
        );
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black),
      body: Center(
        child: _chewie != null
            ? Chewie(controller: _chewie!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
