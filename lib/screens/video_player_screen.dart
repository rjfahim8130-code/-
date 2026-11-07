import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';

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
  late WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _current = widget.video;
    _load(_current.playUrl);
  }

  void _load(String url) {
    setState(() => _loading = true);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _switchTo(VideoModel v) {
    setState(() => _current = v);
    _load(v.playUrl);
  }

  Future<void> _openExternal() async {
    await AdPopunderHost.trigger();
    final uri = Uri.parse(_current.playUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final others = widget.allVideos
        .where((v) => v.fileCode != _current.fileCode)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_current.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'ব্রাউজারে খুলুন',
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _current.title,
                style: const TextStyle(
                  fontSize: 15,
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
              padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('আরও ভিডিও', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: others.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final v = others[i];
                  return GestureDetector(
                    onTap: () => _switchTo(v),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  v.thumbnail.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: v.thumbnail,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Container(color: Colors.grey[900]),
                                        )
                                      : Container(color: Colors.grey[900]),
                                  const Center(
                                    child: Icon(Icons.play_circle_fill,
                                        color: Colors.white70, size: 36),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // হরাইজন্টালের ঠিক পরে Native — Spacer নেই
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: AdNative(height: 250),
              ),
            ),
          ),
          const SafeArea(top: false, child: SizedBox(height: 4)),
        ],
      ),
    );
  }
}
