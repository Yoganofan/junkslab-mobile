import 'package:flutter/material.dart';
import '../../helpers/shared_pref_helper.dart';

class AdminProvider extends ChangeNotifier {
  bool isDarkMode = false;

  AdminProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    isDarkMode = await SharedPrefHelper.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    isDarkMode = isDark;
    await SharedPrefHelper.setThemeMode(isDark);
    notifyListeners();
  }

  void refreshDashboard() {
    // Kosong dulu untuk keperluan testing
  }
}