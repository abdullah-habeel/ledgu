import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class InfoSection extends StatelessWidget {
  final int totalFriends;
  final int totalGroups;
  final int pending;
  final int toPay;

  const InfoSection({
    super.key,
    required this.totalFriends,
    required this.totalGroups,
    this.pending = 0,
    this.toPay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Subtract some spacing for small gaps, then divide by 4
    final containerWidth = (screenWidth - 32) / 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildContainer("Friends", totalFriends, Colors.blue, containerWidth),
        _buildContainer("Groups", totalGroups, Colors.orange, containerWidth),
        _buildContainer("Pending", pending, Colors.green, containerWidth),
        _buildContainer("To Pay", toPay, Colors.red, containerWidth),
      ],
    );
  }

  Widget _buildContainer(
      String title, int count, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          MyText(
            text: count.toString(),
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
