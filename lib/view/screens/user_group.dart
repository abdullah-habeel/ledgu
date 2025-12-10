import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/friend_controller.dart';
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

  final FriendController controller = FriendController();
  final GroupController groupController = GroupController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupInfoController = TextEditingController();
  final TextEditingController newMemberEmailController = TextEditingController();

  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> friends = [];
  List<String> selectedFriendUids = [];
  List<Map<String, dynamic>> addedEmails = [];
  bool isLoading = false;
  bool isAddingEmail = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadFriends();
  }

  Future<void> loadFriends() async {
    final loadedFriends = await controller.getFriends();
    setState(() => friends = loadedFriends);
  }

  Future<void> fetchUserByEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
      userData = null;
    });

    final data = await groupController.getUserByEmail(email);
    if (data != null) {
      setState(() => userData = data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found")));
    }

    setState(() => isLoading = false);
  }

  Future<void> addFriend() async {
    if (userData == null) return;
    final friendUid = userData!['uid'] ?? userData!['id'];
    await controller.addFriend(friendUid);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Friend added successfully")),
    );

    await loadFriends();
  }

  Future<void> addEmailMemberToGroup() async {
    final email = newMemberEmailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isAddingEmail = true;
    });

    final data = await groupController.getUserByEmail(email);
    if (data != null) {
      final uid = data['uid'] ?? data['id'];
      if (!selectedFriendUids.contains(uid)) {
        selectedFriendUids.add(uid);
        addedEmails.add(data);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User added to group")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found")),
      );
    }

    newMemberEmailController.clear();
    setState(() => isAddingEmail = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    groupNameController.dispose();
    groupInfoController.dispose();
    newMemberEmailController.dispose();
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
        title: const MyText(
          text: 'ADD Account',
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
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
                  const GapBox(10),
                  MyButton(
                    text: 'Add Friend',
                    backgroundColor: AppColors.green,
                    onPressed: addFriend,
                  ),
                ],
              ),
            ),
          const GapBox(20),
          MyButton(
            text: isLoading ? "Loading..." : "Search",
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
          // Group Name
          MyTextFormField(
            controller: groupNameController,
            labelText: 'Group Title',
            hintText: 'Enter Group Name',
          ),
          const GapBox(10),

          // Group Info
          MyTextFormField(
            controller: groupInfoController,
            labelText: 'Info',
            hintText: 'Enter Group Info',
          ),
          const GapBox(20),

          // Select friends from existing friends
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

          // New member email field like other fields
          MyTextFormField(
            controller: newMemberEmailController,
            labelText: 'Add Member by Email',
            hintText: 'Enter user email',
          ),
          const GapBox(10),
          MyButton(
            text: isAddingEmail ? "Adding..." : "Add Email",
            backgroundColor: AppColors.green,
            onPressed: isAddingEmail ? null : addEmailMemberToGroup,
          ),

          // Show added emails below
          ...addedEmails.map((e) => Padding(
                padding: const EdgeInsets.only(top: 5),
                child: MyText(text: "Added: ${e['fullName']}", color: Colors.white, fontSize: 14),
              )),

          const GapBox(20),

          // Create group button
          MyButton(
            text: 'Create Group',
            fixedWidth: double.infinity,
            backgroundColor: AppColors.blue2,
            onPressed: () async {
              if (groupNameController.text.isEmpty || selectedFriendUids.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter group name and at least one member")),
                );
                return;
              }

              await groupController.createGroup(
                groupNameController.text,
                groupInfoController.text,
                selectedFriendUids,
              );

              groupNameController.clear();
              groupInfoController.clear();
              newMemberEmailController.clear();
              selectedFriendUids.clear();
              addedEmails.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Group created successfully")),
              );
            },
          ),
          const GapBox(30),
        ],
      ),
    );
  }
}
