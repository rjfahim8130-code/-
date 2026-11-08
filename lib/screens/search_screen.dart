import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ⬅️ url_launcher যোগ করা হলো
import '../models/story_model.dart';
import '../models/video_model.dart';
import '../widgets/ad_top_native.dart'; // ⬅️ AdTopNative
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
import '../services/video_open_service.dart'; // ⬅️ VideoOpenService
import 'story_detail_screen.dart';
import 'video_player_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final List<VideoModel> videos;

  const SearchScreen({super.key, required this.stories, required this.videos});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  List<StoryModel> _fs = [];
  List<VideoModel> _fv = [];

  void _search(String q) {
    setState(() {
      _query = q.toLowerCase().trim();
      if (_query.isEmpty) {
        _fs = [];
        _fv = [];
      } else {
        _fs = widget.stories
            .where((s) =>
                s.title.toLowerCase().contains(_query) ||
                s.description.toLowerCase().contains(_query) ||
                s.author.toLowerCase().contains(_query) ||
                s.code.toLowerCase().contains(_query))
            .toList();
        _fv = widget.videos
            .where((v) => v.title.toLowerCase().contains(_query))
            .toList();
      }
    });
  }

  /// ✅ ভিডিও ট্যাপে সেফ VideoOpenService লজিক
  Future<void> _openVideo(VideoModel video) async {
    await AdPopunderHost.trigger();

    final openedExternally = await VideoOpenService.tryOpenExternal(() async {
      final uri = Uri.parse(video.playUrl);
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    });

    if (openedExternally) return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video, allVideos: widget.videos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'গল্প বা ভিডিও খুঁজুন...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: Column(
        children: [
          const AdTopNative(), // ⬅️ AdBanner এর বদলে AdTopNative
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Text('কিছু লিখে সার্চ করুন', style: TextStyle(color: Colors.grey[600])),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_fs.isNotEmpty) ...[
                        Text(
                          'গল্প (${_fs.length})',
                          style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ..._fs.map(
                          (s) => ListTile(
                            leading: const Icon(Icons.menu_book, color: Color(0xFF4CAF50)),
                            title: Text(s.title, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              s.cardSubtitle,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            onTap: () async {
                              await AdPopunderHost.trigger();
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryDetailScreen(
                                    story: s,
                                    allStories: widget.stories,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AdNative(height: 130), // ⬅️ উচ্চতা স্ট্যান্ডার্ড 130 করা হলো
                        const SizedBox(height: 16),
                      ],
                      if (_fv.isNotEmpty) ...[
                        Text(
                          'ভিডিও (${_fv.length})',
                          style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ..._fv.map(
                          (v) => ListTile(
                            leading: const Icon(Icons.play_circle, color: Color(0xFFE91E63)),
                            title: Text(v.title, style: const TextStyle(color: Colors.white)),
                            onTap: () => _openVideo(v), // ⬅️ আপডেট করা _openVideo ব্যবহার
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AdNative(height: 130), // ⬅️ উচ্চতা স্ট্যান্ডার্ড 130 করা হলো
                      ],
                      if (_fs.isEmpty && _fv.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text('কিছু পাওয়া যায়নি', style: TextStyle(color: Colors.grey[600])),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
