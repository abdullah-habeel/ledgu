import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class WalletSection extends StatelessWidget {
  final double willReceive;
  final double willPay;

  const WalletSection({
    super.key,
    this.willReceive = 0,
    this.willPay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildContainer(context, "Will Receive", willReceive, Colors.green),
        _buildContainer(context, "Will Pay", willPay, Colors.red),
      ],
    );
  }

  Widget _buildContainer(
      BuildContext context, String title, double amount, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          MyText(
            text: title,
            color: Colors.white,
            fontSize: 14,
          ),
          const SizedBox(height: 8),
          MyText(
            text: amount.toStringAsFixed(2),
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
