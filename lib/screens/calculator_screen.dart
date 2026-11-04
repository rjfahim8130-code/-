import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'vault_home_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  String _passcode = '25*52';
  bool _isResult = false;

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  Future<void> _loadPasscode() async {
    final code = await StorageService.getPasscode();
    setState(() => _passcode = code);
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _isResult = false;
      } else if (value == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          _display = '0';
          _expression = '';
        }
      } else if (value == '=') {
        final cleanInput = _expression.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/');
        final cleanPass = _passcode.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/');

        if (cleanInput == cleanPass) {
          // পাসকোড মিলেছে → Vault আনলক
          StorageService.setUnlocked(true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
          );
        } else {
          // সাধারণ ক্যালকুলেটর ফলাফল (ছদ্মবেশ)
          try {
            final result = _evaluate(cleanInput);
            _display = result.toString();
            _expression = result.toString();
            _isResult = true;
          } catch (_) {
            _display = 'Error';
            _expression = '';
          }
        }
      } else {
        if (_isResult) {
          _display = value;
          _expression = value;
          _isResult = false;
        } else {
          if (_display == '0' && value != '.' && value != '+' && value != '-' && value != '×' && value != '÷') {
            _display = value;
            _expression = value;
          } else {
            _display += value;
            _expression += value;
          }
        }
      }
    });
  }

  double _evaluate(String expr) {
    // খুব সিম্পল evaluator (শুধু +, -, *, /)
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    // নিরাপদ নয়, কিন্তু ছদ্মবেশের জন্য যথেষ্ট
    try {
      // ignore: avoid_dynamic_calls
      return double.parse(expr); // fallback
    } catch (_) {
      // আরও ভালো: simple parser
      final parts = expr.split(RegExp(r'([+\-*/])'));
      if (parts.length < 3) return double.tryParse(expr) ?? 0;
      double a = double.tryParse(parts[0]) ?? 0;
      String op = parts[1];
      double b = double.tryParse(parts[2]) ?? 0;
      switch (op) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/': return b != 0 ? a / b : 0;
        default: return 0;
      }
    }
  }

  Widget _buildButton(String text, {Color? bg, Color? fg, double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg ?? const Color(0xFF1E1E1E),
            foregroundColor: fg ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: text == '=' || text == 'C' ? 26 : 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Age Calculator', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Age Calculator'),
                  content: const Text('Enter birth year or use calculator.\nThis is a simple age calculator app.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty && _expression != _display)
                      Text(
                        _expression,
                        style: TextStyle(color: Colors.grey[500], fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Keypad
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(children: [
                      _buildButton('C', bg: const Color(0xFFCF6679), fg: Colors.white),
                      _buildButton('⌫', bg: const Color(0xFF2A2A2A)),
                      _buildButton('÷', bg: const Color(0xFF2A2A2A)),
                      _buildButton('×', bg: const Color(0xFF2A2A2A)),
                    ]),
                    Row(children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('-', bg: const Color(0xFF2A2A2A)),
                    ]),
                    Row(children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('+', bg: const Color(0xFF2A2A2A)),
                    ]),
                    Row(children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('=', bg: const Color(0xFF1E88E5), fg: Colors.white),
                    ]),
                    Row(children: [
                      _buildButton('0', flex: 2),
                      _buildButton('.'),
                      _buildButton('00'),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
