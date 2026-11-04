import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final code = await StorageService.getPasscode();
    setState(() {
      _currentPasscode = code;
      _controller.text = code;
    });
  }

  Future<void> _save() async {
    final newCode = _controller.text.trim();
    if (newCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পাসকোড খালি রাখা যাবে না')),
      );
      return;
    }
    setState(() => _saving = true);
    await StorageService.setPasscode(newCode);
    setState(() {
      _currentPasscode = newCode;
      _saving = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পাসকোড সফলভাবে সেভ হয়েছে')),
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
            'ক্যালকুলেটরে এই এক্সপ্রেশন লিখে = চাপলেই ভল্ট আনলক হবে।\nউদাহরণ: 25*52 অথবা 100+50',
            style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('পাসকোড সেভ করুন', style: TextStyle(fontSize: 16)),
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
                Text('বর্তমান পাসকোড', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  _obscure ? '•' * _currentPasscode.length : _currentPasscode,
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
