import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class SendMoneySheet extends StatefulWidget {
  final Map<String, dynamic> userOrGroup;
  final bool isGroup;
  final TransactionController txController;

  const SendMoneySheet({
    super.key,
    required this.userOrGroup,
    required this.isGroup,
    required this.txController,
  });

  @override
  State<SendMoneySheet> createState() => _SendMoneySheetState();
}

class _SendMoneySheetState extends State<SendMoneySheet> {
  final TextEditingController _amountController = TextEditingController();

  void sendMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    final fromUid = widget.txController.currentUserId!;
    final groupId = widget.isGroup ? widget.userOrGroup['id'] : null;
    final toUid = widget.isGroup ? null : widget.userOrGroup['uid'];
    final toList = widget.isGroup
        ? (widget.userOrGroup['members'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList()
        : null;

    await widget.txController.addTransaction(
      from: fromUid,
      to: toUid ?? "",
      amount: amount,
      time: DateTime.now(),
      groupId: groupId,
      toList: toList,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Money sent successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            text: widget.isGroup
                ? "Send Money to Group"
                : "Send Money to ${widget.userOrGroup['fullName'] ?? 'User'}",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter amount",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: sendMoney,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
            ),
            child: const Text("Send"),
          )
        ],
      ),
    );
  }
}
