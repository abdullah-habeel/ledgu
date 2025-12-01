import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/profile_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/view/auth/update_password.dart';
import 'package:ledgu/view/screens/user_group.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/screens_widgets/profile_header.dart';
import 'package:ledgu/widgets/screens_widgets/profile_tile.dart';
import 'package:ledgu/widgets/screens_widgets/update_profile.dart';
import 'package:ledgu/widgets/text.dart';


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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    setState(() => _isLoading = true);
    final data = await profileController.getCurrentUserInfo();
    if (mounted) {
      setState(() {
        fullName = data['fullName'] ?? '';
        contact = data['contact'] ?? '';
        city = data['city'] ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      fullName: fullName,
                      contact: contact,
                      city: city,
                    ),
                    const GapBox(10),
                    ProfileTile(
                      title: 'Update Profile',
                      leadingIcon: Icons.settings,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateProfilePage(
                              fullName: fullName,
                              contact: contact,
                              city: city,
                            ),
                          ),
                        );
                        if (updated == true) _loadCurrentUser();
                      },
                    ),
                    const GapBox(10),
                    ProfileTile(
                      title: 'Update PIN',
                      leadingIcon: Icons.lock_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UpdatePassword()),
                      ),
                    ),
                    const GapBox(10),
                    MyText(
                      text: 'Others',
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: AppColors.grey1,
                    ),
                    const GapBox(10),
                    ProfileTile(
                      title: 'Logout',
                      leadingIcon: Icons.info_outline,
                      onTap: () => profileController.logout(context),
                    ),
                    const GapBox(10),
                    ProfileTile(
                      title: 'User',
                      leadingIcon: Icons.settings,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserGroupScreen()),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
