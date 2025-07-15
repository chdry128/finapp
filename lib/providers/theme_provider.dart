import 'package:flutter/material.dart';
import 'package:personal_finance_lite/services/shared_prefs_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final val = await SharedPrefsService.getTheme();
    if (val == 'light') {
      _themeMode = ThemeMode.light;
    } else if (val == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    await SharedPrefsService.setTheme(dark ? 'dark' : 'light');
    notifyListeners();
  }
}