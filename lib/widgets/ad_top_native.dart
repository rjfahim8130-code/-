import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// টপ Native 3:1 — প্রতি 60s অটো-রিফ্রেশ, মেমরি-সেফ
class AdTopNative extends StatefulWidget {
  final double height;
  const AdTopNative({super.key, this.height = 120});

  @override
  State<AdTopNative> createState() => _AdTopNativeState();
}

class _AdTopNativeState extends State<AdTopNative>
    with WidgetsBindingObserver {
  WebViewController? _controller;

  bool _isLoading = true;
  bool _hasError = false;

  Timer? _renderTimeout;
  Timer? _pollTimer;
  Timer? _refreshTimer;

  /// WebViewWidget রিমাউন্ট করার জন্য; বাড়লেই নতুন key
  int _tick = 0;

  static const String _htmlContent = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body {
    margin: 0; padding: 4px;
    background: #0D0D0D;
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
    WidgetsBinding.instance.addObserver(this);
    _createAndLoad();

    // প্রতি ৬০s অটো রিফ্রেশ
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) _reload();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // অ্যাপ ব্যাকগ্রাউন্ডে গেলে রিফ্রেশ বন্ধ (ব্যাটারি সেভ)
    if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) _reload();
      });
    }
  }

  // ───────────────────────── Controller lifecycle ─────────────────────────

  void _createAndLoad() {
    final controller = WebViewController()
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
            _startRenderWatch();
          },
          onPageFinished: (_) => _startPollingForAdDom(),
          onWebResourceError: (error) {
            final isMain = error.isForMainFrame ?? false;
            final isBlocked =
                error.errorType == WebResourceErrorType.blockedByClient;
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

    setState(() {
      _controller = controller;
      _tick++;              // WebViewWidget নতুন key পাবে → রিমাউন্ট
      _isLoading = true;
      _hasError = false;
    });
  }

  void _releaseController() {
    // পুরোনো WebView-এর JS/DOM cleanup
    final old = _controller;
    _controller = null;
    if (old != null) {
      // best-effort: load করা JS থামাও
      old.loadRequest(Uri.parse('about:blank')).catchError((_) {});
      // webview_flutter 4.x-এ সরাসরি dispose API নেই;
      // _controller = null + WebViewWidget unmount → প্ল্যাটফর্ম ভিউ release হয়
    }
  }

  // ───────────────────────── Reload / Poll / Timeout ─────────────────────────

  void _reload() {
    _cancelTimers();
    _releaseController();   // ⬅️ পুরোনো controller ছেড়ে দাও
    _createAndLoad();       // ⬅️ নতুন controller
  }

  void _startPollingForAdDom() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(milliseconds: 400), (timer) async {
      final controller = _controller;
      if (controller == null) {
        timer.cancel();
        return;
      }
      try {
        final result = await controller.runJavaScriptReturningResult(
          "(function(){var c=document.getElementById('container-9f56f8fbc6f096ee39e1d7fb1a86e4f0');"
          "return (c && c.children.length > 0) ? '1' : '0';})()",
        );
        final rendered = result.toString().replaceAll('"', '') == '1';
        if (rendered) {
          timer.cancel();
          _renderTimeout?.cancel();
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (_) {}
    });
  }

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    _refreshTimer?.cancel();
    _releaseController();
    super.dispose();
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Container(
      height: widget.height,
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      child: controller == null
          ? const Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white54,
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: WebViewWidget(
                    key: ValueKey(_tick),   // ⬅️ রিফ্রেশে নতুন key → নতুন প্লাটফর্ম ভিউ
                    controller: controller,
                  ),
                ),
                if (_isLoading && !_hasError)
                  const Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                  ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 14, color: Colors.white54),
            SizedBox(width: 4),
            Text('রিলোড করুন',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
