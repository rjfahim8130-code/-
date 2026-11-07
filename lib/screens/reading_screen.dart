import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../widgets/ad_social_bar.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
import 'story_detail_screen.dart';

class ReadingScreen extends StatelessWidget {
  final StoryModel story;
  final List<StoryModel> allStories;

  const ReadingScreen({
    super.key,
    required this.story,
    this.allStories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final others = allStories.where((s) => s.id != story.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(story.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          // রিডারে ব্যানার নয় — Social Bar সবসময় উপরে
          const AdSocialBar(height: 56),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.white,
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
                const SizedBox(height: 24),
                const AdNative(height: 250),
                const SizedBox(height: 16),
                if (others.isNotEmpty) ...[
                  const Text(
                    'আরও গল্প',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...others.take(10).map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.title, maxLines: 2, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        s.cardSubtitle,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () async {
                        await AdPopunderHost.trigger();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StoryDetailScreen(story: s, allStories: allStories),
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
