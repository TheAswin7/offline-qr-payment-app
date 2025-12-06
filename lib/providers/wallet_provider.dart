import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class WalletProvider extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _api;
  Wallet? _wallet;
  bool _isLoading = false;
  String? _error;

  WalletProvider(StorageService storage)
      : _storage = storage,
        _api = ApiService() {
    _loadWallet();
  }

  Wallet? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadWallet() {
    _wallet = _storage.getWallet();
    notifyListeners();
  }

  Future<void> loadWallet(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final wallet = await _api.getWallet(userId);
      if (wallet != null) {
        _wallet = wallet;
        await _storage.saveWallet(wallet);
      } else {
        // Use stored wallet or create default
        _wallet = _storage.getWallet();
        if (_wallet == null) {
          _wallet = Wallet(
            userId: userId,
            offlineBalance: '0.00',
            onlineBalance: '0.00',
            offlineLimit: '10000.00',
            lastUpdated: DateTime.now(),
          );
          await _storage.saveWallet(_wallet!);
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _wallet = _storage.getWallet();
      notifyListeners();
    }
  }

  void updateWallet(Wallet wallet) {
    _wallet = wallet;
    _storage.saveWallet(wallet);
    notifyListeners();
  }

  void refreshWallet() {
    _loadWallet();
  }
}

