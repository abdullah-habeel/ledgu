import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ledgu/utilties/colors.dart';

class AppPinFields extends StatelessWidget {
  final int length;
  final double fieldWidth;
  final double fieldHeight;
  final double borderRadius;
  final Function(String) onCompleted;

  const AppPinFields({
    super.key,
    this.length = 4,
    this.fieldWidth = 40,
    this.fieldHeight = 40,
    this.borderRadius = 8,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      enableActiveFill: true,
      animationDuration: const Duration(milliseconds: 300),
      cursorColor: AppColors.blue1,
      obscureText: true,
      obscuringCharacter: '*',
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        fieldHeight: fieldHeight,
        fieldWidth: fieldWidth,
        borderRadius: BorderRadius.circular(borderRadius),
        activeColor: AppColors.blue1,
        inactiveColor: AppColors.grey1,
        selectedColor: AppColors.lightBlue,
        activeFillColor: AppColors.grey1,
        inactiveFillColor: AppColors.black2,
        selectedFillColor: AppColors.black2,
      ),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      onCompleted: onCompleted,
      onChanged: (value) {},
    );
  }
}
