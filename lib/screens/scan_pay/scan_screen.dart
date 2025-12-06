import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/mock_data.dart';
import 'payment_details_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQRCodeDetect(String? code) {
    if (code == null || code.isEmpty) return;

    // Parse QR code (assuming format: merchant_id:merchant_name)
    // In real app, this would be a proper QR code format
    final parts = code.split(':');
    String merchantId;

    if (parts.length >= 2) {
      merchantId = parts[0];
    } else {
      // Fallback: use code as merchant ID
      merchantId = code;
    }

    // Get merchant info (mock for now)
    final merchant = MockData.getMockMerchant(merchantId);

    // Set merchant in payment provider
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.setMerchant(merchant);

    // Navigate to payment details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(merchant: merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onQRCodeDetect(barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // QR Frame Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Instruction Text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Point at merchant QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


