// friend_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/controller/auth/group_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/view/screens/transaction.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/textformfield.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final GroupController groupController = GroupController();
  List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);
    List<Map<String, dynamic>> temp = [];

    for (String uid in friendUids) {
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        temp.add({'uid': friendDoc.id, ...?friendDoc.data()});
      }
    }

    setState(() {
      friends = temp;
    });
  }

  void openSendFriendMoneySheet(Map<String, dynamic> friend) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      backgroundColor: AppColors.black2,
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(text: "Send Money to ${friend['fullName']}", color: Colors.white),
              GapBox(20),
              MyTextFormField(
                controller: amountController,
                hintText: "Enter total amount",
                labelText: "Amount",
                keyboardType: TextInputType.number,
              ),
              GapBox(20),
              MyButton(
                text: "Send",
                onPressed: () async {
                  final totalAmount = double.tryParse(amountController.text.trim()) ?? 0;
                  if (totalAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter valid amount")),
                    );
                    return;
                  }

                  await groupController.sendMoneyToFriend(friend['uid'], totalAmount);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction sent!")),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  void openSendGroupMoneySheet(Map<String, dynamic> group) {
    final amountController = TextEditingController();
    List<String> selectedMembers = List<String>.from(group['members'] ?? []);

    showModalBottomSheet(
      backgroundColor: AppColors.black2,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(text: "Send Money to ${group['name']}", color: Colors.white),
                  GapBox(20),
                  MyTextFormField(
                    controller: amountController,
                    hintText: "Enter total amount",
                    labelText: "Amount",
                    keyboardType: TextInputType.number,
                  ),
                  GapBox(20),
                  const MyText(
                    text: "Select Members to Share",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  ...List<String>.from(group['members'] ?? []).map((memberUid) {
                    final isSelected = selectedMembers.contains(memberUid);
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('users').doc(memberUid).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
                        final memberData = snapshot.data!.data()!;
                        return CheckboxListTile(
                          title: MyText(text: memberData['fullName'] ?? "User", color: Colors.white),
                          value: isSelected,
                          activeColor: AppColors.blue2,
                          onChanged: (val) {
                            setStateModal(() {
                              if (val == true) {
                                selectedMembers.add(memberUid);
                              } else {
                                selectedMembers.remove(memberUid);
                              }
                            });
                          },
                        );
                      },
                    );
                  }).toList(),
                  GapBox(20),
                  MyButton(
                    text: "Send",
                    onPressed: () async {
                      final totalAmount = double.tryParse(amountController.text.trim()) ?? 0;
                      if (totalAmount <= 0 || selectedMembers.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter valid amount and select members")),
                        );
                        return;
                      }

                      await groupController.sendMoneyToGroup(group['id'], selectedMembers, totalAmount);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction sent!")),
                      );
                    },
                  ),
                  GapBox(50),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        title: const MyText(
          text: "Friends & Groups",
          color: Colors.white,
          fontSize: 16,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: friends.isEmpty
                  ? const Center(
                      child: MyText(text: "No friends yet", color: AppColors.grey1),
                    )
                  : ListView(
                      children: [
                        const MyText(text: "Your Friends", color: Colors.white, fontSize: 14),
                        const SizedBox(height: 10),
                        ...friends.map((f) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.black2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: MyText(text: f['fullName'] ?? "User", color: Colors.white),
                              subtitle: MyText(text: f['email'] ?? "", color: AppColors.grey1),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.history, color: Colors.orange),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TransactionPage(
                                            id: f['uid'] ?? "",
                                            name: f['fullName'] ?? "User",
                                            isGroup: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.attach_money, color: Colors.green),
                                    onPressed: () => openSendFriendMoneySheet(f),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const Divider(color: Colors.white),
                        const MyText(text: "Your Groups", color: Colors.white, fontSize: 14),
                        const SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: groupController.getUserGroupsStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final groupsDocs = snapshot.data!.docs;
                            if (groupsDocs.isEmpty)
                              return const MyText(text: "No groups yet", color: AppColors.grey1);

                            return Column(
                              children: groupsDocs.map((doc) {
                                final data = doc.data();
                                data['id'] = doc.id;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.black2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    title: MyText(text: data['name'] ?? "Group", color: Colors.white),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.history, color: Colors.orange),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => TransactionPage(
                                                  id: data['id'] ?? "",
                                                  name: data['name'] ?? "Group",
                                                  isGroup: true,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.attach_money, color: Colors.green),
                                          onPressed: () => openSendGroupMoneySheet(data),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
