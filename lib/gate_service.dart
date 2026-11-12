import 'package:shared_preferences/shared_preferences.dart';
import 'ad_config.dart';

class GateService {
  static const _keyUntil = 'gate_unlocked_until_ms';
  static const _keyDay = 'gate_day';
  static const _keyCount = 'gate_count_today';

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static Future<void> _rollDay(SharedPreferences p) async {
    final t = _today();
    if (p.getString(_keyDay) != t) {
      await p.setString(_keyDay, t);
      await p.setInt(_keyCount, 0);
    }
  }

  /// ৮ ঘণ্টার উইন্ডো এখনও চালু আছে কি না
  static Future<bool> isUnlocked() async {
    final p = await SharedPreferences.getInstance();
    final until = p.getInt(_keyUntil) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  static Future<int> opensToday() async {
    final p = await SharedPreferences.getInstance();
    await _rollDay(p);
    return p.getInt(_keyCount) ?? 0;
  }

  /// আজ আর গেট দেখানো যাবে কি না (৩বারের কম)
  static Future<bool> canOpenGate() async {
    final c = await opensToday();
    return c < AdConfig.maxGateOpensPerDay;
  }

  /// লিংক ওপেন সফল মার্ক → ৮ ঘণ্টা আনলক
  static Future<void> markOpened() async {
    final p = await SharedPreferences.getInstance();
    await _rollDay(p);
    final c = (p.getInt(_keyCount) ?? 0) + 1;
    await p.setInt(_keyCount, c);
    final until =
        DateTime.now().add(AdConfig.unlockDuration).millisecondsSinceEpoch;
    await p.setInt(_keyUntil, until);
  }

  /// দিনে ৩বার শেষ — আজ আর গেট না দেখিয়ে ঢুকতে দিলে true রাখুন
  static Future<bool> allowBypassWhenQuotaFull() async {
    if (await isUnlocked()) return true;
    if (await canOpenGate()) return false;
    // কোটা শেষ → আজ বাকি সময় ভল্টে ঢুকতে দেওয়া
    return true;
  }
}
