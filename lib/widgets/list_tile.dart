import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/icon_button.dart';

class MyListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onTrailingTap;
  final Color tileColor;

  const MyListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
    required this.onTrailingTap,
    this.tileColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.black2,
      onTap: onTap,
      leading: Icon(leadingIcon, size: 28, color: AppColors.grey1),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.grey1,
        ),
      ),
      trailing: MyIconButton(
        icon: Icons.arrow_forward_ios,
        size: 20,
        color: AppColors.grey1,
        onPressed: onTrailingTap,
      ),
    );
  }
}
