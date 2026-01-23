import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/transaction_tile.dart';

class TransactionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final Stream<QuerySnapshot<Map<String, dynamic>>> groupsStream;
  final bool showAll; // <-- new

  const TransactionsSection({
    super.key,
    required this.friends,
    required this.groupsStream,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    // Limit friend transactions to 3 if showAll is false
    final friendTx = showAll ? friends : friends.take(3).toList();

    return ListView(
      children: [
        Divider(color: AppColors.grey1),

        /// Last friend transactions
        ...friendTx.map((friend) {
          return TransactionTile(
            title: friend['fullName'] ?? "User",
            subtitle: "Last Transaction",
            date: "15 Nov 2025",
            amount: 0,
          );
        }),

        const SizedBox(height: 10),

        /// Group transactions
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: groupsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            final docs = snapshot.data!.docs;
            final groupTx = showAll ? docs : docs.take(3).toList();

            return Column(
              children: groupTx.map((doc) {
                final data = doc.data();
                return TransactionTile(
                  title: data['name'] ?? "Group",
                  subtitle: "Group Transaction",
                  date: "15 Nov 2025",
                  amount: 0,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
