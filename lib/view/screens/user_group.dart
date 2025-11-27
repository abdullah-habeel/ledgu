// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class _UserGroupScreenState extends State<UserGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupInfoController = TextEditingController();

  Map<String, dynamic>? userData;
  bool isLoading = false;

  // Friends and group selection
  List<Map<String, dynamic>> friends = [];
  List<String> selectedFriendUids = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadFriends();
  }

  @override
  void dispose() {
    emailController.dispose();
    groupNameController.dispose();
    groupInfoController.dispose();
    tabController.dispose();
    super.dispose();
  }

  // =========================
  // FETCH USER BY EMAIL
  // =========================
  Future<void> fetchUserByEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      userData = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs.first.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // LOAD FRIENDS
  // =========================
  Future<void> loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final friendUids = List<String>.from(userDoc['friends'] ?? []);
    List<Map<String, dynamic>> temp = [];

    for (String uid in friendUids) {
      final friendDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) temp.add({'uid': friendDoc.id, ...friendDoc.data()!});
    }

    setState(() {
      friends = temp;
    });
  }

  // =========================
  // CREATE GROUP
  // =========================
  Future<void> createGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final name = groupNameController.text.trim();
    final info = groupInfoController.text.trim();

    if (name.isEmpty || selectedFriendUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter group name and select at least one friend")),
      );
      return;
    }

    try {
      final members = [currentUser.uid, ...selectedFriendUids];

      final groupDocRef =
          await FirebaseFirestore.instance.collection('groups').add({
        "name": name,
        "info": info,
        "members": members,
        "createdBy": currentUser.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await groupDocRef.update({"id": groupDocRef.id});

      // Reset
      groupNameController.clear();
      groupInfoController.clear();
      selectedFriendUids.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group created successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating group: $e")),
      );
    }
  }

  // =========================
  // UI BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          leading: const BackButton(),
          title: MyText(
            text: 'ADD Account',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.white,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Colors.blue),
                  insets: EdgeInsets.symmetric(horizontal: 100),
                ),
                tabs: const [
                  Tab(text: "User"),
                  Tab(text: "Group"),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  buildUserTab(),
                  buildGroupTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // USER TAB
  // =========================
  Widget buildUserTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(
            controller: emailController,
            hintText: 'Enter Here',
            labelText: 'Email',
          ),
          GapBox(10),
          if (userData != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.black2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: "Name: ${userData!['fullName']}",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  GapBox(5),
                  MyText(
                    text: "City: ${userData!['city']}",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  GapBox(5),
                  MyText(
                    text: "Contact: ${userData!['contact']}",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
            GapBox(20),
          ],
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

  // =========================
  // GROUP TAB
  // =========================
  Widget buildGroupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(
            controller: groupNameController,
            labelText: 'Group Title',
            hintText: 'Enter Group Name',
          ),
          GapBox(10),
          MyTextFormField(
            controller: groupInfoController,
            labelText: 'Info',
            hintText: 'Enter Group Info',
          ),
          GapBox(20),
          const MyText(
            text: "Select Friends",
            color: Colors.white,
            fontSize: 14,
          ),
          GapBox(10),
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
          }).toList(),
          GapBox(20),
          MyButton(
            text: 'Create Group',
            fixedWidth: double.infinity,
            backgroundColor: AppColors.blue2,
            onPressed: createGroup,
          ),
          GapBox(30),
        ],
      ),
    );
  }
}
