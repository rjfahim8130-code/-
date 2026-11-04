import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _passcodeKey = 'secret_passcode';
  static const String _isUnlockedKey = 'is_vault_unlocked';

  static Future<String> getPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passcodeKey) ?? '25*52';
  }

  static Future<void> setPasscode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passcodeKey, code.trim());
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
