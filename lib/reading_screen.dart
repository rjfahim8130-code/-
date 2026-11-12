import 'package:flutter/material.dart';
import 'story_model.dart';
import 'story_detail_screen.dart';
import 'ad_banner.dart';
import 'ad_native.dart';

class ReadingScreen extends StatefulWidget {
  final StoryModel story;
  final List<StoryModel> allStories;

  const ReadingScreen({
    super.key,
    required this.story,
    this.allStories = const [],
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  /// true = banner, false = native — প্রতি বার স্ক্রিন খুললে টগল
  static bool _showBannerNext = true;
  late final bool _useBanner;

  @override
  void initState() {
    super.initState();
    _useBanner = _showBannerNext;
    _showBannerNext = !_showBannerNext;
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final allStories = widget.allStories;
    final others = allStories.where((s) => s.id != story.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(story.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          if (_useBanner) const AdBanner() else const AdNative(height: 120),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'লেখক: ${story.author}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const Divider(height: 32, color: Colors.white12),
                Text(
                  story.content.isNotEmpty ? story.content : story.description,
                  style: const TextStyle(
                    fontSize: 16.5,
                    height: 1.7,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'আরও গল্প',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...others.take(8).map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.title,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryDetailScreen(
                              story: s,
                              allStories: allStories,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
