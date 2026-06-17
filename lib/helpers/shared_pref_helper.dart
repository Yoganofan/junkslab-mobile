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

  // 6. Statistik Dampak — persisted across transactions
  static const String keyLimbahTerserap = "limbah_terserap";
  static const String keyTotalTransaksi = "total_transaksi";
  static const String keyCo2Dicegah = "co2_dicegah"; // stored as int (x100 for 2 decimal precision)

  static Future<int> getLimbahTerserap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLimbahTerserap) ?? 300;
  }

  static Future<void> setLimbahTerserap(int kg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLimbahTerserap, kg);
  }

  static Future<int> getTotalTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalTransaksi) ?? 12;
  }

  static Future<void> setTotalTransaksi(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTotalTransaksi, count);
  }

  /// CO2 is stored as integer cents (e.g. 105 = 1.05 ton)
  static Future<int> getCo2DicegahCents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCo2Dicegah) ?? 100; // default 1.00 ton = 100 cents
  }

  static Future<void> setCo2DicegahCents(int cents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCo2Dicegah, cents);
  }

  /// Convenience: add impact after a completed pickup
  static Future<void> addCompletedPickup(int beratKg) async {
    // 1) Limbah terserap += berat
    int currentLimbah = await getLimbahTerserap();
    await setLimbahTerserap(currentLimbah + beratKg);

    // 2) Total transaksi += 1
    int currentTransaksi = await getTotalTransaksi();
    await setTotalTransaksi(currentTransaksi + 1);

    // 3) CO2 dicegah += berat * 0.44 (cents)
    // e.g. 45 kg * 0.44 = 19.8 cents ≈ 0.198 ton
    int currentCo2 = await getCo2DicegahCents();
    int addedCo2 = (beratKg * 0.44).round();
    await setCo2DicegahCents(currentCo2 + addedCo2);
  }
}