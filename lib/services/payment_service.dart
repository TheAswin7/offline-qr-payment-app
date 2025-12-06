import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'storage_service.dart';
import 'sync_service.dart';

class PaymentService {
  final StorageService _storage;
  final SyncService _syncService;
  final Uuid _uuid = const Uuid();

  PaymentService(this._storage, this._syncService);

  Future<Map<String, dynamic>> processPayment({
    required String amount,
    required User merchant,
    required String userId,
  }) async {
    try {
      // Check wallet balance
      final wallet = _storage.getWallet();
      if (wallet == null) {
        return {'success': false, 'error': 'Wallet not found'};
      }

      final currentBalance = double.parse(wallet.offlineBalance);
      final paymentAmount = double.parse(amount);

      if (paymentAmount > currentBalance) {
        return {'success': false, 'error': 'Insufficient balance'};
      }

      // Create transaction
      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        counterpartyId: merchant.id,
        counterpartyName: merchant.name,
        timestamp: DateTime.now(),
        status: TransactionStatus.offlineConfirmed,
        type: TransactionType.sent,
        merchantId: merchant.merchantId,
      );

      // Update wallet
      final newBalance = (currentBalance - paymentAmount).toStringAsFixed(2);
      final updatedWallet = wallet.copyWith(
        offlineBalance: newBalance,
        lastUpdated: DateTime.now(),
      );

      // Save transaction and wallet
      await _storage.addTransaction(transaction);
      await _storage.saveWallet(updatedWallet);

      // Try to sync in background
      _syncService.syncTransaction(transaction);

      return {
        'success': true,
        'transaction': transaction,
        'wallet': updatedWallet,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> receivePayment({
    required String amount,
    required User payer,
    required String merchantId,
  }) async {
    try {
      final wallet = _storage.getWallet();
      if (wallet == null) {
        return {'success': false, 'error': 'Wallet not found'};
      }

      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        counterpartyId: payer.id,
        counterpartyName: payer.name,
        timestamp: DateTime.now(),
        status: TransactionStatus.offlineConfirmed,
        type: TransactionType.received,
        merchantId: merchantId,
      );

      final currentBalance = double.parse(wallet.offlineBalance);
      final paymentAmount = double.parse(amount);
      final newBalance = (currentBalance + paymentAmount).toStringAsFixed(2);

      final updatedWallet = wallet.copyWith(
        offlineBalance: newBalance,
        lastUpdated: DateTime.now(),
      );

      await _storage.addTransaction(transaction);
      await _storage.saveWallet(updatedWallet);

      _syncService.syncTransaction(transaction);

      return {
        'success': true,
        'transaction': transaction,
        'wallet': updatedWallet,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}


