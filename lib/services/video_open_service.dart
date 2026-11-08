import 'package:shared_preferences/shared_preferences.dart';

/// প্রতি ৪ ঘণ্টার উইন্ডোতে প্রথম ২টি ভিডিও → external browser
/// বাকি → in-app player
///
/// নকশা: read-only check → open attempt → success হলেই commit
/// ফলে ব্যর্থ open-এ quota নষ্ট হয় না, আর "mark ভুলে যাওয়া" বন্ধ হয়।
class VideoOpenService {
  static const _keyWindowStart = 'video_ext_window_start_ms';
  static const _keyCount = 'video_ext_count';

  static const Duration window = Duration(hours: 4);
  static const int maxExternal = 2;

  // ───────────────────────── In-process mutex ─────────────────────────
  // একই isolate-এর ভেতরে concurrent call (double-tap / list rebuild)
  // থেকে quota leak ঠেকায়। SharedPreferences cross-process atomic নয়,
  // তাই background isolate থেকে কল করলে আলাদা ডিজাইন দরকার।

  static Future<void>? _lock;

  static Future<T> _synchronized<T>(Future<T> Function() action) async {
    while (_lock != null) {
      await _lock;
    }
    final completer = Future<void>.value();
    _lock = completer;
    try {
      return await action();
    } finally {
      _lock = null;
    }
  }

  // ───────────────────────── Window reset ─────────────────────────

  static Future<void> _ensureWindow(SharedPreferences prefs) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final start = prefs.getInt(_keyWindowStart) ?? 0;
    if (start == 0 || (now - start) >= window.inMilliseconds) {
      await prefs.setInt(_keyWindowStart, now);
      await prefs.setInt(_keyCount, 0);
    }
  }

  // ───────────────────────── Public API ─────────────────────────

  /// শুধু চেক — কোনো write নেই।
  /// কাস্টম confirm dialog বা নিচু স্তরের কন্ট্রোলের জন্য।
  static Future<bool> canOpenExternal() {
    return _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      await _ensureWindow(prefs);
      return (prefs.getInt(_keyCount) ?? 0) < maxExternal;
    });
  }

  /// ব্রাউজার সফলভাবে খোলার পরেই কল করুন।
  /// `tryOpenExternal` ব্যবহার করলে এটি ম্যানুয়ালি ডাকার দরকার নেই।
  static Future<void> confirmExternalOpened() {
    return _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      await _ensureWindow(prefs);
      final count = (prefs.getInt(_keyCount) ?? 0) + 1;
      await prefs.setInt(_keyCount, count);
    });
  }

  /// সব-in-one: চেক + খোলা + সফল হলে কাউন্ট।
  ///
  /// [openExternal] একটি async ফাংশন; ব্রাউজার সফলভাবে খুললে `true` দেবে
  /// (যেমন: `launchUrl(uri, mode: LaunchMode.externalApplication)`)।
  ///
  /// রিটার্ন: `true` = external খোলা হয়েছে ও quota থেকে কাটা হয়েছে,
  ///          `false` = লিমিট শেষ / খোলা ব্যর্থ → in-app প্লেয়ারে যেতে হবে।
  static Future<bool> tryOpenExternal(
    Future<bool> Function() openExternal,
  ) async {
    // ১. read-only চেক (রেস-মুক্ত, quota খরচ করে না)
    final allowed = await canOpenExternal();
    if (!allowed) return false;

    // ২. আসলে খোলার চেষ্টা — ব্যর্থ হলে quota কাটবে না
    bool success = false;
    try {
      success = await openExternal();
    } catch (_) {
      success = false;
    }

    // ৩. শুধু সফল হলে কাউন্ট
    if (success) {
      await confirmExternalOpened();
    }
    return success;
  }

  // ───────────────────────── Debug / admin ─────────────────────────

  /// ডিবাগ বা অ্যাডমিন প্যানেলের জন্য — quota ও উইন্ডো রিসেট করে।
  static Future<void> reset() async {
    await _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyWindowStart);
      await prefs.remove(_keyCount);
    });
  }

  /// বর্তমান অবস্থা পড়া (ডিবাগ/UI দেখানোর জন্য)।
  static Future<({int used, int remaining, DateTime? windowStart})>
      debugState() async {
    return _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      final startMs = prefs.getInt(_keyWindowStart) ?? 0;
      final count = prefs.getInt(_keyCount) ?? 0;
      final remaining = (maxExternal - count).clamp(0, maxExternal);
      return (
        used: count,
        remaining: remaining,
        windowStart: startMs == 0
            ? null
            : DateTime.fromMillisecondsSinceEpoch(startMs),
      );
    });
  }
}
