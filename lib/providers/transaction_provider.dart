import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

class TransactionProvider with ChangeNotifier {
  final StorageService _storage;
  final ApiService _api;
  final SyncService _syncService;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider(StorageService storage)
      : _storage = storage,
        _api = ApiService(),
        _syncService = SyncService(storage, ApiService()) {
    _loadTransactions();
  }

  List<Transaction> get transactions => _transactions;
  List<Transaction> get pendingTransactions => _transactions
      .where((t) => t.status == TransactionStatus.pendingSync)
      .toList();
  List<Transaction> get completedTransactions => _transactions
      .where((t) => t.status == TransactionStatus.synced)
      .toList();
  List<Transaction> get recentTransactions => _transactions.take(5).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadTransactions() {
    _transactions = _storage.getTransactions();
    notifyListeners();
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transactions = await _api.getTransactions(userId);
      _transactions = transactions;
      await _storage.saveTransactions(transactions);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _transactions = _storage.getTransactions();
      notifyListeners();
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _storage.addTransaction(transaction);
    notifyListeners();
  }

  void updateTransaction(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _storage.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> syncAllPending() async {
    await _syncService.syncAllPending();
    _loadTransactions();
  }

  void refreshTransactions() {
    _loadTransactions();
  }
}





