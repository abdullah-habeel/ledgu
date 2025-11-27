import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onPressed;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: size,
        color: color,
      ),
      onPressed: onPressed,
    );
  }
}
