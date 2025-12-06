import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import '../utils/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.user != null) {
      await Future.wait([
        walletProvider.loadWallet(authProvider.user!.id),
        transactionProvider.loadTransactions(authProvider.user!.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Balance Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<WalletProvider>(
                  builder: (context, walletProvider, child) {
                    if (walletProvider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final wallet = walletProvider.wallet;
                    if (wallet == null) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('Wallet not found'),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        BalanceCard(
                          title: 'Online Bank Balance',
                          amount: wallet.onlineBalance,
                          color: Colors.blue,
                          icon: Icons.account_balance,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 12),
                        BalanceCard(
                          title: 'Offline Wallet Balance',
                          amount: wallet.offlineBalance,
                          color: Colors.green,
                          icon: Icons.wallet,
                          isReadOnly: false,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.scan);
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan & Pay'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.myQr);
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('My QR'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.transactions);
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Recent Transactions List
              Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  final recentTransactions =
                      transactionProvider.recentTransactions;
                  if (recentTransactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: recentTransactions
                        .map((txn) => TransactionItem(transaction: txn))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

