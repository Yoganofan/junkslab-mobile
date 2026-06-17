import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userAddressKey = 'user_address';
  static const String _selectedPickupLocationIdKey = 'selected_pickup_location_id';
  static const String _lastLoginKey = 'last_login';

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Sesi Log In/Out Utama (Tetap Statis)
  Future<bool> setUserId(String userId) async {
    return await _preferences.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _preferences.getString(_userIdKey);
  }

  Future<bool> setUserEmail(String email) async {
    return await _preferences.setString(_userEmailKey, email);
  }

  String? getUserEmail() {
    return _preferences.getString(_userEmailKey);
  }

  Future<bool> setUserName(String name) async {
    final String email = getUserEmail() ?? 'guest';
    return await _preferences.setString('${_userNameKey}_$email', name);
  }

  String? getUserName() {
    final String email = getUserEmail() ?? 'guest';
    return _preferences.getString('${_userNameKey}_$email');
  }

  Future<bool> setUserPhone(String phone) async {
    final String email = getUserEmail() ?? 'guest';
    return await _preferences.setString('${_userPhoneKey}_$email', phone);
  }

  String? getUserPhone() {
    final String email = getUserEmail() ?? 'guest';
    return _preferences.getString('${_userPhoneKey}_$email');
  }

  Future<bool> setSelectedPickupLocationId(int locationId) async {
    final String email = getUserEmail() ?? 'guest';
    return await _preferences.setInt('${_selectedPickupLocationIdKey}_$email', locationId);
  }

  int? getSelectedPickupLocationId() {
    final String email = getUserEmail() ?? 'guest';
    return _preferences.getInt('${_selectedPickupLocationIdKey}_$email');
  }

  Future<bool> setUserAddress(String address) async {
    final String email = getUserEmail() ?? 'guest';
    return await _preferences.setString('${_userAddressKey}_$email', address);
  }

  String? getUserAddress() {
    final String email = getUserEmail() ?? 'guest';
    return _preferences.getString('${_userAddressKey}_$email');
  }

  // Last Login
  Future<bool> setLastLogin(DateTime dateTime) async {
    return await _preferences.setString(_lastLoginKey, dateTime.toIso8601String());
  }

  DateTime? getLastLogin() {
    final String? dateString = _preferences.getString(_lastLoginKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Clear
  Future<bool> clearAllPreferences() async {
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userEmailKey);
    await _preferences.remove(_lastLoginKey);
    return true;
  }

  bool isUserLoggedIn() {
    return getUserId() != null && getUserEmail() != null;
  }
}