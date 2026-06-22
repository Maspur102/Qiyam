import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyXp = 'current_xp';
  static const String _keySystemActive = 'is_system_active';
  static const String _keySleepTime = 'sleep_time';
  static const String _keyPrayerBlockDuration = 'prayer_block_duration';

  static Future<void> saveXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXp, xp);
  }

  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyXp) ?? 0;
  }

  static Future<void> setSystemStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySystemActive, isActive);
  }

  static Future<bool> isSystemActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySystemActive) ?? true;
  }

  static Future<void> saveSleepTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySleepTime, time);
  }

  static Future<String> getSleepTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySleepTime) ?? '22:00';
  }

  static Future<void> saveBlockDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrayerBlockDuration, minutes);
  }

  static Future<int> getBlockDuration() async {
    final prefs = await SharedPreferences.getInstance();
    // Diperbaiki: Menggunakan getInt, bukan setInt
    return prefs.getInt(_keyPrayerBlockDuration) ?? 5; 
  }
}
