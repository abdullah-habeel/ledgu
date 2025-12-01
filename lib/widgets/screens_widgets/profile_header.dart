import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/utilties/images.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String contact;
  final String city;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.contact,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        CircleAvatar(radius: 70, backgroundImage: AssetImage(MyImages.image)),
        const SizedBox(height: 15),
        MyText(
          text: fullName.isNotEmpty ? fullName : 'Loading...',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey1,
        ),
        const SizedBox(height: 15),
        MyText(
          text: contact.isNotEmpty && city.isNotEmpty
              ? '$contact | $city'
              : 'Loading...',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.grey1,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
