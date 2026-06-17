import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const String keyIsLoggedIn = 'is_admin_logged_in';
  static const String keyThemeMode = 'admin_theme_mode';
  static const String keySortPreference = 'catalog_sort_order';
  static const String keyQueueFilter = 'queue_filter_status';
  static const String keyLastSync = 'last_sync_time'; 

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, theme);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyThemeMode) ?? 'light';
  }

  static Future<void> setSortOrder(String order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySortPreference, order);
  }

  static Future<String> getSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keySortPreference) ?? 'Poin Terendah';
  }

  static Future<void> setQueueFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyQueueFilter, filter);
  }

  static Future<String> getQueueFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyQueueFilter) ?? 'Semua';
  }

  // --- FUNGSI LAST SYNC ---
  static Future<void> setLastSync(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastSync, time);
  }

  static Future<String> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastSync) ?? '';
  }
}
