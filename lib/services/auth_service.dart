import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'storage_service.dart';
import '../models/user.dart' as user_model;

class AuthService {
  final StorageService _storage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // TEMPORARY TEST MODE FOR SMS ISSUES
  final bool _testMode = true; // Set to false to use real Firebase SMS

  AuthService(this._storage);

  Future<bool> isAuthenticated() async {
    return _storage.getUser() != null && _storage.getPin() != null;
  }

  String? _verificationId;

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    // TEST MODE: Skip Firebase and use demo OTP
    if (_testMode) {
      print('🧪 TEST MODE: Using demo OTP instead of SMS');
      _verificationId = 'test_verification_id';
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'TEST MODE: Demo OTP ready! Use code: 123456'
      };
    }

    try {
      // Ensure phone number starts with +
      String formattedPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

      _verificationId = null; // Reset verification ID

      print('🔥 Sending OTP to: $formattedPhoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto verification completed for $formattedPhoneNumber - NO SMS NEEDED');
          // Auto-verification completed
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            print('✅ Auto signed in: ${userCredential.user?.phoneNumber}');
          } catch (e) {
            print('❌ Auto verification error: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed for $formattedPhoneNumber: ${e.code} - ${e.message}');
          print('⚠️  Check Firebase Console:');
          print('   • Phone Authentication enabled?');
          print('   • Test phone numbers configured?');
          print('   • SHA certificates added?');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print('📱 REAL SMS SENT to $formattedPhoneNumber (verificationId set)');
          print('⏰ SMS should arrive in 10-60 seconds');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print('⏳ Auto retrieval timeout for $formattedPhoneNumber');
          print('📱 Manual SMS entry required');
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait a bit for callbacks
      await Future.delayed(const Duration(seconds: 3));

      print('🎯 OTP request completed for $formattedPhoneNumber');
      return {
        'success': true,
        'message': 'SMS OTP sent! Check your phone messages.'
      };
    } catch (e) {
      print('💥 Send OTP error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    // TEST MODE: Accept demo OTP "123456"
    if (_testMode) {
      if (otp == '123456') {
        print('🧪 TEST MODE: OTP verified successfully');

        // Create app user (mock Firebase user)
        final user = user_model.User(
          id: 'demo_user_${phoneNumber.replaceAll('+', '')}',
          phoneNumber: phoneNumber,
          name: 'Demo User',
          merchantId: 'demo_merchant_${phoneNumber.replaceAll('+', '')}',
          shopName: 'Demo Shop',
          isMerchant: false,
        );

        await _storage.saveUser(user);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'error': 'TEST MODE: Use OTP 123456'};
      }
    }

    if (_verificationId == null) {
      return {'success': false, 'error': 'Verification ID not found'};
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Create app user from Firebase user
        final firebaseUser = userCredential.user!;
        final user = user_model.User(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? phoneNumber,
          name: 'User ${phoneNumber.substring(phoneNumber.length - 4)}', // Default name
          merchantId: 'merchant_${phoneNumber.substring(phoneNumber.length - 4)}',
          shopName: 'Shop ${phoneNumber.substring(phoneNumber.length - 4)}', // Default shop
          isMerchant: false, // Let user choose this later
        );

        await _storage.saveUser(user);
        return {'success': true, 'user': user};
      }

      return {'success': false, 'error': 'Authentication failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
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
