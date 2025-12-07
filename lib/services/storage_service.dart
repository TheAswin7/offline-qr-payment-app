import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // User
  Future<void> saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  User? getUser() {
    final userJson = _prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // PIN
  Future<void> savePin(String pin) async {
    await _prefs.setString('wallet_pin', pin);
  }

  String? getPin() {
    return _prefs.getString('wallet_pin');
  }

  // Wallet
  Future<void> saveWallet(Wallet wallet) async {
    await _prefs.setString('wallet', jsonEncode(wallet.toJson()));
  }

  Wallet? getWallet() {
    final walletJson = _prefs.getString('wallet');
    if (walletJson == null) return null;
    return Wallet.fromJson(jsonDecode(walletJson));
  }

  // Transactions
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await _prefs.setString('transactions', jsonEncode(transactionsJson));
  }

  List<Transaction> getTransactions() {
    final transactionsJson = _prefs.getString('transactions');
    if (transactionsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  // Merchant Wallets (for offline QR payments)
  Future<void> saveMerchantWallet(String merchantId, Wallet wallet) async {
    await _prefs.setString('merchant_wallet_$merchantId', jsonEncode(wallet.toJson()));
  }

  Wallet? getMerchantWallet(String merchantId) {
    final walletJson = _prefs.getString('merchant_wallet_$merchantId');
    if (walletJson == null) {
      // Create default merchant wallet if it doesn't exist
      final defaultWallet = Wallet(
        userId: merchantId,
        offlineBalance: '0.00',
        onlineBalance: '0.00',
        offlineLimit: '10000.00',
        lastUpdated: DateTime.now(),
      );
      saveMerchantWallet(merchantId, defaultWallet);
      return defaultWallet;
    }
    return Wallet.fromJson(jsonDecode(walletJson));
  }

  Future<void> updateMerchantWallet(String merchantId, Wallet wallet) async {
    await _prefs.setString('merchant_wallet_$merchantId', jsonEncode(wallet.toJson()));
  }

  // Add merchant transaction
  Future<void> addMerchantTransaction(String merchantId, Transaction transaction) async {
    final key = 'merchant_transactions_$merchantId';
    final transactionsJson = _prefs.getString(key);
    List<Transaction> transactions = [];

    if (transactionsJson != null) {
      final List<dynamic> decoded = jsonDecode(transactionsJson);
      transactions = decoded.map((json) => Transaction.fromJson(json)).toList();
    }

    transactions.insert(0, transaction); // Add to beginning
    final transactionsJsonNew = transactions.map((t) => t.toJson()).toList();
    await _prefs.setString(key, jsonEncode(transactionsJsonNew));
  }

  List<Transaction> getMerchantTransactions(String merchantId) {
    final key = 'merchant_transactions_$merchantId';
    final transactionsJson = _prefs.getString(key);
    if (transactionsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((json) => Transaction.fromJson(json)).toList();
  }

  // Biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool('biometric_enabled', enabled);
  }

  bool isBiometricEnabled() {
    return _prefs.getBool('biometric_enabled') ?? false;
  }

  // Language
  Future<void> setLanguage(String language) async {
    await _prefs.setString('language', language);
  }

  String getLanguage() {
    return _prefs.getString('language') ?? 'en';
  }

  // Is Onboarded
  Future<void> setOnboarded(bool onboarded) async {
    await _prefs.setBool('onboarded', onboarded);
  }

  bool isOnboarded() {
    return _prefs.getBool('onboarded') ?? false;
  }
}
