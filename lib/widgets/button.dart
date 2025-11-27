import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'dart:async'; // <-- for FutureOr

class MyButton extends StatelessWidget {
  final String text;
  final FutureOr<void> Function()? onPressed; // <-- changed
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double height;
  final double borderRadius;
  final double? widthFactor; // nullable
  final double? fixedWidth;  // optional fixed width

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.foregroundColor = Colors.white,
    this.backgroundColor = AppColors.buttonColor,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1,
    this.height = 50,
    this.borderRadius = 12,
    this.widthFactor = 0.8,  // default 80%
    this.fixedWidth,          // optional
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double finalWidth;
    if (fixedWidth != null) {
      finalWidth = fixedWidth!;
    } else if (widthFactor != null) {
      finalWidth = screenWidth * widthFactor!;
    } else {
      finalWidth = double.infinity;
    }

    return SizedBox(
      width: finalWidth,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed!(); // <-- call async or sync safely
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
