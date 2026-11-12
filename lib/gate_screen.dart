import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ad_config.dart';
import 'gate_service.dart';
import 'vault_home_screen.dart';

class GateScreen extends StatefulWidget {
  const GateScreen({super.key});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> with WidgetsBindingObserver {
  bool _linkOpened = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ব্রাউজার থেকে ফিরলে
    if (state == AppLifecycleState.resumed && _linkOpened) {
      _finish();
    }
  }

  Future<void> _openLink() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final uri = Uri.parse(AdConfig.smartLink);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) {
        _linkOpened = true;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংক খোলা যায়নি')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish() async {
    if (!_linkOpened) return;
    await GateService.markOpened();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
    );
  }

  Future<void> _continueAfterReturn() async {
    if (!_linkOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে বাটনে চাপ দিয়ে লিংক খুলুন')),
      );
      return;
    }
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_open, size: 56, color: Color(0xFF1E88E5)),
              const SizedBox(height: 20),
              const Text(
                'প্রবেশের আগে একটি ধাপ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'নিচের বাটনে চাপ দিয়ে পেজটি খুলুন। ফিরে এসে "এগিয়ে যান" চাপুন।\n'
                'এরপর ${AdConfig.unlockDuration.inHours} ঘণ্টা অ্যাপ খোলা থাকবে।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], height: 1.4),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _busy ? null : _openLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _busy ? 'খুলছে...' : 'পেজ খুলুন',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _continueAfterReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('এগিয়ে যান'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
