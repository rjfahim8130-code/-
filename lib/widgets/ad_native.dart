import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdNative extends StatefulWidget {
  final double height;
  const AdNative({super.key, this.height = 130});

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  late final WebViewController _controller;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>html,body{margin:0;padding:4px;background:#1A1A1A;overflow:hidden;}</style>
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A1A1A))
      ..loadHtmlString(_html, baseUrl: 'https://bauval.org');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: WebViewWidget(controller: _controller),
    );
  }
}
