import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/popunder_service.dart';

class AdPopunderHost extends StatefulWidget {
  const AdPopunderHost({super.key});

  static final GlobalKey<AdPopunderHostState> hostKey =
      GlobalKey<AdPopunderHostState>();

  static Future<void> trigger() async {
    await hostKey.currentState?.trigger();
  }

  @override
  State<AdPopunderHost> createState() => AdPopunderHostState();
}

class AdPopunderHostState extends State<AdPopunderHost> {
  WebViewController? _controller;
  bool _show = false;

  Future<void> trigger() async {
    final ok = await PopunderService.tryAcquire();
    if (!ok || !mounted) return;

    final c = PopunderService.createController();
    setState(() {
      _controller = c;
      _show = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _show = false;
          _controller = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_show || _controller == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 1,
      height: 1,
      child: WebViewWidget(controller: _controller!),
    );
  }
}
