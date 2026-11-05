import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final List<VideoModel> allVideos;

  const VideoPlayerScreen({super.key, required this.video, this.allVideos = const []});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoModel _current;
  late WebViewController _controller;
  bool _loading = true;

  // নিচে অ্যাড দেখাতে চাইলে এখানে আপনার অ্যাড HTML/URL বসান
  static const String adBannerUrl = ''; // যেমন: 'https://your-ad-network.com/banner'

  @override
  void initState() {
    super.initState();
    _current = widget.video;
    _initPlayer(_current.playUrl);
  }

  void _initPlayer(String url) {
    setState(() => _loading = true);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _play(VideoModel v) {
    setState(() => _current = v);
    _initPlayer(v.playUrl);
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(_current.playUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final others = widget.allVideos.where((v) => v.fileCode != _current.fileCode).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_current.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.open_in_browser), tooltip: 'ব্রাউজারে খুলুন', onPressed: _openExternal),
        ],
      ),
      body: Column(
        children: [
          // ===== Video (top) =====
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_current.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2),
            ),
          ),

          // ===== Horizontal related videos =====
          if (others.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Align(alignment: Alignment.centerLeft, child: Text('আরও ভিডিও', style: TextStyle(color: Colors.grey, fontSize: 13))),
            ),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: others.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final v = others[i];
                  return GestureDetector(
                    onTap: () => _play(v),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: v.thumbnail.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: v.thumbnail, width: 140, fit: BoxFit.cover)
                                  : Container(color: Colors.grey[900], width: 140),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(v.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ===== Bottom ad space =====
          const Spacer(),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            alignment: Alignment.center,
            child: adBannerUrl.isEmpty
                ? Text('Ad Space', style: TextStyle(color: Colors.grey[700], fontSize: 12))
                : WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(adBannerUrl)),
                  ),
          ),
        ],
      ),
    );
  }
}
