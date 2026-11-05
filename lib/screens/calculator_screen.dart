import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'vault_home_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ---- Normal calculator ----
  String _expr = '';
  String _result = '0';
  String _passcode = '25*52';

  // ---- Age calculator ----
  final _birthCtrl = TextEditingController();
  String _ageResult = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadPasscode();
  }

  @override
  void dispose() {
    _tab.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPasscode() async {
    final code = await StorageService.getPasscode();
    if (mounted) setState(() => _passcode = code);
  }

  // ---------- Math engine (correct order: * / then + -) ----------
  double? _eval(String input) {
    try {
      var s = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(' ', '');
      if (s.isEmpty) return null;

      // split by + - keeping signs
      final tokens = <String>[];
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        final c = s[i];
        if ((c == '+' || c == '-') && i > 0 && s[i - 1] != '*' && s[i - 1] != '/') {
          if (buf.isNotEmpty) tokens.add(buf.toString());
          buf.clear();
          tokens.add(c);
        } else {
          buf.write(c);
        }
      }
      if (buf.isNotEmpty) tokens.add(buf.toString());

      double parseTerm(String term) {
        // handle * and /
        final parts = <String>[];
        final b = StringBuffer();
        for (int i = 0; i < term.length; i++) {
          final c = term[i];
          if (c == '*' || c == '/') {
            parts.add(b.toString());
            parts.add(c);
            b.clear();
          } else {
            b.write(c);
          }
        }
        parts.add(b.toString());
        double v = double.parse(parts[0]);
        for (int i = 1; i < parts.length; i += 2) {
          final op = parts[i];
          final n = double.parse(parts[i + 1]);
          if (op == '*') {
            v *= n;
          } else {
            if (n == 0) throw Exception('div0');
            v /= n;
          }
        }
        return v;
      }

      double total = parseTerm(tokens[0]);
      for (int i = 1; i < tokens.length; i += 2) {
        final op = tokens[i];
        final v = parseTerm(tokens[i + 1]);
        if (op == '+') {
          total += v;
        } else {
          total -= v;
        }
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  void _onKey(String k) {
    setState(() {
      if (k == 'C') {
        _expr = '';
        _result = '0';
      } else if (k == '⌫') {
        if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1);
        if (_expr.isEmpty) _result = '0';
      } else if (k == '=') {
        final clean = _expr.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/');
        final pass = _passcode.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/');
        if (clean == pass) {
          StorageService.setUnlocked(true);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VaultHomeScreen()));
          return;
        }
        final v = _eval(_expr);
        if (v == null) {
          _result = 'Error';
        } else {
          if (v == v.roundToDouble()) {
            _result = v.toInt().toString();
          } else {
            _result = v.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
          }
          _expr = _result;
        }
      } else {
        if (_result != '0' && _expr == _result && (k == '+' || k == '-' || k == '×' || k == '÷')) {
          _expr = _result + k;
        } else if (_expr == _result && !(k == '+' || k == '-' || k == '×' || k == '÷')) {
          _expr = k;
        } else {
          _expr += k;
        }
      }
    });
  }

  void _calcAge() {
    final text = _birthCtrl.text.trim();
    DateTime? birth;
    if (RegExp(r'^\d{4}$').hasMatch(text)) {
      birth = DateTime(int.parse(text), 1, 1);
    } else if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$').hasMatch(text)) {
      final p = text.split('-');
      birth = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    }
    if (birth == null) {
      setState(() => _ageResult = 'সঠিক তারিখ দিন (YYYY বা YYYY-MM-DD)');
      return;
    }
    final now = DateTime.now();
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;
    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    setState(() => _ageResult = '$years বছর $months মাস $days দিন');
  }

  Widget _btn(String t, {Color? bg, Color? fg, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg ?? const Color(0xFF2A2A2A),
            foregroundColor: fg ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          onPressed: () => _onKey(t),
          child: Text(t, style: TextStyle(fontSize: t == '=' || t == 'C' ? 24 : 22, fontWeight: FontWeight.w500)),
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
        backgroundColor: const Color(0xFF121212),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF1E88E5),
          tabs: const [Tab(text: 'ক্যালকুলেটর'), Tab(text: 'বয়স')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ===== Calculator tab =====
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_expr.isNotEmpty && _expr != _result)
                          Text(_expr, style: TextStyle(color: Colors.grey[500], fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(_result, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w300), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(children: [_btn('C', bg: const Color(0xFFCF6679)), _btn('⌫'), _btn('÷'), _btn('×')]),
                        Row(children: [_btn('7'), _btn('8'), _btn('9'), _btn('-')]),
                        Row(children: [_btn('4'), _btn('5'), _btn('6'), _btn('+')]),
                        Row(children: [_btn('1'), _btn('2'), _btn('3'), _btn('=', bg: const Color(0xFF1E88E5))]),
                        Row(children: [_btn('0', flex: 2), _btn('.'), _btn('00')]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ===== Age tab =====
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('জন্ম তারিখ / বছর', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _birthCtrl,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: '1998  অথবা  1998-05-15',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _calcAge,
                  child: const Text('বয়স বের করুন', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 28),
                if (_ageResult.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                    child: Text(_ageResult, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
