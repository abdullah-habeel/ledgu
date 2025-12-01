import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class TransactionTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String date;

  const TransactionTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: MyText(text: title, color: Colors.white),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(text: subtitle, color: AppColors.grey1, fontSize: 12),
            MyText(text: "Amount: $amount", color: AppColors.grey1, fontSize: 12),
            MyText(text: "Date: $date", color: AppColors.grey1, fontSize: 12),
          ],
        ),
      ),
    );
  }
}
