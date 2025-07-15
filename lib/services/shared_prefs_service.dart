import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _currencyKey = 'currency';
  static const _notificationsKey = 'notifications';
  static const _themeKey = 'theme';

  static Future<String> getCurrency() async =>
      (await SharedPreferences.getInstance()).getString(_currencyKey) ?? '\$';

  static Future<void> setCurrency(String value) async =>
      (await SharedPreferences.getInstance()).setString(_currencyKey, value);

  static Future<bool> getNotificationsEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_notificationsKey) ?? true;

  static Future<void> setNotificationsEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_notificationsKey, value);

  static Future<String> getTheme() async =>
      (await SharedPreferences.getInstance()).getString(_themeKey) ?? 'system';

  static Future<void> setTheme(String value) async =>
      (await SharedPreferences.getInstance()).setString(_themeKey, value);
}