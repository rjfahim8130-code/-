import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Adsterra Banner 320x50 — হোম/গল্প/ভিডিও স্ক্রিনের উপরে
class AdBanner extends StatefulWidget {
  final double height;
  const AdBanner({super.key, this.height = 50});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late final WebViewController _controller;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>
  html, body { margin:0; padding:0; background:#0D0D0D; overflow:hidden; text-align:center; }
</style>
</head>
<body>
<script>
  atOptions = {
    'key' : '55ab2946fa3e9e6f9f905b2a74726eda',
    'format' : 'iframe',
    'height' : 50,
    'width' : 320,
    'params' : {}
  };
</script>
<script src="https://bauval.org/22/55ab2946fa3e9e6f9f905b2a74726eda"></script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D0D))
      ..loadHtmlString(_html, baseUrl: 'https://bauval.org');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}
