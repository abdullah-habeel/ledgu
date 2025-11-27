import 'package:flutter/material.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/utilties/colors.dart';

class InfoContainer extends StatelessWidget {
  final double height;
  final double widthFactor;
  final Color containerColor;
  final IconData iconData;
  final Color iconAndTextColor;
  final int number;
  final String bottomText;
  final double spacing;
  final double contentSize;

  const InfoContainer({
    super.key,
    this.height = 80,
    this.widthFactor = 0.8,
    this.containerColor = AppColors.black2,
    required this.iconData,
    this.iconAndTextColor = AppColors.grey1,
    required this.number,
    required this.bottomText,
    this.spacing = 4,
    this.contentSize = 16, 
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
          Icon(
            iconData,
            color: iconAndTextColor,
            size: contentSize,
          ),
          GapBox(spacing),
          MyText(
            text: number.toString(),
            color: Colors.white,
            fontSize: contentSize,
            fontWeight: FontWeight.bold,
          ),
          GapBox(spacing),
          MyText(
            text: bottomText,
            color: iconAndTextColor,
            fontSize: contentSize,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
