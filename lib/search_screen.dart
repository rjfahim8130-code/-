import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'story_model.dart';
import 'video_model.dart';
import 'story_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final List<VideoModel> videos;

  const SearchScreen({
    super.key,
    required this.stories,
    required this.videos,
  });

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

  Future<void> _openVideo(VideoModel v) async {
    await launchUrl(Uri.parse(v.playUrl), mode: LaunchMode.externalApplication);
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
          ? Center(
              child: Text('কিছু লিখে সার্চ করুন',
                  style: TextStyle(color: Colors.grey[600])),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_fs.isNotEmpty) ...[
                  Text('গল্প (${_fs.length})',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600)),
                  ..._fs.map(
                    (s) => ListTile(
                      leading: const Icon(Icons.menu_book,
                          color: Color(0xFF4CAF50)),
                      title: Text(s.title,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryDetailScreen(
                            story: s,
                            allStories: widget.stories,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (_fv.isNotEmpty) ...[
                  Text('ভিডিও (${_fv.length})',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600)),
                  ..._fv.map(
                    (v) => ListTile(
                      leading: const Icon(Icons.open_in_browser,
                          color: Color(0xFFE91E63)),
                      title: Text(v.title,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () => _openVideo(v),
                    ),
                  ),
                ],
                if (_fs.isEmpty && _fv.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text('কিছু পাওয়া যায়নি',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
              ],
            ),
    );
  }
}
