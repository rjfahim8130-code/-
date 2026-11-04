import 'package:flutter/material.dart';
import 'story_list_screen.dart';
import 'video_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class VaultHomeScreen extends StatefulWidget {
  @override
  _VaultHomeScreenState createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  bool isSyncing = false;

  // ইন-অ্যাপ সিঙ্ক ফাংশন (MongoDB এবং DoodStream থেকে নতুন ডেটা টানে)
  Future<void> _syncData() async {
    setState(() => isSyncing = true);
    // এখানে আপনার API কল বা লোকাল ক্যাশ আপডেট লজিক থাকবে
    await Future.delayed(Duration(seconds: 2)); 
    setState(() => isSyncing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("সকল ডেটা সফলভাবে সিঙ্ক হয়েছে!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("Private Vault"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: isSyncing ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.sync),
            onPressed: isSyncing ? null : _syncData,
            tooltip: "Sync & Refresh",
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("ক্যাটাগরি সমূহ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StoryListScreen())),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book, color: Colors.blueAccent, size: 40),
                        SizedBox(height: 8),
                        Text("গল্পসমূহ", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoListScreen())),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Icon(Icons.video_library, color: Colors.redAccent, size: 40),
                        SizedBox(height: 8),
                        Text("ভিডিও কালেকশন", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
