import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/transaction_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.user != null) {
      await transactionProvider.loadTransactions(authProvider.user!.id);
    }
  }

  Future<void> _syncPending() async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    await transactionProvider.syncAllPending();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Sync'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncPending,
            tooltip: 'Sync Pending',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final pending = transactionProvider.pendingTransactions;

        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending transactions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadTransactions,
          child: ListView.builder(
            itemCount: pending.length,
            itemBuilder: (context, index) {
              return TransactionItem(transaction: pending[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final completed = transactionProvider.completedTransactions;

        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (completed.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed transactions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadTransactions,
          child: ListView.builder(
            itemCount: completed.length,
            itemBuilder: (context, index) {
              return TransactionItem(transaction: completed[index]);
            },
          ),
        );
      },
    );
  }
}


