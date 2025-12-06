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


