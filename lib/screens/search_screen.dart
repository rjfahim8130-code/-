import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "গল্প বা ভিডিও সার্চ করুন...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // সার্চ ফিল্টার লজিক
          },
        ),
      ),
      body: Center(
        child: Text("আপনার কাঙ্ক্ষিত গল্প বা ভিডিও খুঁজতে নাম লিখুন", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
