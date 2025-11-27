import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/text.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              SizedBox(
                height: 468,
                width: double.infinity,
                child: Image.asset(MyImages.image),
              ),
              SizedBox(height: 10),
              Center(
                child: MyText(
                  text: 'Welcome to Mobile App ',
                  color: AppColors.grey1,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: MyText(
                  text:
                      'Help you manage your inventory in\n offline App. Help yomanage your.',
                  color: AppColors.grey1,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 10),
              MyButton(text: 'Get Started', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
