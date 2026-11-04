import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  final String title;
  final String partNumber;
  final String contentText;
  final String? nextPartCode;

  ReadingScreen({
    required this.title,
    required this.partNumber,
    required this.contentText,
    this.nextPartCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text("$title - পর্ব $partNumber"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentText,
              style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // পূর্ববর্তী পর্বের লজিক
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text("পূর্ববর্তী পর্ব"),
                ),
                if (nextPartCode != null && nextPartCode!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      // পরবর্তী পর্ব লোড করার লজিক
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text("পরবর্তী পর্ব"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
