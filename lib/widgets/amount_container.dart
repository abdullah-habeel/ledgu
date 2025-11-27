import 'package:flutter/material.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/utilties/colors.dart';

class AmountContainer extends StatelessWidget {
  final double height;
  final double widthFactor; 
  final Color containerColor;
  final String topText;
  final String bottomText;
  final Color topTextColor;
  final Color bottomTextColor;
  final double spacing;
  final double topTextSize;
  final double bottomTextSize;
  final FontWeight topTextWeight;
  final FontWeight bottomTextWeight;

  const AmountContainer({
    super.key,
    this.height = 70,
    this.widthFactor = 0.8,
    this.containerColor = AppColors.green,
    required this.topText,
    required this.bottomText,
    this.topTextColor = Colors.white,
    this.bottomTextColor = Colors.white,
    this.spacing = 10,
    this.topTextSize = 18,
    this.bottomTextSize = 14,
    this.topTextWeight = FontWeight.bold,
    this.bottomTextWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: screenWidth * widthFactor,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyText(
            text: topText,
            color: topTextColor,
            fontSize: topTextSize,
            fontWeight: topTextWeight,
          ),
          GapBox(spacing),
          MyText(
            text: bottomText,
            color: bottomTextColor,
            fontSize: bottomTextSize,
            fontWeight: bottomTextWeight,
          ),
        ],
      ),
    );
  }
}
