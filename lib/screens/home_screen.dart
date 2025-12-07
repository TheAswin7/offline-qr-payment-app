import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/responsive_utils.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/loading_overlay.dart';
import 'scan_pay/scan_screen.dart';
import 'my_qr_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider =
        Provider.of<WalletProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.user != null) {
      walletProvider.loadWallet(authProvider.user!.id);
      transactionProvider.loadTransactions(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline QR Payments'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: walletProvider.isLoading || transactionProvider.isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              walletProvider.refreshWallet();
              transactionProvider.refreshTransactions();
              _loadData();
            },
            child: ListView(
              padding: ResponsiveUtils.getResponsivePadding(context, left: 16, top: 8, right: 16, bottom: 16),
              children: [
                // User greeting
                if (authProvider.user != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          authProvider.user!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Balance Cards
                if (walletProvider.wallet != null) ...[
                  BalanceCard(
                    title: 'Offline Balance',
                    amount: walletProvider.wallet!.offlineBalance,
                    color: Colors.blue,
                    icon: Icons.wallet,
                  ),
                  const SizedBox(height: 12),
                  BalanceCard(
                    title: 'Online Balance',
                    amount: walletProvider.wallet!.onlineBalance,
                    color: Colors.green,
                    icon: Icons.account_balance,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Pay Now',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanScreen(),
                        ),
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.qr_code,
                      label: 'My QR Code',
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyQrScreen(),
                        ),
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.history,
                      label: 'Transactions',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsScreen(),
                        ),
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.receipt,
                      label: 'Sync Status',
                      color: Colors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pending: ${transactionProvider.pendingTransactions.length}',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Transactions
                if (transactionProvider.recentTransactions.isNotEmpty) ...[
                  Row(
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsScreen(),
                          ),
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...transactionProvider.recentTransactions
                      .map((txn) => TransactionItem(transaction: txn)),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
