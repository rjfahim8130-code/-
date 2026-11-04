import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<VideoModel> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() async {
    setState(() => isLoading = true);
    final data = await ApiService.fetchVideos();
    setState(() {
      videos = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(title: Text("ভিডিও কালেকশন"), backgroundColor: Colors.black),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  leading: Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 40),
                  title: Text(video.title, style: TextStyle(color: Colors.white)),
                  subtitle: Text(video.length ?? '', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(videoTitle: video.title),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
