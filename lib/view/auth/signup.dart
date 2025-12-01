// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ledgu/controller/auth/signup_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/ottp.dart';
import 'package:ledgu/view/auth/login.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/text_button.dart';
import 'package:ledgu/widgets/textformfield.dart';

import '../screens/main_screen.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final SignupController controller = SignupController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, child) {
            return Stack(
              children: [
                // =====================
                // Main Signup UI
                // =====================
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        GapBox(12),
                        MyText(
                          text: 'Signup Account',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        MyText(
                          text:
                              'You can add personal details to\n strong the pos store profile.',
                          color: AppColors.grey1,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        GapBox(12),

                        // INPUTS
                        MyTextFormField(
                          labelText: 'Full Name',
                          hintText: 'Enter  Here',
                          controller: controller.nameController,
                        ),
                        GapBox(10),
                        MyTextFormField(
                          labelText: 'Contact No',
                          hintText: 'Enter  Here',
                          controller: controller.contactController,
                        ),
                        GapBox(10),
                        MyTextFormField(
                          labelText: 'City',
                          hintText: 'Enter  Here',
                          controller: controller.cityController,
                        ),
                        GapBox(10),
                        MyTextFormField(
                          labelText: 'Email',
                          hintText: 'Enter  Here',
                          controller: controller.emailController,
                        ),

                        GapBox(20),
                        MyText(
                          text: 'Enter Your Secret PIN',
                          color: AppColors.grey1,
                          fontWeight: FontWeight.w600,
                        ),
                        GapBox(10),

                        AppPinFields(
                          length: 6,
                          onCompleted: (value) =>
                              controller.pinController.text = value,
                        ),
                        GapBox(21),

                        // ============================
                        // Signup Button
                        // ============================
                        MyButton(
                          text: 'Signup',
                          backgroundColor: AppColors.blue2,
                          onPressed: () async {
                            isLoading.value = true; // show loader

                            final user =
                                await controller.registerUser(context);

                            isLoading.value = false; // hide loader

                            if (user != null) {
                              // SUCCESS MESSAGE
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Signup Successful!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              controller.clearFields();

                              // Delay before navigation
                              Future.delayed(
                                  const Duration(milliseconds: 800), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MainScreen()),
                                );
                              });
                            } else {
                              // FAILED MESSAGE
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Signup Failed! Please try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              text: "Have account?",
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            MyTextButton(
                              text: 'Login',
                              textColor: AppColors.buttonColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Login()),
                                );
                              },

                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // =====================
                // Loading Overlay
                // =====================
                if (loading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
