import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class FriendListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final void Function(Map<String, dynamic>) onSendMoney;
  final void Function(Map<String, dynamic>) onViewTransaction;

  const FriendListWidget({
    super.key,
    required this.friends,
    required this.onSendMoney,
    required this.onViewTransaction,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(
        child: MyText(text: "No friends yet", color: AppColors.grey1),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () => onViewTransaction(f),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_money, color: Colors.green),
                    onPressed: () => onSendMoney(f),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
