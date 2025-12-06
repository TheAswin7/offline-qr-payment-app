import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import '../services/sync_service.dart';

class PaymentProvider with ChangeNotifier {
  final StorageService _storage;
  late final PaymentService _paymentService;
  Transaction? _currentTransaction;
  User? _selectedMerchant;
  String _amount = '0.00';
  bool _isProcessing = false;
  String? _error;

  PaymentProvider(StorageService storage)
      : _storage = storage {
    _paymentService = PaymentService(
      _storage,
      SyncService(_storage, ApiService()),
    );
  }

  Transaction? get currentTransaction => _currentTransaction;
  User? get selectedMerchant => _selectedMerchant;
  String get amount => _amount;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  void setMerchant(User merchant) {
    _selectedMerchant = merchant;
    notifyListeners();
  }

  void setAmount(String amount) {
    _amount = amount;
    notifyListeners();
  }

  Future<Map<String, dynamic>> processPayment({
    required String amount,
    required User merchant,
    required String userId,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.processPayment(
        amount: amount,
        merchant: merchant,
        userId: userId,
      );

      _isProcessing = false;

      if (result['success'] == true) {
        _currentTransaction = result['transaction'] as Transaction;
        notifyListeners();
        return result;
      } else {
        _error = result['error'] ?? 'Payment failed';
        notifyListeners();
        return result;
      }
    } catch (e) {
      _isProcessing = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  void reset() {
    _currentTransaction = null;
    _selectedMerchant = null;
    _amount = '0.00';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


