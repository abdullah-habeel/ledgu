// transaction_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class TransactionPage extends StatelessWidget {
  final String id; // friend UID or groupId
  final String name;
  final bool isGroup;

  const TransactionPage({
    super.key,
    required this.id,
    required this.name,
    this.isGroup = false,
  });

  /// Helper to get user full name by UID
  Future<String> getUserName(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return data['fullName'] ?? uid;
    }
    return uid;
  }

  /// Friend transactions without StreamZip
  Stream<List<Map<String, dynamic>>> getFriendTransactions(String friendUid) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    final txCollection = FirebaseFirestore.instance.collection('transactions');

    // Stream of transactions where current user is involved with this friend
    return txCollection
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      final allTx = snapshot.docs
          .map((doc) => doc.data()..['id'] = doc.id)
          .where((tx) {
        final from = tx['from'] ?? '';
        final to = tx['to'] ?? '';
        return (from == currentUser.uid && to == friendUid) ||
            (from == friendUid && to == currentUser.uid);
      }).toList();

      allTx.sort((a, b) {
        final t1 = (a['time'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final t2 = (b['time'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return t2.compareTo(t1);
      });

      return allTx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: const MyText(text: "Transactions", color: Colors.white),
        ),
        body: const Center(
          child: MyText(text: "User not logged in", color: Colors.white),
        ),
      );
    }

    if (isGroup) {
      // Group transactions
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: MyText(text: "$name Transactions", color: Colors.white),
          centerTitle: true,
        ),
        backgroundColor: AppColors.black1,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('groupId', isEqualTo: id)
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: MyText(text: "No transactions yet", color: AppColors.grey1),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final tx = docs[index].data() as Map<String, dynamic>;
                final amount = tx['amount'] ?? 0;
                final time = tx['time'] != null
                    ? (tx['time'] as Timestamp).toDate()
                    : null;
                final fromUid = tx['from'] ?? '';
                final toUids =
                    (tx['toList'] as List<dynamic>?)?.cast<String>() ?? [];

                return Card(
                  color: AppColors.black2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: MyText(text: "Amount: $amount", color: Colors.white),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (time != null)
                          MyText(
                              text: "Time: $time",
                              color: AppColors.grey1,
                              fontSize: 12),
                        FutureBuilder<String>(
                          future: getUserName(fromUid),
                          builder: (context, snapFrom) {
                            final fromName =
                                snapFrom.hasData ? snapFrom.data! : fromUid;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: "From: $fromName",
                                  color: AppColors.grey1,
                                  fontSize: 12,
                                ),
                                const SizedBox(height: 4),
                                ...toUids.map((uid) => FutureBuilder<String>(
                                      future: getUserName(uid),
                                      builder: (context, snapTo) {
                                        final toName =
                                            snapTo.hasData ? snapTo.data! : uid;
                                        return MyText(
                                          text: "To: $toName",
                                          color: AppColors.grey1,
                                          fontSize: 12,
                                        );
                                      },
                                    )),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      // Friend transactions
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          title: MyText(text: "$name Transactions", color: Colors.white),
          centerTitle: true,
        ),
        backgroundColor: AppColors.black1,
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: getFriendTransactions(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: MyText(
                  text: "No transactions yet",
                  color: AppColors.grey1,
                ),
              );
            }

            final docs = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final tx = docs[index];
                final amount = tx['amount'] ?? 0;
                final time = tx['time'] != null
                    ? (tx['time'] as Timestamp).toDate()
                    : null;
                final fromUid = tx['from'] ?? '';
                final toUid = tx['to'] ?? '';

                return Card(
                  color: AppColors.black2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: MyText(text: "Amount: $amount", color: Colors.white),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (time != null)
                          MyText(
                            text: "Time: $time",
                            color: AppColors.grey1,
                            fontSize: 12,
                          ),
                        FutureBuilder<String>(
                          future: getUserName(fromUid),
                          builder: (context, snapFrom) {
                            final fromName =
                                snapFrom.hasData ? snapFrom.data! : fromUid;
                            return FutureBuilder<String>(
                              future: getUserName(toUid),
                              builder: (context, snapTo) {
                                final toName =
                                    snapTo.hasData ? snapTo.data! : toUid;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: "From: $fromName",
                                      color: AppColors.grey1,
                                      fontSize: 12,
                                    ),
                                    MyText(
                                      text: "To: $toName",
                                      color: AppColors.grey1,
                                      fontSize: 12,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}
