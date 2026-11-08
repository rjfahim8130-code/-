import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';
import '../widgets/ad_top_native.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
import '../services/video_open_service.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatelessWidget {
  final List<VideoModel> videos;

  const VideoListScreen({super.key, required this.videos});

  // ───────────────────────── Helpers ─────────────────────────

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _countWithAds(int n) => n + (n ~/ 2);
  int _dataIndex(int i) => i - (i ~/ 3);
  bool _isAdSlot(int i) => (i + 1) % 3 == 0;

  // ───────────────────────── Video open ─────────────────────────

  Future<void> _openVideo(BuildContext context, VideoModel video) async {
    await AdPopunderHost.trigger();

    final openedExternally = await VideoOpenService.tryOpenExternal(() async {
      final uri = Uri.parse(video.playUrl);
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    });

    if (openedExternally) return;

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video, allVideos: videos),
      ),
    );
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('ভিডিও'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          const AdTopNative(),
          Expanded(
            child: videos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off_outlined,
                            size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text('কোনো ভিডিও পাওয়া যায়নি',
                            style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text(
                          'API Key চেক করুন বা Sync করুন',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _countWithAds(videos.length),
                    itemBuilder: (context, i) {
                      if (_isAdSlot(i)) {
                        return const AdNative(height: 130);
                      }
                      final di = _dataIndex(i);
                      if (di < 0 || di >= videos.length) {
                        return const SizedBox.shrink();
                      }
                      return _videoCard(context, videos[di]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Card ─────────────────────────

  Widget _videoCard(BuildContext context, VideoModel video) {
    return GestureDetector(
      onTap: () => _openVideo(context, video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    video.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[900]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.videocam,
                                  color: Colors.grey, size: 40),
                            ),
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(Icons.videocam,
                                  color: Colors.grey, size: 40),
                            ),
                          ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(video.length),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 48),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.views} views',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
