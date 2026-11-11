import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'vault_home_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _expr = '';
  String _result = '';
  final _dobCtrl = TextEditingController();
  String _ageText = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _onKey(String k) {
    setState(() {
      if (k == 'C') {
        _expr = '';
        _result = '';
      } else if (k == '⌫') {
        if (_expr.isNotEmpty) {
          _expr = _expr.substring(0, _expr.length - 1);
        }
      } else if (k == '=') {
        _evaluate();
      } else {
        _expr += k;
      }
    });
  }

  Future<void> _evaluate() async {
    final pass = await StorageService.getPasscode();
    if (StorageService.normalizePasscode(_expr) ==
        StorageService.normalizePasscode(pass)) {
      await StorageService.setUnlocked(true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
      );
      return;
    }

    try {
      final v = _safeEval(_expr);
      setState(() => _result = _formatNum(v));
    } catch (_) {
      setState(() => _result = 'Error');
    }
  }

  double _safeEval(String input) {
    var s = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(' ', '');
    if (s.isEmpty) throw Exception('empty');
    // simple left-to-right + - * /
    final tokens = <String>[];
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if ('+-*/'.contains(c)) {
        if (buf.isEmpty && c == '-') {
          buf.write(c);
        } else {
          if (buf.isNotEmpty) tokens.add(buf.toString());
          buf.clear();
          tokens.add(c);
        }
      } else {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty) tokens.add(buf.toString());

    if (tokens.isEmpty) throw Exception('bad');

    // first * /
    final stack = <String>[tokens.first];
    for (var i = 1; i < tokens.length; i += 2) {
      if (i + 1 >= tokens.length) break;
      final op = tokens[i];
      final num = tokens[i + 1];
      if (op == '*' || op == '/') {
        final a = double.parse(stack.removeLast());
        final b = double.parse(num);
        final r = op == '*' ? a * b : a / b;
        stack.add(r.toString());
      } else {
        stack.add(op);
        stack.add(num);
      }
    }

    var acc = double.parse(stack.first);
    for (var i = 1; i < stack.length; i += 2) {
      if (i + 1 >= stack.length) break;
      final op = stack[i];
      final b = double.parse(stack[i + 1]);
      if (op == '+') {
        acc += b;
      } else if (op == '-') {
        acc -= b;
      }
    }
    return acc;
  }

  String _formatNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _calcAge() {
    final raw = _dobCtrl.text.trim();
    final dob = DateTime.tryParse(raw) ?? _parseBnDate(raw);
    if (dob == null) {
      setState(() => _ageText = 'তারিখ লিখুন: YYYY-MM-DD');
      return;
    }
    final now = DateTime.now();
    var years = now.year - dob.year;
    var months = now.month - dob.month;
    var days = now.day - dob.day;
    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    setState(() {
      _ageText = '$years বছর $months মাস $days দিন';
    });
  }

  DateTime? _parseBnDate(String s) {
    final p = s.split(RegExp(r'[/\-.]'));
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  Widget _btn(String label, {Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onKey(label),
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
            ),
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
        title: const Text('Age Calculator'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Calculator'),
            Tab(text: 'Age'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _expr.isEmpty ? '0' : _expr,
                        style: TextStyle(fontSize: 28, color: Colors.grey[400]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: Column(
                  children: [
                    Row(children: [
                      _btn('C', color: const Color(0xFF5D4037)),
                      _btn('⌫', color: const Color(0xFF5D4037)),
                      _btn('÷', color: const Color(0xFF1565C0)),
                      _btn('×', color: const Color(0xFF1565C0)),
                    ]),
                    Row(children: [
                      _btn('7'),
                      _btn('8'),
                      _btn('9'),
                      _btn('-', color: const Color(0xFF1565C0)),
                    ]),
                    Row(children: [
                      _btn('4'),
                      _btn('5'),
                      _btn('6'),
                      _btn('+', color: const Color(0xFF1565C0)),
                    ]),
                    Row(children: [
                      _btn('1'),
                      _btn('2'),
                      _btn('3'),
                      _btn('=', color: const Color(0xFF2E7D32)),
                    ]),
                    Row(children: [
                      _btn('0', flex: 2),
                      _btn('.'),
                      _btn('00'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'জন্ম তারিখ (YYYY-MM-DD)',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dobCtrl,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    hintText: '1990-05-15',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _calcAge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('বয়স হিসাব করুন'),
                ),
                const SizedBox(height: 24),
                if (_ageText.isNotEmpty)
                  Text(
                    _ageText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
