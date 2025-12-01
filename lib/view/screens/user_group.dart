// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/group_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/textformfield.dart';

class UserGroupScreen extends StatefulWidget {
  const UserGroupScreen({super.key});

  @override
  State<UserGroupScreen> createState() => _UserGroupScreenState();
}

class _UserGroupScreenState extends State<UserGroupScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final GroupController controller = GroupController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupInfoController = TextEditingController();

  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> friends = [];
  List<String> selectedFriendUids = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadFriends();
  }

  Future<void> loadFriends() async {
    final loadedFriends = await controller.loadFriends();
    setState(() => friends = loadedFriends);
  }

  Future<void> fetchUserByEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
      userData = null;
    });

    final data = await controller.getUserByEmail(email);
    if (data != null) {
      setState(() => userData = data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found")));
    }

    setState(() => isLoading = false);
  }

  Future<void> createGroup() async {
    final name = groupNameController.text.trim();
    final info = groupInfoController.text.trim();

    if (name.isEmpty || selectedFriendUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter group name and select at least one friend")));
      return;
    }

    await controller.createGroup(name, info, selectedFriendUids);

    setState(() {
      groupNameController.clear();
      groupInfoController.clear();
      selectedFriendUids.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Group created successfully")));
  }

  @override
  void dispose() {
    emailController.dispose();
    groupNameController.dispose();
    groupInfoController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black1,
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        leading: const BackButton(),
        title: const MyText(text: 'ADD Account', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TabBar(
            controller: tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.blue),
              insets: EdgeInsets.symmetric(horizontal: 100),
            ),
            tabs: const [Tab(text: "User"), Tab(text: "Group")],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [buildUserTab(), buildGroupTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(controller: emailController, hintText: 'Enter Here', labelText: 'Email'),
          const GapBox(10),
          if (userData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.black2, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(text: "Name: ${userData!['fullName']}", color: Colors.white, fontSize: 14),
                  const GapBox(5),
                  MyText(text: "City: ${userData!['city']}", color: Colors.white, fontSize: 14),
                  const GapBox(5),
                  MyText(text: "Contact: ${userData!['contact']}", color: Colors.white, fontSize: 14),
                ],
              ),
            ),
          const GapBox(20),
          MyButton(
            text: isLoading ? "Loading..." : "Continue",
            backgroundColor: AppColors.blue2,
            fixedWidth: double.infinity,
            onPressed: isLoading ? null : fetchUserByEmail,
          ),
        ],
      ),
    );
  }

  Widget buildGroupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(controller: groupNameController, labelText: 'Group Title', hintText: 'Enter Group Name'),
          const GapBox(10),
          MyTextFormField(controller: groupInfoController, labelText: 'Info', hintText: 'Enter Group Info'),
          const GapBox(20),
          const MyText(text: "Select Friends", color: Colors.white, fontSize: 14),
          const GapBox(10),
          ...friends.map((f) {
            final isSelected = selectedFriendUids.contains(f['uid']);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedFriendUids.add(f['uid']);
                  } else {
                    selectedFriendUids.remove(f['uid']);
                  }
                });
              },
              title: MyText(text: f['fullName'], color: Colors.white),
              activeColor: AppColors.blue2,
            );
          }),
          const GapBox(20),
          MyButton(
            text: 'Create Group',
            fixedWidth: double.infinity,
            backgroundColor: AppColors.blue2,
            onPressed: createGroup,
          ),
          const GapBox(30),
        ],
      ),
    );
  }
}
