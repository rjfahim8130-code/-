import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PopunderService {
  static const String _keyLastShown = 'popunder_last_shown_ms';
  static const Duration _cooldown = Duration(minutes: 15);

  static const String _html = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<script data-cfasync="false" src="https://abscloud.org/1/116b66fa602efda9e7d6b42982192a19"></script>
</body>
</html>
''';

  static Future<bool> canShow() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_keyLastShown) ?? 0;
    if (last == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - last) >= _cooldown.inMilliseconds;
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastShown, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> tryAcquire() async {
    if (!await canShow()) return false;
    await markShown();
    return true;
  }

  static WebViewController createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString(_html, baseUrl: 'https://abscloud.org');
  }
}
