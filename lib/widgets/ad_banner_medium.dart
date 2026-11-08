import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 300x250 — লিস্টে Native-এর পাশাপাশি
class AdBannerMedium extends StatefulWidget {
  const AdBannerMedium({super.key});

  @override
  State<AdBannerMedium> createState() => _AdBannerMediumState();
}

class _AdBannerMediumState extends State<AdBannerMedium> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  static const String _htmlContent = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body {
    margin: 0; padding: 0;
    background: #0D0D0D;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
  }
</style>
</head>
<body>
<script type="text/javascript">
  atOptions = {
    'key' : 'fc1454c2d1336f9034aa01b47d93abf3',
    'format' : 'iframe',
    'height' : 250,
    'width' : 300,
    'params' : {}
  };
</script>
<script type="text/javascript" src="https://bauval.org/22/fc1454c2d1336f9034aa01b47d93abf3"></script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D0D))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_htmlContent, baseUrl: 'https://bauval.org');
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadHtmlString(_htmlContent, baseUrl: 'https://bauval.org');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      alignment: Alignment.center,
      color: const Color(0xFF0D0D0D),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ⬇️ WebView সবসময় ট্রি-তে থাকবে (error হলেও)
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          // ⬇️ লোডিং স্পিনার
          if (_isLoading && !_hasError)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // ⬇️ এরর overlay (WebView সরায় না)
          if (_hasError)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF0D0D0D),
                child: _ErrorView(onRetry: _reload),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      behavior: HitTestBehavior.opaque,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 20, color: Colors.white54),
            SizedBox(height: 6),
            Text(
              'বিজ্ঞাপন লোড হয়নি, রিলোড করুন',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
