import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../models/user.dart';
import 'payment_confirm_screen.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final User merchant;

  const PaymentDetailsScreen({
    super.key,
    required this.merchant,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  String _amount = '0';
  final List<String> _numberPad = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '.', '0', '<',
  ];

  void _onNumberTap(String value) {
    setState(() {
      if (value == '<') {
        if (_amount.isNotEmpty && _amount != '0') {
          _amount = _amount.substring(0, _amount.length - 1);
          if (_amount.isEmpty) _amount = '0';
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount == '0') {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });

    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.setAmount(_amount);
  }

  Future<void> _proceedToPayment() async {
    if (_amount == '0' || double.parse(_amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallet = walletProvider.wallet;

    if (wallet != null) {
      final amount = double.parse(_amount);
      final balance = double.parse(wallet.offlineBalance);

      if (amount > balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient balance')),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmScreen(merchant: widget.merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallet = walletProvider.wallet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Merchant Info
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.store, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      widget.merchant.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.merchant.merchantId != null)
                      Text(
                        'ID: ${widget.merchant.merchantId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Amount Display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹$_amount',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Remaining Balance Info
            if (wallet != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Remaining offline limit: ₹${wallet.offlineBalance}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Number Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _numberPad.length,
                itemBuilder: (context, index) {
                  final value = _numberPad[index];
                  return ElevatedButton(
                    onPressed: () => _onNumberTap(value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: value == '<'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey[200],
                      foregroundColor: value == '<' ? Colors.red : Colors.black,
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pay Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Pay from Offline Wallet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }
}
