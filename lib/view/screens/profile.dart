import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:ledgu/view/auth/update_profile.dart';
import 'package:ledgu/view/auth/update_password.dart';   // <<< IMPORTANT
import 'package:ledgu/view/screens/user_group.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/list_tile.dart';
import 'package:ledgu/widgets/text.dart';

import '../../controller/auth/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final profileController = ProfileController();

  String fullName = '';
  String contact = '';
  String city = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Load current user info from Firestore
  void _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fullName = data['fullName'] ?? '';
          contact = data['contact'] ?? '';
          city = data['city'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GapBox(15),
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(MyImages.image),
                ),
              ),
              GapBox(15),
              Center(
                child: MyText(
                  text: fullName.isNotEmpty ? fullName : 'Loading...',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey1,
                ),
              ),
              GapBox(15),
              Center(
                child: MyText(
                  text: contact.isNotEmpty && city.isNotEmpty
                      ? '$contact | $city'
                      : 'Loading...',
                  color: AppColors.grey1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GapBox(15),

              /// UPDATE PROFILE
              MyListTile(
                leadingIcon: Icons.settings,
                title: 'Update Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdateProfilePage(),
                    ),
                  ).then((_) => _loadCurrentUser());
                },
                onTrailingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdateProfilePage(),
                    ),
                  ).then((_) => _loadCurrentUser());
                },
              ),

              GapBox(10),

              /// UPDATE PIN (PASSWORD)
              MyListTile(
                leadingIcon: Icons.lock_outline,
                title: 'Update PIN',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpdatePassword()),
                  );
                },
                onTrailingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpdatePassword()),
                  );
                },
              ),

              GapBox(10),

              MyText(
                text: 'Others',
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: AppColors.grey1,
              ),

              GapBox(10),

              /// LOGOUT
              MyListTile(
                leadingIcon: Icons.info_outline,
                title: 'Logout',
                onTap: () => profileController.logout(context),
                onTrailingTap: () => profileController.logout(context),
              ),

              GapBox(10),

              /// USERS SCREEN
              MyListTile(
                leadingIcon: Icons.settings,
                title: 'User',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserGroupScreen(),
                    ),
                  );
                },
                onTrailingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserGroupScreen(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
