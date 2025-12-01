import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/amount_container.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';

class WalletSection extends StatelessWidget {
  const WalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: "My Wallet",
          color: AppColors.grey1,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        GapBox(15),
        Row(
          children: [
            Expanded(
              child: AmountContainer(
                topText: "15,000",
                bottomText: "Will Received",
                containerColor: AppColors.blue1,
                topTextColor: AppColors.green,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: AmountContainer(
                topText: "20,000",
                bottomText: "Will Paid",
                containerColor: AppColors.blue1,
                topTextColor: AppColors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
