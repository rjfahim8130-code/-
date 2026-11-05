import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryListScreen({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('গল্প ও উপন্যাস'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: stories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text('কোনো গল্প পাওয়া যায়নি', style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Sync করে আবার চেষ্টা করুন', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Card(
                  color: const Color(0xFF1A1A1A),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: story.hasImage
                                ? CachedNetworkImage(
                                    imageUrl: story.imageUrl,
                                    width: 80,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 80,
                                      height: 100,
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 80,
                                      height: 100,
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 100,
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.menu_book, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  story.cardSubtitle,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
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
                                    Text(story.author, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
