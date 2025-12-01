// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch current user info
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return {};

    return doc.data()!;
  }

  /// Logout user
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Update user info
  Future<void> updateUserInfo({
    required String fullName,
    required String contact,
    required String city,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName,
      'contact': contact,
      'city': city,
    });
  }
}
