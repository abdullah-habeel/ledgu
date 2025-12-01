import 'package:flutter/material.dart';
import 'package:ledgu/widgets/info_container.dart';

class InfoSection extends StatelessWidget {
  final int totalFriends;
  final int totalGroups;

  const InfoSection({
    super.key,
    required this.totalFriends,
    required this.totalGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoContainer(
            iconData: Icons.group_rounded,
            number: totalFriends,
            bottomText: "Friends",
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: InfoContainer(
            iconData: Icons.groups_rounded,
            number: totalGroups,
            bottomText: "Groups",
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: InfoContainer(
            iconData: Icons.pending_actions_rounded,
            number: 8,
            bottomText: "Pending",
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: InfoContainer(
            iconData: Icons.payments_rounded,
            number: 20,
            bottomText: "To Pay",
          ),
        ),
      ],
    );
  }
}
