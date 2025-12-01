import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/transaction_tile.dart';

class TransactionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final Stream<QuerySnapshot<Map<String, dynamic>>> groupsStream;

  const TransactionsSection({
    super.key,
    required this.friends,
    required this.groupsStream,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: MyText(
            text: "Transactions",
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 17,
          ),
          trailing: MyText(
            text: "See All",
            fontWeight: FontWeight.bold,
            color: AppColors.blue2,
            fontSize: 15,
          ),
        ),
        Divider(color: AppColors.grey1),

        /// Last 5 friend transactions
        ...friends.take(5).map((friend) {
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

            return Column(
              children: snapshot.data!.docs.map((doc) {
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
