import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _passcodeKey = 'secret_passcode';
  static const String _isUnlockedKey = 'is_vault_unlocked';

  /// পাসকোড normalize: সব স্পেস বাদ, ×/÷ কে */ এ রূপান্তর।
  /// এতে CalculatorScreen-এর তুলনা সবসময় নির্ভুল হবে।
  static String normalizePasscode(String code) {
    return code
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
  }

  static Future<String> getPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passcodeKey) ?? '25*52';
  }

  static Future<void> setPasscode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passcodeKey, normalizePasscode(code));
  }

  static Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isUnlockedKey) ?? false;
  }

  static Future<void> setUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isUnlockedKey, value);
  }

  static Future<void> lockVault() async {
    await setUnlocked(false);
  }
}
