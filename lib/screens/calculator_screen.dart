import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vault_home_screen.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = "";
  String _passcode = "25*52"; // ডিফল্ট পাসকোড

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  void _loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _passcode = prefs.getString('secret_passcode') ?? "25*52";
    });
  }

  void _onBtnPressed(String val) {
    setState(() {
      if (val == "C") {
        _input = "";
      } else if (val == "=") {
        if (_input.replaceAll(" ", "") == _passcode.replaceAll(" ", "")) {
          _input = "";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VaultHomeScreen()),
          );
        } else {
          _input = "Age: 18 Years"; // সাধারণ ক্যালকুলেটর বা বয়স হিসাবের ছদ্মবেশ
        }
      } else {
        _input += val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Age Calculator"), backgroundColor: Colors.grey[900]),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(_input, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            ),
          ),
          // ক্যালকুলেটর কিপ্যাড ডিজাইন
          _buildKeypadRow(["7", "8", "9", "/"]),
          _buildKeypadRow(["4", "5", "6", "*"]),
          _buildKeypadRow(["1", "2", "3", "-"]),
          _buildKeypadRow(["C", "0", "=", "+"]),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) => Expanded(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[850]),
              onPressed: () => _onBtnPressed(btn),
              child: Text(btn, style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
