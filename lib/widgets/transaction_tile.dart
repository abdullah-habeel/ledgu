import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final int amount;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = amount > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${amount.abs()}",
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        Divider(thickness: 0.5, color: AppColors.grey1),
      ],
    );
  }
}
