import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:ledgu/utilties/ottp.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/text_button.dart';
import 'package:ledgu/widgets/textformfield.dart';

import '../../controller/auth/login_controller.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final LoginController loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GapBox(12),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage(MyImages.image),
                ),
              ),
              GapBox(12),
              MyTextFormField(
                controller: loginController.emailController,
                labelText: 'Email', hintText: 'Enter Email Here'
              ),
              GapBox(20),
              AppPinFields(
                length: 6, 
                onCompleted: (value) =>
                              loginController.pinController.text = value,  
                ),
              GapBox(21),
              MyButton(
                text: 'Login',
                onPressed: () => loginController.loginUser(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: "Don’t Remember PIN?",
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  MyTextButton(
                    text: 'Reset PIN',
                    textColor: AppColors.buttonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
