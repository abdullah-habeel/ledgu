import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final Color? fillColor;
  final Color textColor;
  final double borderRadius;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly; // important

  const MyTextFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.fillColor = AppColors.black2,
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.readOnly = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor),
      readOnly: readOnly, // <<< THIS WAS MISSING BEFORE
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: fillColor ?? Colors.black,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
