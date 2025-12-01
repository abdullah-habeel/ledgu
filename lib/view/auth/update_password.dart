// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/textformfield.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool isLoading = false;

  // ⭐ FULL UPDATE PASSWORD LOGIC ⭐
  Future<void> updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final oldPass = oldPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔵 1. GET OLD PIN SAVED IN FIRESTORE
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final savedPin = snap['pin']; // PIN the user created

      // 🔴 If old PIN does not match user's actual old PIN
      if (oldPass != savedPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Old password is incorrect")),
        );
        setState(() => isLoading = false);
        return;
      }

      // 🔵 2. REAUTHENTICATE USING OLD PIN
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: savedPin,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔵 3. UPDATE FIREBASE PASSWORD
      await user.updatePassword(newPass);

      // 🔵 4. UPDATE PIN IN FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"pin": newPass});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: const MyText(
            text: 'Update Password',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GapBox(30),

              MyTextFormField(
                controller: oldPassController,
                hintText: '******',
                labelText: 'Enter Your Old Password',
                obscureText: true,
              ),
              GapBox(10),

              MyTextFormField(
                controller: newPassController,
                hintText: '******',
                labelText: 'Enter Your New Password',
                obscureText: true,
              ),
              GapBox(10),

              MyTextFormField(
                controller: confirmPassController,
                hintText: '******',
                labelText: 'Confirm Your New Password',
                obscureText: true,
              ),

              GapBox(20),

              MyButton(
                text: isLoading ? "Updating..." : "Update",
                backgroundColor: AppColors.blue2,
                fixedWidth: double.infinity,
                onPressed: isLoading ? null : updatePassword,
              )
            ],
          ),
        ),
      ),
    );
  }
}
