import 'package:flutter/material.dart';

class GapBox extends StatelessWidget {
  final double height;

  const GapBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
