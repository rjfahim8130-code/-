import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Popunder কঠোর নিয়ম:
/// - ১৫ মিনিটে সর্বোচ্চ ১ বার
/// - "সফলভাবে দেখানোর পরেই" mark — ব্যর্থ attempt-এ cooldown নষ্ট হবে না
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

  // ───────────────────────── Read-only ─────────────────────────

  static Future<bool> canShow() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_keyLastShown) ?? 0;
    if (last == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - last) >= _cooldown.inMilliseconds;
  }

  // ───────────────────────── Commit ─────────────────────────

  /// সফলভাবে পপআন্ডার দেখানোর **পরে** কল করুন।
  /// সরাসরি কল করা এড়িয়ে `tryShow` ব্যবহার করুন।
  static Future<void> confirmShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastShown, DateTime.now().millisecondsSinceEpoch);
  }

  // ───────────────────────── All-in-one helper ─────────────────────────

  /// চেক + শো + সফল হলেই mark।
  /// [show] ফাংশনটি `true` ফেরালে "সফলভাবে দেখানো হয়েছে" ধরে নেওয়া হয়।
  /// (যেমন: WebView সফলভাবে load হয়েছে, অথবা popunder trigger কল হয়েছে।)
  static Future<bool> tryShow(Future<bool> Function() show) async {
    if (!await canShow()) return false;

    bool ok = false;
    try {
      ok = await show();
    } catch (_) {
      ok = false;
    }

    if (ok) await confirmShown();
    return ok;
  }

  // ───────────────────────── WebViewController ─────────────────────────

  static WebViewController createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString(_html, baseUrl: 'https://abscloud.org');
  }
}
