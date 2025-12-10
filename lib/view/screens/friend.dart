import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/friend_controller.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/controller/screens_controller/group_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/view/screens/send_money.dart';
import 'package:ledgu/view/screens/transaction.dart';
import 'package:ledgu/widgets/screens_widgets/friend_list.dart';
import 'package:ledgu/widgets/screens_widgets/group_list.dart';
import 'package:ledgu/widgets/screens_widgets/sendmoney_split.dart';
import 'package:ledgu/widgets/text.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final FriendController controller = FriendController();
  final TransactionController txController = TransactionController();
  final GroupController groupController = GroupController();

  // ---------------- Transaction & Group Functions ----------------
  void openTransaction(Map<String, dynamic> userOrGroup, bool isGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionPage(
          id: userOrGroup['uid'] ?? userOrGroup['id'] ?? "",
          name: userOrGroup['fullName'] ?? userOrGroup['name'] ?? "Name",
          isGroup: isGroup,
        ),
      ),
    );
  }

  void openSendMoney(Map<String, dynamic> userOrGroup, {bool isGroup = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (_) => SendMoneySheet(
        userOrGroup: userOrGroup,
        isGroup: isGroup,
        txController: txController,
      ),
    );
  }

  void openSendMoneySplit(Map<String, dynamic> group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SendMoneySplitSheet(
        group: group,
        txController: txController,
      ),
    );
  }

  // ---------------- Edit Group ----------------
  void _editGroup(Map<String, dynamic> group) async {
    final nameController = TextEditingController(text: group['name']);
    final infoController = TextEditingController(text: group['info']);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Group"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: infoController, decoration: const InputDecoration(labelText: "Info")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    );

    if (result == true) {
      await groupController.editGroup(
        groupId: group['id'],
        name: nameController.text,
        info: infoController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group updated successfully")),
      );
    }
  }

  // ---------------- Delete Group ----------------
  void _deleteGroup(Map<String, dynamic> group) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Group"),
        content: const Text("Are you sure you want to delete this group?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (result == true) {
      await groupController.deleteGroup(group['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        centerTitle: true,
        title: const MyText(
          text: "Friends & Groups",
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ---------------- Friends ----------------
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.getFriendsStream(),
              builder: (context, snapshot) {
                final friends = snapshot.data ?? [];
                return FriendListWidget(
                  friends: friends,
                  onSendMoney: (f) => openSendMoney(f),
                  onViewTransaction: (f) => openTransaction(f, false),
                );
              },
            ),
            const SizedBox(height: 20),

            // ---------------- Groups ----------------
            GroupListWidget(
              groupsStream: groupController.getUserGroupsStream(),
              onSendMoney: (g) => openSendMoneySplit(g),
              onViewTransaction: (g) => openTransaction(g, true),
              onEditGroup: _editGroup,
              onDeleteGroup: _deleteGroup,
            ),
          ],
        ),
      ),
    );
  }
}
