import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Adsterra Banner 300x250 — প্লেয়ার ছাড়া সব স্ক্রিনের টপ (sticky)
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

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
    'key' : 'fc1454c2d1336f9034aa01b47d93abf3',
    'format' : 'iframe',
    'height' : 250,
    'width' : 300,
    'params' : {}
  };
</script>
<script src="https://bauval.org/22/fc1454c2d1336f9034aa01b47d93abf3"></script>
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
      height: 250,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}
