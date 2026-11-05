import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import 'reading_screen.dart';

class StoryDetailScreen extends StatelessWidget {
  final StoryModel story;
  final List<StoryModel> allStories;

  const StoryDetailScreen({
    super.key,
    required this.story,
    this.allStories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final others = allStories.where((s) => s.id != story.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            flexibleSpace: FlexibleSpaceBar(
              background: story.hasImage
                  ? CachedNetworkImage(
                      imageUrl: story.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.menu_book, size: 72, color: Colors.grey),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (story.code.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('কোড: ${story.code}',
                          style: TextStyle(color: Colors.blue[300], fontSize: 13)),
                    ),
                  Text(story.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(story.author, style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(story.category,
                            style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(story.description,
                      style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        foregroundColor: const Color(0xFF95D5B2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('সম্পূর্ণ পড়ুন',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReadingScreen(
                              story: story,
                              allStories: allStories,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const Text('আরও গল্প',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...others.take(8).map((s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: s.hasImage
                                ? CachedNetworkImage(
                                    imageUrl: s.imageUrl,
                                    width: 56,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56,
                                    height: 70,
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.menu_book, color: Colors.grey),
                                  ),
                          ),
                          title: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(s.cardSubtitle,
                              maxLines: 1, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StoryDetailScreen(
                                  story: s,
                                  allStories: allStories,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
