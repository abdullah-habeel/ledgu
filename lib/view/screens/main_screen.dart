import 'package:flutter/material.dart';
import 'package:ledgu/view/screens/dashboard.dart';
import 'package:ledgu/view/screens/friend.dart';
import 'package:ledgu/view/screens/history.dart';
import 'package:ledgu/view/screens/profile.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/bottom_nav_bar.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),   
    const FriendPage(),     
    const HistoryPage(),     
    ProfilePage(),     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black1,

      // ⭐ PAGE SWITCHING
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: MyBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
