import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_finance_lite/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user) =>
      user == null ? null : UserModel(uid: user.uid, email: user.email!);

  Stream<UserModel?> get user =>
      _auth.authStateChanges().map(_userFromFirebase);

  Future<UserModel?> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(cred.user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(cred.user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async => await _auth.signOut();
}