import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
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
  List<StoryModel> _filteredStories = [];
  List<VideoModel> _filteredVideos = [];

  void _search(String q) {
    setState(() {
      _query = q.toLowerCase().trim();
      if (_query.isEmpty) {
        _filteredStories = [];
        _filteredVideos = [];
      } else {
        _filteredStories = widget.stories
            .where((s) =>
                s.title.toLowerCase().contains(_query) ||
                s.description.toLowerCase().contains(_query) ||
                s.author.toLowerCase().contains(_query))
            .toList();
        _filteredVideos = widget.videos
            .where((v) => v.title.toLowerCase().contains(_query))
            .toList();
      }
    });
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
      body: _query.isEmpty
          ? Center(child: Text('কিছু লিখে সার্চ করুন', style: TextStyle(color: Colors.grey[600])))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_filteredStories.isNotEmpty) ...[
                  Text('গল্প (${_filteredStories.length})', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._filteredStories.map((s) => ListTile(
                        leading: const Icon(Icons.menu_book, color: Color(0xFF4CAF50)),
                        title: Text(s.title),
                        subtitle: Text(s.author, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(story: s))),
                      )),
                  const SizedBox(height: 16),
                ],
                if (_filteredVideos.isNotEmpty) ...[
                  Text('ভিডিও (${_filteredVideos.length})', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._filteredVideos.map((v) => ListTile(
                        leading: const Icon(Icons.play_circle, color: Color(0xFFE91E63)),
                        title: Text(v.title),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: v))),
                      )),
                ],
                if (_filteredStories.isEmpty && _filteredVideos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('কিছু পাওয়া যায়নি', style: TextStyle(color: Colors.grey[600]))),
                  ),
              ],
            ),
    );
  }
}
