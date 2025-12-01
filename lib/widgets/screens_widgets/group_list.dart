import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class GroupListWidget extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> groupsStream;
  final void Function(Map<String, dynamic>) onSendMoney;
  final void Function(Map<String, dynamic>) onViewTransaction;
  final void Function(Map<String, dynamic>)? onEditGroup;
  final void Function(Map<String, dynamic>)? onDeleteGroup;

  const GroupListWidget({
    super.key,
    required this.groupsStream,
    required this.onSendMoney,
    required this.onViewTransaction,
    this.onEditGroup,
    this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: groupsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: MyText(text: "No groups yet", color: AppColors.grey1));
        }

        final groups = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
                text: "Your Groups", color: Colors.white, fontSize: 14),
            const SizedBox(height: 10),
            ...groups.map((doc) {
              final group = {'id': doc.id, ...doc.data()};
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: MyText(text: group['name'] ?? "Group", color: Colors.white),
                  subtitle: MyText(text: group['info'] ?? "", color: AppColors.grey1),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.orange),
                        onPressed: () => onViewTransaction(group),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_money, color: Colors.green),
                        onPressed: () => onSendMoney(group),
                      ),
                      if (onEditGroup != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => onEditGroup!(group),
                        ),
                      if (onDeleteGroup != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDeleteGroup!(group),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
