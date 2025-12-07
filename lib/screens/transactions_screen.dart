// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/transaction_provider.dart';
// import '../providers/auth_provider.dart';
// import '../widgets/transaction_item.dart';

// class TransactionsScreen extends StatefulWidget {
//   const TransactionsScreen({super.key});

//   @override
//   State<TransactionsScreen> createState() => _TransactionsScreenState();
// }

// class _TransactionsScreenState extends State<TransactionsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadTransactions();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadTransactions() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final transactionProvider =
//         Provider.of<TransactionProvider>(context, listen: false);

//     if (authProvider.user != null) {
//       await transactionProvider.loadTransactions(authProvider.user!.id);
//     }
//   }

//   Future<void> _syncPending() async {
//     final transactionProvider =
//         Provider.of<TransactionProvider>(context, listen: false);
//     await transactionProvider.syncAllPending();

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Sync completed')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Transactions'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Pending Sync'),
//             Tab(text: 'Completed'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: _syncPending,
//             tooltip: 'Sync Pending',
//           ),
//         ],
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildPendingTab(),
//           _buildCompletedTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPendingTab() {
//     return Consumer<TransactionProvider>(
//       builder: (context, transactionProvider, child) {
//         final pending = transactionProvider.pendingTransactions;

//         if (transactionProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (pending.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.check_circle_outline,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No pending transactions',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: _loadTransactions,
//           child: ListView.builder(
//             itemCount: pending.length,
//             itemBuilder: (context, index) {
//               return TransactionItem(transaction: pending[index]);
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCompletedTab() {
//     return Consumer<TransactionProvider>(
//       builder: (context, transactionProvider, child) {
//         final completed = transactionProvider.completedTransactions;

//         if (transactionProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (completed.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.receipt_long_outlined,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No completed transactions',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: _loadTransactions,
//           child: ListView.builder(
//             itemCount: completed.length,
//             itemBuilder: (context, index) {
//               return TransactionItem(transaction: completed[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';
import '../widgets/loading_overlay.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all'; // all, sent, received, pending

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    List<Transaction> displayedTransactions = transactionProvider.transactions;

    switch (_filter) {
      case 'sent':
        displayedTransactions = displayedTransactions
            .where((t) => t.type == TransactionType.sent)
            .toList();
        break;
      case 'received':
        displayedTransactions = displayedTransactions
            .where((t) => t.type == TransactionType.received)
            .toList();
        break;
      case 'pending':
        displayedTransactions = transactionProvider.pendingTransactions;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: transactionProvider.isLoading,
        child: Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == 'all',
                    onSelected: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Sent',
                    selected: _filter == 'sent',
                    onSelected: () => setState(() => _filter = 'sent'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Received',
                    selected: _filter == 'received',
                    onSelected: () => setState(() => _filter = 'received'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    selected: _filter == 'pending',
                    onSelected: () => setState(() => _filter = 'pending'),
                  ),
                ],
              ),
            ),

            // Transactions List
            if (displayedTransactions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    transactionProvider.refreshTransactions();
                  },
                  child: ListView.builder(
                    itemCount: displayedTransactions.length,
                    itemBuilder: (context, index) {
                      return TransactionItem(
                        transaction: displayedTransactions[index],
                      );
                    },
                  ),
                ),
              ),

            // Sync Status
            if (transactionProvider.pendingTransactions.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pending Transactions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${transactionProvider.pendingTransactions.length} transaction(s) waiting to sync',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await transactionProvider.syncAllPending();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transactions synced'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}





