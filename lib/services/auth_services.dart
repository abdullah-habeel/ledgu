import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // REGISTER / CREATE USER
  // =========================
  Future<User?> registerUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unknown Registration Error: $e');
      return null;
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<User?> loginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unknown Login Error: $e');
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Reset Password Error: ${e.message}');
    } catch (e) {
      debugPrint('Unknown Reset Password Error: $e');
    }
  }

  // =========================
  // GET CURRENT USER
  // =========================
  User? get currentUser => _auth.currentUser;
  
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}
