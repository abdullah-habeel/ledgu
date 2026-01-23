import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TransactionController txController = TransactionController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> transactions = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  final int batchSize = 20;

  @override
  void initState() {
    super.initState();

    // Scroll listener to load more
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoadingMore &&
          hasMore) {
        loadMoreTransactions();
      }
    });
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMore) return;

    setState(() => isLoadingMore = true);

    final txList = await txController.getAllTransactionsPaginated(
        startAfter: lastDoc, limit: batchSize);

    if (txList.length < batchSize) hasMore = false;
    if (txList.isNotEmpty) lastDoc = txList.last['docSnapshot'];

    setState(() {
      transactions.addAll(txList.map(formatTransaction).toList());
      isLoadingMore = false;
    });
  }

  Map<String, dynamic> formatTransaction(Map<String, dynamic> tx) {
    DateTime? time;
    if (tx['time'] != null) {
      if (tx['time'] is Timestamp) {
        time = (tx['time'] as Timestamp).toDate();
      } else if (tx['time'] is DateTime) {
        time = tx['time'] as DateTime;
      }
    }
    return {
      ...tx,
      'formattedTime': time != null ? time.toLocal().toString() : "",
    };
  }

  /// Initial fetch for first batch
  Future<void> loadInitialTransactions() async {
    final txList =
        await txController.getAllTransactionsPaginated(limit: batchSize);

    if (txList.length < batchSize) hasMore = false;
    if (txList.isNotEmpty) lastDoc = txList.last['docSnapshot'];

    setState(() {
      transactions = txList.map(formatTransaction).toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (transactions.isEmpty) loadInitialTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index >= transactions.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tx = transactions[index];
                final from = tx['fromName'] ?? tx['from'];
                final to = tx['toName'] ??
                    (tx['toList'] != null
                        ? (tx['toList'] as List).join(", ")
                        : tx['to']);
                final amount = tx['amount'] ?? 0;
                final time = tx['formattedTime'] ?? "";

                return Card(
                  color: AppColors.black2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: MyText(
                        text: "$from → $to",
                        color: Colors.white,
                        fontSize: 14),
                    subtitle:
                        MyText(text: "Time: $time", color: Colors.grey, fontSize: 12),
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
