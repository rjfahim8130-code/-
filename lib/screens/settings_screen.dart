import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passController = TextEditingController();

  void _saveNewPasscode() async {
    if (_passController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secret_passcode', _passController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে!")),
      );
      _passController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.black),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("সিক্রেট পাসওয়ার্ড সেট করুন (যেমন: 25*52)", style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          TextField(
            controller: _passController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              hintText: "নতুন পাসওয়ার্ড লিখুন",
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveNewPasscode,
            child: Text("সেভ করুন"),
          ),
        ],
      ),
    );
  }
}
