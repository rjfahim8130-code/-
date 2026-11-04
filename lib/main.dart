import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(VaultApp());
}

class VaultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: CalculatorScreen(), // অ্যাপ চালু হলেই ক্যালকুলেটর স্ক্রিন আসবে
    );
  }
}
