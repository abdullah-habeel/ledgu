import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.black2,
      selectedItemColor: AppColors.blue2,
      unselectedItemColor: AppColors.grey1,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_rounded),
          label: "Friends",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: "Profile",
        ),
      ],
    );
  }
}
