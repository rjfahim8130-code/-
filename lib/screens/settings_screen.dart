import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  String _currentPasscode = '';
  bool _obscure = true;
  bool _saving = false;

  static final _allowedRegex = RegExp(r'^[0-9+\-*/×÷.]+$');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final code = await StorageService.getPasscode();
    if (!mounted) return;
    setState(() {
      _currentPasscode = code;
      _controller.text = code;
    });
  }

  String? _validate(String raw) {
    final code = raw.replaceAll(' ', '');
    if (code.isEmpty) return 'পাসকোড খালি রাখা যাবে না';
    if (code.length < 4) return 'কমপক্ষে ৪ অক্ষর দিন';
    if (!_allowedRegex.hasMatch(code)) {
      return 'শুধু 0-9, + - × ÷ * / . ব্যবহার করুন';
    }
    if (!RegExp(r'[+\-*/×÷]').hasMatch(code)) {
      return 'অন্তত একটি অপারেটর (+ - × ÷) দিন, যেমন: 25*52';
    }
    return null;
  }

  Future<void> _save() async {
    final raw = _controller.text;
    final error = _validate(raw);
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final newCode = raw.replaceAll(' ', '');

    if (newCode == _currentPasscode) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এটাই বর্তমান পাসকোড')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await StorageService.setPasscode(newCode);
      if (!mounted) return;
      setState(() {
        _currentPasscode = newCode;
        _controller.text = newCode;
        _saving = false;
        _obscure = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পাসকোড সফলভাবে সেভ হয়েছে')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('সেভ করতে সমস্যা: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('সেটিংস'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'সিক্রেট পাসকোড',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'ক্যালকুলেটরে এই এক্সপ্রেশন লিখে = চাপলেই ভল্ট আনলক হবে。\n'
            'উদাহরণ: 25*52  অথবা  100+50  অথবা  12×34',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9+\-*/×÷. ]'),
              ),
            ],
            style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: '25*52',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'পাসকোড সেভ করুন',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'বর্তমান পাসকোড',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  _obscure ? '•' * 8 : _currentPasscode,
                  style: const TextStyle(fontSize: 18, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
