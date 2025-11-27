// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ledgu/services/auth_services.dart';
import 'package:ledgu/view/screens/main_screen.dart'; // Make sure this path is correct

class LoginController {
  final AuthServices _authServices = AuthServices();

  // Controllers for TextFields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  // For showing loading state
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // =========================
  // LOGIN FUNCTION
  // =========================
  Future<void> loginUser(BuildContext context) async {
    String email = emailController.text.trim();
    String pin = pinController.text.trim(); // Assuming your PIN is password here

    if (email.isEmpty || pin.isEmpty) {
      _showSnackBar(context, 'Please enter both Email and PIN');
      return;
    }

    isLoading.value = true;

    try {
      final user = await _authServices.loginUser(email: email, password: pin);

      if (user != null) {
        _showSnackBar(context, 'Login Successful!');
        // Navigate to next screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        _showSnackBar(context, 'User not found or wrong PIN!');
      }
    } catch (e) {
      _showSnackBar(context, 'Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    emailController.dispose();
    pinController.dispose();
    isLoading.dispose();
  }

  // =========================
  // SHOW SNACKBAR
  // =========================
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
