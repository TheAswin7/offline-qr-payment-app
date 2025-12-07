import '../models/user.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

class MockData {
  static User getMockUser(String phoneNumber) {
    return User(
      id: 'user_${phoneNumber.substring(phoneNumber.length - 4)}',
      phoneNumber: phoneNumber,
      name: 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
      merchantId: 'merchant_${phoneNumber.substring(phoneNumber.length - 4)}',
      shopName: 'Shop ${phoneNumber.substring(phoneNumber.length - 4)}',
      isMerchant: true,
    );
  }

  static Wallet getMockWallet(String userId) {
    return Wallet(
      userId: userId,
      offlineBalance: '5000.00',
      onlineBalance: '25000.00',
      offlineLimit: '10000.00',
      lastUpdated: DateTime.now(),
    );
  }

  static List<Transaction> getMockTransactions(String userId) {
    return [
      Transaction(
        id: 'txn_001',
        amount: '250.00',
        counterpartyId: 'merchant_1234',
        counterpartyName: 'Shop ABC',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransactionStatus.synced,
        type: TransactionType.sent,
      ),
      Transaction(
        id: 'txn_002',
        amount: '500.00',
        counterpartyId: 'user_5678',
        counterpartyName: 'Customer XYZ',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: TransactionStatus.synced,
        type: TransactionType.received,
      ),
      Transaction(
        id: 'txn_003',
        amount: '150.00',
        counterpartyId: 'merchant_9012',
        counterpartyName: 'Shop DEF',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: TransactionStatus.pendingSync,
        type: TransactionType.sent,
      ),
    ];
  }

  static User getMockMerchant(String merchantId) {
    return User(
      id: 'merchant_$merchantId',
      phoneNumber: '+91${merchantId.substring(merchantId.length - 10)}',
      name: 'Merchant $merchantId',
      merchantId: merchantId,
      shopName: 'Shop $merchantId',
      isMerchant: true,
    );
  }
}





