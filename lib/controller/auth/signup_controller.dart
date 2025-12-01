// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/services/auth_services.dart';

class SignupController {
  final AuthServices _authService = AuthServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  /// Register user and save details in Firestore
  Future<User?> registerUser(BuildContext context) async {
    final email = emailController.text.trim().toLowerCase(); // lowercase
    final password = pinController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    try {
      // Create Firebase Auth User
      final user = await _authService.registerUser(email: email, password: password);
      if (user != null) {
        // Save extra info to Firestore including empty friends array
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': nameController.text.trim(),
          'contact': contactController.text.trim(),
          'city': cityController.text.trim(),
          'email': email, // store lowercase
          'friends': [], // <-- essential for friend feature
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error registering user: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void clearFields() {
    nameController.clear();
    contactController.clear();
    cityController.clear();
    emailController.clear();
    pinController.clear();
  }
}
