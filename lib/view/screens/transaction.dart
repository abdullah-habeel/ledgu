import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/screens_widgets/transaction_tile.dart';

class TransactionPage extends StatelessWidget {
  final String id; // friend UID or groupId
  final String name;
  final bool isGroup;

  TransactionPage({
    super.key,
    required this.id,
    required this.name,
    this.isGroup = false,
  });

  final TransactionController controller = TransactionController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        title: Text("$name Transactions"),
        centerTitle: true,
      ),
      backgroundColor: AppColors.black1,
      body: isGroup ? _buildGroupTransactions() : _buildFriendTransactions(),
    );
  }

  Widget _buildFriendTransactions() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getFriendTransactions(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No transactions yet"));
        }

        final txList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: txList.length,
          itemBuilder: (context, index) {
            final tx = txList[index];
            final amount = (tx['amount'] ?? 0).toString();
            final date = tx['time'] != null
                ? (tx['time'] as DateTime).toString()
                : '';
            final fromUid = tx['from'] ?? '';
            final toUid = tx['to'] ?? '';

            return FutureBuilder<String>(
              future: controller.getUserName(
                  fromUid == controller.currentUserId ? toUid : fromUid),
              builder: (context, snapshot) {
                final displayName = snapshot.data ?? "Loading...";
                return TransactionTileWidget(
                  title: "Transaction",
                  subtitle: "From: $displayName",
                  amount: amount,
                  date: date,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupTransactions() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getGroupTransactions(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No transactions yet"));
        }

        final txList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: txList.length,
          itemBuilder: (context, index) {
            final tx = txList[index];
            final amount = (tx['amount'] ?? 0).toString();
            final date = tx['time'] != null
                ? (tx['time'] as DateTime).toString()
                : '';
            final fromUid = tx['from'] ?? '';
            final toList = (tx['toList'] as List<dynamic>?) ?? [];

            return FutureBuilder<List<String>>(
              future: Future.wait(
                  toList.map((uid) => controller.getUserName(uid.toString()))),
              builder: (context, snapshot) {
                final displayTo =
                    snapshot.hasData ? snapshot.data!.join(", ") : "Loading...";
                return TransactionTileWidget(
                  title: "Group Transaction",
                  subtitle: "From: ${fromUid} To: $displayTo",
                  amount: amount,
                  date: date,
                );
              },
            );
          },
        );
      },
    );
  }
}
