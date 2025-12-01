import 'package:flutter/material.dart';
import 'package:ledgu/widgets/text.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final VoidCallback? onTrailingTap;

  const ProfileTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leadingIcon, color: Colors.white),
      title: MyText(text: title, color: Colors.white, fontSize: 14),
      trailing: IconButton(
        icon: Icon(leadingIcon, color: Colors.white),
        onPressed: onTrailingTap ?? onTap,
      ),
      onTap: onTap,
    );
  }
}
