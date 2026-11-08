import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdTopNative extends StatefulWidget {
  final double height;
  const AdTopNative({super.key, this.height = 120});

  @override
  State<AdTopNative> createState() => _AdTopNativeState();
}

class _AdTopNativeState extends State<AdTopNative> {
  WebViewController? _controller;
  Timer? _timer;
  int _tick = 0;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>html,body{margin:0;padding:0;background:#0D0D0D;overflow:hidden;}</style>
</head>
<body>
<script async="async" data-cfasync="false" src="https://bauval.org/21/9f56f8fbc6f096ee39e1d7fb1a86e4f0"></script>
<div id="container-9f56f8fbc6f096ee39e1d7fb1a86e4f0"></div>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _reload();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) _reload();
    });
  }

  void _reload() {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D0D))
      ..loadHtmlString(_html, baseUrl: 'https://bauval.org');
    
    if (!mounted) return;
    setState(() {
      _controller = c;
      _tick++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return SizedBox(height: widget.height);
    }
    return SizedBox(
      key: ValueKey(_tick),
      height: widget.height,
      width: double.infinity,
      child: WebViewWidget(controller: _controller!),
    );
  }
}
