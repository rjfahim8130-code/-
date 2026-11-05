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
                if (_fs.isNotEmpty) ...[
                  Text('গল্প (${_fs.length})',
                      style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._fs.map((s) => ListTile(
                        leading: const Icon(Icons.menu_book, color: Color(0xFF4CAF50)),
                        title: Text(s.title),
                        subtitle: Text(s.cardSubtitle,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryDetailScreen(
                              story: s,
                              allStories: widget.stories,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (_fv.isNotEmpty) ...[
                  Text('ভিডিও (${_fv.length})',
                      style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._fv.map((v) => ListTile(
                        leading: const Icon(Icons.play_circle, color: Color(0xFFE91E63)),
                        title: Text(v.title),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(
                              video: v,
                              allVideos: widget.videos,
                            ),
                          ),
                        ),
                      )),
                ],
                if (_fs.isEmpty && _fv.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                        child: Text('কিছু পাওয়া যায়নি', style: TextStyle(color: Colors.grey[600]))),
                  ),
              ],
            ),
    );
  }
}
