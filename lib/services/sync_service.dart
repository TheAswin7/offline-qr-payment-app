import '../models/transaction.dart';
import 'storage_service.dart';
import 'api_service.dart';

class SyncService {
  final StorageService _storage;
  final ApiService _api;

  SyncService(this._storage, this._api);

  Future<void> syncTransaction(Transaction transaction) async {
    if (transaction.status == TransactionStatus.synced) {
      return;
    }

    final success = await _api.syncTransaction(transaction);
    if (success) {
      // Update transaction status
      final transactions = _storage.getTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        transactions[index] = transaction.copyWith(
          status: TransactionStatus.synced,
        );
        await _storage.saveTransactions(transactions);
      }
    } else {
      // Mark as pending sync
      final transactions = _storage.getTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1 && transactions[index].status != TransactionStatus.pendingSync) {
        transactions[index] = transaction.copyWith(
          status: TransactionStatus.pendingSync,
        );
        await _storage.saveTransactions(transactions);
      }
    }
  }

  Future<void> syncAllPending() async {
    final transactions = _storage.getTransactions();
    final pending = transactions.where(
      (t) => t.status == TransactionStatus.pendingSync,
    ).toList();

    for (final transaction in pending) {
      await syncTransaction(transaction);
    }
  }
}





