import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Native 3:1
class AdNative extends StatefulWidget {
  final double height;
  const AdNative({super.key, this.height = 130});

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _renderTimeout;
  Timer? _pollTimer;

  static const String _htmlContent = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body {
    margin: 0;
    padding: 4px;
    background: #1A1A1A;
    overflow: hidden;
    height: 100%;
    box-sizing: border-box;
  }
  #container-9f56f8fbc6f096ee39e1d7fb1a86e4f0 {
    width: 100%;
    min-height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
</head>
<body>
<script async="async" data-cfasync="false"
  src="https://bauval.org/21/9f56f8fbc6f096ee39e1d7fb1a86e4f0"></script>
<div id="container-9f56f8fbc6f096ee39e1d7fb1a86e4f0"></div>
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
      ..setBackgroundColor(const Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            _startRenderWatch();
          },
          onPageFinished: (_) async {
            // page finished মানেই ad render হয়নি — DOM তৈরি হয়েছে কিনা poll করি
            _startPollingForAdDom();
          },
          onWebResourceError: (error) {
            // main-frame error ছাড়াও ad script ব্লক হলে (ERR_BLOCKED_BY_CLIENT)
            // সেটাকে error হিসেবে ধরি
            final isMain = error.isForMainFrame ?? false;
            final isBlocked = error.errorType == WebResourceErrorType.blockedByClient;
            if (isMain || isBlocked) {
              if (!mounted) return;
              _cancelTimers();
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

  /// ad DOM তৈরি হয়েছে কিনা ৩ সেকেন্ড পর্যন্ত poll করা
  void _startPollingForAdDom() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) async {
      try {
        final result = await _controller.runJavaScriptReturningResult(
          "(function(){var c=document.getElementById('container-9f56f8fbc6f096ee39e1d7fb1a86e4f0');"
          "return (c && c.children.length > 0) ? '1' : '0';})()",
        );
        final rendered = result.toString().replaceAll('"', '') == '1';
        if (rendered) {
          timer.cancel();
          _renderTimeout?.cancel();
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (_) {
        // JS ত্রুটি উপেক্ষা
      }
    });
  }

  /// ৬ সেকেন্ডেও DOM তৈরি না হলে → error দেখাও
  void _startRenderWatch() {
    _renderTimeout?.cancel();
    _renderTimeout = Timer(const Duration(seconds: 6), () {
      _pollTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    });
  }

  void _cancelTimers() {
    _pollTimer?.cancel();
    _renderTimeout?.cancel();
  }

  void _reload() {
    _cancelTimers();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadHtmlString(_htmlContent, baseUrl: 'https://bauval.org');
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
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
      child: Stack(
        children: [
          // WebView সবসময় ট্রি-তে
          Positioned.fill(child: WebViewWidget(controller: _controller)),

          // লোডিং স্পিনার (ad DOM তৈরি হওয়ার আগ পর্যন্ত)
          if (_isLoading && !_hasError)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white54,
                ),
              ),
            ),

          // এরর overlay
          if (_hasError)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF1A1A1A),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 16, color: Colors.white54),
            SizedBox(width: 6),
            Text('রিলোড করুন',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
