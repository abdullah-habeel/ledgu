import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendMoneySplitSheet extends StatefulWidget {
  final Map<String, dynamic> group;
  final TransactionController txController;

  const SendMoneySplitSheet({
    super.key,
    required this.group,
    required this.txController,
  });

  @override
  State<SendMoneySplitSheet> createState() => _SendMoneySplitSheetState();
}

class _SendMoneySplitSheetState extends State<SendMoneySplitSheet> {
  final TextEditingController _amountController = TextEditingController();

  final Map<String, bool> _selectedMembers = {};
  Map<String, double> _memberAmounts = {};
  final Map<String, String> _memberNames = {}; // UID → fullName
  double totalAmount = 0;
  bool loadingNames = true;

  @override
  void initState() {
    super.initState();
    _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    final memberUids = List<String>.from(widget.group['members'] ?? []);

    for (String uid in memberUids) {
      final name = await widget.txController.getUserName(uid);
      _memberNames[uid] = name;
      _selectedMembers[uid] = true; // select all by default
    }

    setState(() => loadingNames = false);
    _updateAmounts();
  }

  void _updateAmounts() {
    final selected = _selectedMembers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selected.isEmpty || totalAmount == 0) {
      _memberAmounts = {};
      return;
    }

    final split = totalAmount / selected.length;
    _memberAmounts = {for (var m in selected) m: split};
  }

  void _onAmountChanged(String value) {
    totalAmount = double.tryParse(value) ?? 0;
    setState(_updateAmounts);
  }

  void _onMemberToggled(String member, bool? value) {
    _selectedMembers[member] = value ?? false;
    setState(_updateAmounts);
  }

  void _sendMoney() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await widget.txController.addTransaction(
      from: currentUser.uid,
      amount: totalAmount,
      time: DateTime.now(),
      groupId: widget.group['id'],
      toList: _memberAmounts.keys.toList(),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Money sent successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingNames) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final memberUids = _selectedMembers.keys.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: _onAmountChanged,
            decoration: const InputDecoration(prefixText: "\$ "),
          ),
          const SizedBox(height: 16),
          const Text("Split among members", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: memberUids.length,
              itemBuilder: (_, index) {
                final uid = memberUids[index];
                return CheckboxListTile(
                  value: _selectedMembers[uid],
                  title: Text(_memberNames[uid] ?? "Unknown"),
                  subtitle: Text(
                    "\$${_memberAmounts[uid]?.toStringAsFixed(2) ?? "0"}",
                  ),
                  onChanged: (val) => _onMemberToggled(uid, val),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _memberAmounts.isNotEmpty ? _sendMoney : null,
            child: const Text("Send Money"),
          ),
        ],
      ),
    );
  }
}
