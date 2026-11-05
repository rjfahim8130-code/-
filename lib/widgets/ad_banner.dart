import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>
  html,body{margin:0;padding:0;background:#0D0D0D;overflow:hidden;}
  iframe{border:0;display:block;margin:0 auto;}
</style>
</head>
<body>
<iframe
  src="https://a.magsrv.com/iframe.php?idzone=6080294&size=300x50"
  width="300" height="50"
  scrolling="no" marginwidth="0" marginheight="0" frameborder="0">
</iframe>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D0D))
      ..loadHtmlString(_html, baseUrl: 'https://a.magsrv.com');
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
