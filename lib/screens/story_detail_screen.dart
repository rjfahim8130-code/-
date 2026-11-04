import 'package:flutter/material.dart';
import 'reading_screen.dart';

class StoryDetailScreen extends StatelessWidget {
  final String storyTitle;

  StoryDetailScreen({required this.storyTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(title: Text(storyTitle), backgroundColor: Colors.black),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("পর্বসমূহ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          // ডেমো পর্ব লিস্ট (MongoDB ডেটার সাথে কানেক্ট হবে)
          ...List.generate(5, (index) => Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text("পর্ব ${index + 1}", style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingScreen(
                      title: storyTitle,
                      partNumber: "${index + 1}",
                      contentText: "এখানে ${index + 1} নম্বর পর্বের মূল লেখা থাকবে...",
                    ),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }
}
