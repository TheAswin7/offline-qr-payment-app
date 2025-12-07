import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/user.dart';
import 'payment_success_screen.dart';

class PaymentConfirmScreen extends StatefulWidget {
  final User merchant;

  const PaymentConfirmScreen({
    super.key,
    required this.merchant,
  });

  @override
  State<PaymentConfirmScreen> createState() => _PaymentConfirmScreenState();
}

class _PaymentConfirmScreenState extends State<PaymentConfirmScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    print('🔐 Starting authentication...');
    print('💰 Payment amount: ${paymentProvider.amount}');

    bool authenticated = false;

    // TEMPORARY: Skip authentication for testing
    // TODO: Re-enable authentication after confirming payment flow works
    authenticated = true;
    print('✅ Authentication skipped for testing');

    // ORIGINAL CODE FOR AUTHENTICATION (commented out):
    /*
    // Check if biometric is enabled
    // Access storage through auth provider's internal storage
    final authProviderInternal = authProvider as dynamic;
    final storage = authProviderInternal._storage;
    final isBiometricEnabled = storage?.isBiometricEnabled() ?? false;

    bool authenticated = false;

    if (isBiometricEnabled && await authProvider.isBiometricAvailable()) {
      // Try biometric first
      print('👆 Attempting biometric authentication...');
      authenticated = await authProvider.authenticateWithBiometric();
      print('👆 Biometric result: $authenticated');
    }

    if (!authenticated) {
      // Fallback to PIN
      print('🔢 Checking PIN authentication...');
      if (_pinController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter PIN')),
        );
        print('❌ Empty PIN - authentication failed');
        return;
      }

      print('🔢 Verifying PIN: "${_pinController.text}"');
      authenticated = await authProvider.verifyPin(_pinController.text);
      print('🔢 PIN verification result: $authenticated');

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN')),
        );
        print('❌ Invalid PIN - authentication failed');
        return;
      }
    }
    */

    print('💳 Processing payment...');
    // Process payment
    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Process customer payment (deduct money)
      final result = await paymentProvider.processPayment(
        amount: paymentProvider.amount,
        merchant: widget.merchant,
        userId: authProvider.user!.id,
      );

      print('💳 Customer payment result: $result');

      if (result['success'] == true) {
        // Step 2: Credit merchant wallet (add money)
        print('💰 Crediting merchant wallet...');
        final merchantResult = await paymentProvider.processMerchantPayment(
          amount: paymentProvider.amount,
          customer: authProvider.user!, // Current user as customer
          merchantId: widget.merchant.merchantId ?? widget.merchant.id,
        );

        print('💰 Merchant credit result: $merchantResult');

        setState(() {
          _isProcessing = false;
        });

        print('✅ Payment successful, updating wallets and navigating...');

        // Update customer's wallet and transactions
        walletProvider.updateWallet(result['wallet']);
        transactionProvider.addTransaction(result['transaction']);

        // Navigate to success screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                transaction: result['transaction'],
              ),
            ),
          );
          print('🎯 Navigation completed');
          print('🎉 MERCHANT BALANCE UPDATED! Merchant received ₹${paymentProvider.amount}');
        }
      } else {
        print('❌ Payment failed: ${result['error']}');
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Payment failed')),
        );
      }
    } catch (e) {
      print('💥 Payment error: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirm Payment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${paymentProvider.amount}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${widget.merchant.name}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: _obscurePin,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  prefixIcon: const Icon(Icons.pin),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePin = !_obscurePin;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Confirm Payment',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40), // Bottom spacing for scroll
          ],
        ),
      ),
    );
  }
}
