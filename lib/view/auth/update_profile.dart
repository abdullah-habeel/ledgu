import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/textformfield.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Fetch current user info from Firebase
  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          nameController.text = data['fullName'] ?? '';
          contactController.text = data['contact'] ?? '';
          cityController.text = data['city'] ?? '';
          setState(() {});
        }
      });
    }
  }

  // Update user info in Firestore
  Future<void> _updateProfile() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged-in user found.')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'contact': contactController.text.trim(),
        'city': cityController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    contactController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: const Text('Update Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (read-only)
              MyTextFormField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Your email',
                readOnly: true,
              ),
              GapBox(10),

              // Full Name
              MyTextFormField(
                controller: nameController,
                labelText: 'Full Name',
                hintText: 'Enter your name',
              ),
              GapBox(10),

              // Contact
              MyTextFormField(
                controller: contactController,
                labelText: 'Contact',
                hintText: 'Enter contact number',
                keyboardType: TextInputType.phone,
              ),
              GapBox(10),

              // City
              MyTextFormField(
                controller: cityController,
                labelText: 'City',
                hintText: 'Enter your city',
              ),
              GapBox(20),

              // Update button
              MyButton(
                text: isLoading ? 'Updating...' : 'Update',
                fixedWidth: double.infinity,
                backgroundColor: AppColors.blue2,
                onPressed: isLoading ? null : _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
