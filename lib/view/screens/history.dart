import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TransactionController txController = TransactionController();
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    // Listen to all transactions
    txController.getAllTransactionsStream().listen((txList) {
      setState(() {
        transactions = txList;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        centerTitle: true,
        title: const MyText(
          text: "Transaction History",
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(
                  child: MyText(text: "No transactions found", color: AppColors.green))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (_, index) {
                    final tx = transactions[index];
                    final from = tx['fromName'] ?? tx['from'];
                    final to = tx['toName'] ??
                        (tx['toList'] != null
                            ? (tx['toList'] as List).join(", ")
                            : tx['to']);
                    final amount = tx['amount'] ?? 0;
                    final time = tx['time'] != null
                        ? (tx['time'] as DateTime).toLocal().toString()
                        : "";

                    return Card(
                      color: AppColors.black2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: MyText(
                            text: "$from → $to", color: Colors.white, fontSize: 14),
                        subtitle: MyText(text: "Time: $time", color: Colors.grey, fontSize: 12),
                        trailing: MyText(
                          text: "₨ $amount",
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
