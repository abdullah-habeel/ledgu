// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ledgu/services/auth_services.dart';

import '../../view/auth/get_started.dart';

class ProfileController {
  final AuthServices _authServices = AuthServices();

  Future<void> logout(BuildContext context) async {
    try {
      await _authServices.logout();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );

      // After logout, navigate to login screen
      // Replace with your login screen route
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GetStarted()),
        (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }
}
