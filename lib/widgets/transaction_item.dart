import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({
    super.key,
    required this.transaction,
  });

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.synced:
        return Colors.green;
      case TransactionStatus.pendingSync:
        return Colors.orange;
      case TransactionStatus.offlineConfirmed:
        return Colors.blue;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.synced:
        return 'Synced';
      case TransactionStatus.pendingSync:
        return 'Pending';
      case TransactionStatus.offlineConfirmed:
        return 'Offline';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    return type == TransactionType.sent
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }

  Color _getTypeColor(TransactionType type) {
    return type == TransactionType.sent ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(transaction.type).withOpacity(0.2),
          child: Icon(
            _getTypeIcon(transaction.type),
            color: _getTypeColor(transaction.type),
          ),
        ),
        title: Text(
          transaction.counterpartyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} ${transaction.timestamp.hour}:${transaction.timestamp.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == TransactionType.sent ? '-' : '+'}₹${transaction.amount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(transaction.type),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(transaction.status),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(transaction.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





