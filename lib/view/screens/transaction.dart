import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/screens_widgets/transaction_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionPage extends StatefulWidget {
  final String id; // friend UID or groupId
  final String name;
  final bool isGroup;

  const TransactionPage({
    super.key,
    required this.id,
    required this.name,
    this.isGroup = false,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionController controller = TransactionController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  final int batchSize = 20;
  bool historyMode = false; // true when user clicks history icon

  @override
  void initState() {
    super.initState();
    loadTransactions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoadingMore &&
          hasMore) {
        loadMoreTransactions();
      }
    });
  }

  Future<void> loadTransactions() async {
    setState(() => isLoading = true);

    List<Map<String, dynamic>> txList;

    if (historyMode) {
      if (widget.isGroup) {
        // Group history
        txList = await controller.getGroupTransactionsPaginated(
            groupId: widget.id, limit: batchSize);
      } else {
        // Friend history
        txList = await controller.getFriendTransactionsPaginated(
            friendUid: widget.id, limit: batchSize);
      }
    } else {
      if (widget.isGroup) {
        txList = await controller.getGroupTransactionsPaginated(
            groupId: widget.id, limit: batchSize);
      } else {
        txList = await controller.getFriendTransactionsPaginated(
            friendUid: widget.id, limit: batchSize);
      }
    }

    if (txList.length < batchSize) hasMore = false;
    if (txList.isNotEmpty) lastDoc = txList.last['docSnapshot'];

    setState(() {
      transactions = txList;
      isLoading = false;
    });
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMore) return;
    setState(() => isLoadingMore = true);

    List<Map<String, dynamic>> txList;

    if (historyMode) {
      if (widget.isGroup) {
        txList = await controller.getGroupTransactionsPaginated(
            groupId: widget.id, startAfter: lastDoc, limit: batchSize);
      } else {
        txList = await controller.getFriendTransactionsPaginated(
            friendUid: widget.id, startAfter: lastDoc, limit: batchSize);
      }
    } else {
      if (widget.isGroup) {
        txList = await controller.getGroupTransactionsPaginated(
            groupId: widget.id, startAfter: lastDoc, limit: batchSize);
      } else {
        txList = await controller.getFriendTransactionsPaginated(
            friendUid: widget.id, startAfter: lastDoc, limit: batchSize);
      }
    }

    if (txList.length < batchSize) hasMore = false;
    if (txList.isNotEmpty) lastDoc = txList.last['docSnapshot'];

    setState(() {
      transactions.addAll(txList);
      isLoadingMore = false;
    });
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return "";
    if (ts is Timestamp) return ts.toDate().toLocal().toString();
    if (ts is DateTime) return ts.toLocal().toString();
    return ts.toString();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openHistory() {
    historyMode = true;
    lastDoc = null;
    hasMore = true;
    loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(historyMode
            ? "${widget.isGroup ? 'Group' : 'Friend'} History"
            : "${widget.name} Transactions"),
        centerTitle: true,
       
      ),
      backgroundColor: AppColors.black1,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("No transactions yet"))
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
                    final time = _formatTimestamp(tx['time']);

                    return TransactionTileWidget(
                      title: widget.isGroup ? "Group Transaction" : "Transaction",
                      subtitle: "$from → $to",
                      amount: amount.toString(),
                      date: time,
                    );
                  },
                ),
    );
  }
}
