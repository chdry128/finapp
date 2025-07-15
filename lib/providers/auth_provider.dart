import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/user.dart';
import 'package:personal_finance_lite/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _auth = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  AuthProvider() {
    _auth.user.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<void> register(String email, String password) async {
    await _auth.register(email, password);
  }

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
  }

  Future<void> logout() async {
    await _auth.logout();
  }
}