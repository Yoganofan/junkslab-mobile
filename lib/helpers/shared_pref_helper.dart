import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String keyIsLoggedIn = "is_logged_in";
  static const String keyUserRole = "user_role"; 
  static const String keyUserName = "user_name";
  static const String keyThemeMode = "theme_mode"; 

  // 1. Status Login
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, isLoggedIn);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // 2. Role User (Penyedia / Penyerap)
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserRole, role);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserRole);
  }

  // 3. Nama User (Tampil di Profil)
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserName, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName);
  }

  // 4. Tema Aplikasi
  static Future<void> setThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyThemeMode, isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyThemeMode) ?? false; 
  }

  // 5. Saldo JunksPoint
  static const String keyJunksPoint = "junks_point";
  
  static Future<void> setJunksPoint(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyJunksPoint, points);
  }

  static Future<int> getJunksPoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyJunksPoint) ?? 12000;
  }
}