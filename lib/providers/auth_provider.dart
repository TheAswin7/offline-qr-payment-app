import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storage;
  StorageService get storage => _storage;
  late final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(StorageService storage)
      : _storage = storage {
    _authService = AuthService(_storage, ApiService());
    _loadUser();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _loadUser() {
    _user = _storage.getUser();
    notifyListeners();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.sendOtp(phoneNumber);
      _isLoading = false;
      
      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(phoneNumber, otp);
      _isLoading = false;
      
      if (result['success'] == true && result['user'] != null) {
        _user = result['user'] as User;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.setPin(pin);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    return await _authService.verifyPin(pin);
  }

  Future<bool> authenticateWithBiometric() async {
    return await _authService.authenticateWithBiometric();
  }

  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


