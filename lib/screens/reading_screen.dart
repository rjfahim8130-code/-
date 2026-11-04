import 'package:flutter/material.dart';
import '../models/story_model.dart';

class ReadingScreen extends StatelessWidget {
  final StoryModel story;

  const ReadingScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(story.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
