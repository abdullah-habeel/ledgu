import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/dashboard_controller.dart';
import 'package:ledgu/controller/screens_controller/transaction_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/screens_widgets/info_section.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/widgets/text_button.dart';
import 'package:ledgu/widgets/wallet_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = DashboardController();
  final TransactionController txController = TransactionController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> friends = [];
  int totalFriends = 0;
  int totalGroups = 0;

  double willReceive = 0;
  double willPay = 0;

  int pending = 0;
  int toPay = 0;

  bool showAllTransactions = false;

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  final int batchSize = 20;

  @override
  void initState() {
    super.initState();
    loadDashboardData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoadingMore &&
          hasMore &&
          showAllTransactions) {
        loadMoreTransactions();
      }
    });
  }

  Future<void> loadDashboardData() async {
    await loadFriends();
    loadGroups(); // Do NOT await
    await loadTotals();
    await loadTransactions();
  }

  Future<void> loadFriends() async {
    final list = await controller.getFriends();
    setState(() {
      friends = list;
      totalFriends = list.length;
    });
  }

  void loadGroups() {
    controller.getUserGroups().listen((snapshot) {
      setState(() => totalGroups = snapshot.docs.length);
    });
  }

  Future<void> loadTotals() async {
    final totals = await controller.getDashboardTotals();
    final counts = await controller.getPendingAndToPay();

    setState(() {
      willReceive = totals['willReceive'] ?? 0;
      willPay = totals['willPay'] ?? 0;
      pending = counts['pending'] ?? 0;
      toPay = counts['toPay'] ?? 0;
    });
  }

  Future<void> loadTransactions() async {
    setState(() => isLoading = true);

    final txList =
        await txController.getAllTransactionsPaginated(limit: batchSize);

    if (txList.length < batchSize) hasMore = false;
    if (txList.isNotEmpty) lastDoc = txList.last['docSnapshot'];

    setState(() {
      transactions = txList.map(formatTransaction).toList();
      isLoading = false;
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

  void toggleTransactionView() {
    setState(() {
      showAllTransactions = !showAllTransactions;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTransactions = showAllTransactions
        ? transactions
        : transactions.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.black1,
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        centerTitle: true,
        title: MyText(
          text: "Dashboard",
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Wallet Section
            WalletSection(
              willReceive: willReceive,
              willPay: willPay,
            ),

            const SizedBox(height: 15),

            // Info Section
            InfoSection(
              totalFriends: totalFriends,
              totalGroups: totalGroups,
              pending: pending,
              toPay: toPay,
            ),

            const SizedBox(height: 15),

            // Transactions Header
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: MyText(
                text: "Transactions",
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 17,
              ),
              trailing: MyTextButton(
                text: showAllTransactions ? 'Show Less' : 'See All',
                textColor: AppColors.blue2,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                onPressed: toggleTransactionView,
              ),
            ),

            // Transactions List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedTransactions.isEmpty
                      ? const Center(
                          child: MyText(
                              text: "No transactions found",
                              color: AppColors.green))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: displayedTransactions.length +
                              (isLoadingMore ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index >= displayedTransactions.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final tx = displayedTransactions[index];
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
                                subtitle: MyText(
                                    text: "Time: $time",
                                    color: Colors.grey,
                                    fontSize: 12),
                                trailing: MyText(
                                  text: "₨ $amount",
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
