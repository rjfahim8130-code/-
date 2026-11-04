import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../services/api_service.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatefulWidget {
  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  List<StoryModel> stories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() async {
    setState(() => isLoading = true);
    final data = await ApiService.fetchStories();
    setState(() {
      stories = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(title: Text("সকল গল্প"), backgroundColor: Colors.black),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return ListTile(
                  leading: story.thumbnailUrl.isNotEmpty
                      ? Image.network(story.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.book, color: Colors.white54, size: 40),
                  title: Text(story.title, style: TextStyle(color: Colors.white)),
                  subtitle: Text("পর্ব: ${story.partNumber}", style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDetailScreen(storyTitle: story.title),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
