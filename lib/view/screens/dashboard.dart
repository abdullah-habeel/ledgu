import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/controller/auth/group_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/amount_container.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/info_container.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/transaction_tile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GroupController groupController = GroupController();
  List<Map<String, dynamic>> friends = [];
  int totalFriends = 0;
  int totalGroups = 0;

  @override
  void initState() {
    super.initState();
    loadFriends();
    loadGroups();
  }

  // Load actual friends from Firestore
  Future<void> loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);
    List<Map<String, dynamic>> temp = [];

    for (String uid in friendUids) {
      final friendDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        temp.add({'uid': friendDoc.id, ...?friendDoc.data()});
      }
    }

    setState(() {
      friends = temp;
      totalFriends = temp.length;
    });
  }

  // Load number of groups
  void loadGroups() {
    final stream = groupController.getUserGroupsStream();
    stream.listen((snapshot) {
      setState(() {
        totalGroups = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: MyText(
            text: 'Dashboard',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: 'My Wallet',
                color: AppColors.grey1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              GapBox(20),
              Row(
                children: [
                  Expanded(
                    child: AmountContainer(
                      topText: '15,000',
                      bottomText: 'Will Received',
                      containerColor: AppColors.blue1,
                      topTextColor: AppColors.green,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AmountContainer(
                      topText: '20,000',
                      bottomText: 'Will Paid',
                      containerColor: AppColors.blue1,
                      topTextColor: AppColors.red,
                    ),
                  ),
                ],
              ),
              GapBox(10),
              Row(
                children: [
                  Expanded(
                    child: InfoContainer(
                      iconData: Icons.group_rounded,
                      number: totalFriends,
                      bottomText: 'Friend',
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: InfoContainer(
                      iconData: Icons.groups_rounded,
                      number: totalGroups,
                      bottomText: 'Groups',
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: InfoContainer(
                      iconData: Icons.pending_actions_rounded,
                      number: 8, // still static, can be updated later
                      bottomText: 'Pending',
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: InfoContainer(
                      iconData: Icons.payments_rounded,
                      number: 20, // still static, can be updated later
                      bottomText: 'To Pay',
                    ),
                  ),
                ],
              ),
              GapBox(10),
              ListTile(
                leading: MyText(
                  text: 'Transaction',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 17,
                ),
                trailing: MyText(
                  text: 'See All',
                  color: AppColors.blue2,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: AppColors.grey1, thickness: 0.5),
              Expanded(
                child: ListView(
                  children: [
                    // Display last 5 transactions with friends
                    ...friends.take(5).map((friend) {
                      return TransactionTile(
                        title: friend['fullName'] ?? "User",
                        subtitle: "Last Transaction",
                        date: "15 Nov 2025", // can fetch real date from Firestore later
                        amount: 0, // can fetch actual amount from Firestore
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    // Display groups
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: groupController.getUserGroupsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final groupsDocs = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupsDocs.map((doc) {
                            final data = doc.data();
                            return TransactionTile(
                              title: data['name'] ?? "Group",
                              subtitle: "Group Transaction",
                              date: "15 Nov 2025",
                              amount: 0, // fetch actual total if needed
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
      ),
    );
  }
}
