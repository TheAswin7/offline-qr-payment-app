import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import 'mock_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with actual API
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Auth
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    if (!await isConnected()) {
      // Mock response
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'otp': '123456'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'error': 'Failed to send OTP'};
    } catch (e) {
      // Fallback to mock
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'otp': '123456'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    if (!await isConnected()) {
      // Mock response
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'user': MockData.getMockUser(phoneNumber).toJson(),
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'error': 'Invalid OTP'};
    } catch (e) {
      // Fallback to mock
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'user': MockData.getMockUser(phoneNumber).toJson(),
      };
    }
  }

  // Wallet
  Future<Wallet?> getWallet(String userId) async {
    if (!await isConnected()) {
      return MockData.getMockWallet(userId);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wallet.fromJson(data);
      }
      return MockData.getMockWallet(userId);
    } catch (e) {
      return MockData.getMockWallet(userId);
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions(String userId) async {
    if (!await isConnected()) {
      return MockData.getMockTransactions(userId);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactions = data['transactions'];
        return transactions.map((json) => Transaction.fromJson(json)).toList();
      }
      return MockData.getMockTransactions(userId);
    } catch (e) {
      return MockData.getMockTransactions(userId);
    }
  }

  // Sync transaction
  Future<bool> syncTransaction(Transaction transaction) async {
    if (!await isConnected()) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}


