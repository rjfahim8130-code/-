import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import '../widgets/ad_top_native.dart'; // ⬅️ AdTopNative
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryListScreen({super.key, required this.stories});

  int _countWithAds(int n) => n + (n ~/ 2);
  int _dataIndex(int i) => i - (i ~/ 3);
  bool _isAdSlot(int i) => (i + 1) % 3 == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('গল্প ও উপন্যাস'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          const AdTopNative(), // ⬅️ AdBanner এর বদলে AdTopNative
          Expanded(
            child: stories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text('কোনো গল্প পাওয়া যায়নি', style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text(
                          'Sync করে আবার চেষ্টা করুন',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _countWithAds(stories.length),
                    itemBuilder: (context, i) {
                      if (_isAdSlot(i)) {
                        return const AdNative(height: 130); // ⬅️ উচ্চতা স্ট্যান্ডার্ড 130 করা হলো
                      }
                      final di = _dataIndex(i);
                      if (di < 0 || di >= stories.length) {
                        return const SizedBox.shrink();
                      }
                      final story = stories[di];
                      return _storyCard(context, story);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _storyCard(BuildContext context, StoryModel story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await AdPopunderHost.trigger();
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryDetailScreen(
                story: story,
                allStories: stories,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (story.hasImage)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: story.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 180, color: Colors.grey[900]),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(
                story.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                story.cardSubtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      story.category,
                      style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    story.author,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
