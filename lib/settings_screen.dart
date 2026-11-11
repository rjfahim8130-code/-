import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ctrl = TextEditingController();
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await StorageService.getPasscode();
    if (mounted) _ctrl.text = p;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = StorageService.normalizePasscode(_ctrl.text);
    if (v.isEmpty) {
      setState(() => _msg = 'পাসকোড খালি রাখা যাবে না');
      return;
    }
    await StorageService.setPasscode(v);
    if (!mounted) return;
    setState(() => _msg = 'সেভ হয়েছে');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('পাসকোড আপডেট হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('সেটিংস'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'সিক্রেট পাসকোড',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\n')),
              ],
              decoration: InputDecoration(
                hintText: 'যেমন: 25*52',
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ক্যালকুলেটরে এই এক্সপ্রেশন লিখে = চাপলে ভল্ট খুলবে।',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('সেভ'),
            ),
            if (_msg.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_msg, style: const TextStyle(color: Colors.greenAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
