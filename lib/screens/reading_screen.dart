import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../widgets/ad_top_native.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';

class ReadingScreen extends StatelessWidget {
  final StoryModel story;
  final List<StoryModel> allStories;

  const ReadingScreen({
    super.key,
    required this.story,
    this.allStories = const [],
  });

  Future<void> _openAnother(BuildContext context, StoryModel other) async {
    await AdPopunderHost.trigger();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          story: other,
          allStories: allStories,
        ),
      ),
    );
  }

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
          const AdTopNative(),
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
                const SizedBox(height: 20),
                const AdNative(height: 130),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'আরও গল্প',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  ...others.take(8).map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.title,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => _openAnother(context, s),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
