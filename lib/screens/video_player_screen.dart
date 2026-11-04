import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoTitle;

  VideoPlayerScreen({required this.videoTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(videoTitle), backgroundColor: Colors.black),
      body: Column(
        children: [
          // প্রথম অংশ: ভিডিও প্লেয়ার
          Container(
            height: 220,
            color: Colors.grey[900],
            child: Center(
              child: Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 64),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("অন্যান্য ভিডিও", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // দ্বিতীয় অংশ: নিচে হরাইজন্টাল স্ক্রোলিং থাম্বনেইল লিস্ট
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                          child: Center(child: Icon(Icons.video_library, color: Colors.white54)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("ভিডিও টাইটেল ${index + 1}", style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // তৃতীয় অংশ: বিজ্ঞাপনের খালি স্থান (Advertisement Area)
          Expanded(
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text("Advertisement Area", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
