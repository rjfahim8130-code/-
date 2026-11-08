import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 320x50 — Video Player টপ
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
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
    margin: 0;
    padding: 0;
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
    'key' : '55ab2946fa3e9e6f9f905b2a74726eda',
    'format' : 'iframe',
    'height' : 50,
    'width' : 320,
    'params' : {}
  };
</script>
<script type="text/javascript" src="https://bauval.org/22/55ab2946fa3e9e6f9f905b2a74726eda"></script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D0D))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            // মূল পেজ লোড ব্যর্থ হলে তবেই error দেখাবে
            if (error.isForMainFrame ?? false) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
          },
        ),
      )
      // baseUrl অবশ্যই দিতে হবে — Adsterra/Referer যাচাইয়ের জন্য জরুরি
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
      height: 50,
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      child: _hasError
          ? _ErrorView(onRetry: _reload)
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 14, color: Colors.white54),
            SizedBox(width: 4),
            Text(
              'রিলোড করুন',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
