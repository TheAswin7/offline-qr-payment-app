import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final StorageService _storage;
  final ApiService _api;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthService(this._storage, this._api);

  Future<bool> isAuthenticated() async {
    return _storage.getUser() != null && _storage.getPin() != null;
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    return await _api.sendOtp(phoneNumber);
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final result = await _api.verifyOtp(phoneNumber, otp);
    if (result['success'] == true && result['user'] != null) {
      final user = User.fromJson(result['user']);
      await _storage.saveUser(user);
      return {'success': true, 'user': user};
    }
    return result;
  }

  Future<void> setPin(String pin) async {
    // Hash the PIN before storing
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    await _storage.savePin(hash.toString());
    await _storage.setOnboarded(true);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = _storage.getPin();
    if (storedPin == null) return false;
    
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return storedPin == hash.toString();
  }

  Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to complete payment',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearUser();
    await _storage.setOnboarded(false);
  }
}


