import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/dashboard_controller.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/screens_widgets/info_section.dart';
import 'package:ledgu/widgets/screens_widgets/transaction_section.dart';
import 'package:ledgu/widgets/screens_widgets/wallet_section.dart';
import 'package:ledgu/widgets/text.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = DashboardController();

  List<Map<String, dynamic>> friends = [];
  int totalFriends = 0;
  int totalGroups = 0;

  @override
  void initState() {
    super.initState();
    loadFriends();
    loadGroups();
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

  @override
  Widget build(BuildContext context) {
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
            /// Wallet Section
            WalletSection(),

            const SizedBox(height: 15),

            /// Info section
            InfoSection(
              totalFriends: totalFriends,
              totalGroups: totalGroups,
            ),

            const SizedBox(height: 15),

            /// Transactions section
            Expanded(
              child: TransactionsSection(
                friends: friends,
                groupsStream: controller.getUserGroups(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
