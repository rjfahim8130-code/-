import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';
import '../services/video_open_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/ad_native.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final List<VideoModel> allVideos;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.allVideos = const [],
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoModel _current;
  WebViewController? _controller;
  bool _loading = true;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.video;
    _createAndLoad(_current.playUrl);
  }

  void _releaseController() {
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.loadRequest(Uri.parse('about:blank')).catchError((_) {});
    }
  }

  void _createAndLoad(String url) {
    _releaseController();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _tick++;
      _loading = true;
    });
  }

  void _switchTo(VideoModel v) {
    setState(() => _current = v);
    _createAndLoad(v.playUrl);
  }

  Future<void> _openExternal() async {
    final openedExternally = await VideoOpenService.tryOpenExternal(() async {
      final uri = Uri.parse(_current.playUrl);
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    });

    if (!openedExternally && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('এক্সটার্নাল ব্রাউজারে খুলতে সমস্যা হয়েছে বা কোটা শেষ।'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _releaseController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final others = widget.allVideos
        .where((v) => v.fileCode != _current.fileCode)
        .toList();

    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _current.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Column(
        children: [
          const AdBanner(),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: controller == null
                ? Container(color: Colors.black)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      WebViewWidget(
                        key: ValueKey(_tick),
                        controller: controller,
                      ),
                      if (_loading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _current.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (others.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'আরও ভিডিও',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: others.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final v = others[i];
                  return GestureDetector(
                    onTap: () => _switchTo(v),
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: v.thumbnail.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: v.thumbnail,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: Colors.grey[900]),
                            ),
                          ),
                          Text(
                            v.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: AdNative(height: 130),
          ),
        ],
      ),
    );
  }
}
