import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Adsterra Social Bar — রিডারে সবসময় টপ; অন্য স্ক্রিনে মাঝে মাঝে
class AdSocialBar extends StatefulWidget {
  final double height;
  const AdSocialBar({super.key, this.height = 56});

  @override
  State<AdSocialBar> createState() => _AdSocialBarState();
}

class _AdSocialBarState extends State<AdSocialBar> {
  late final WebViewController _controller;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>
  html, body { margin:0; padding:0; background:transparent; overflow:hidden; }
</style>
</head>
<body>
<script data-cfasync="false" src="https://bauval.org/14/ffa35eaae1c6ca002b8946fa89e65b71"></script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
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
