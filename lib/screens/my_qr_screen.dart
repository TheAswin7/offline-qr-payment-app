import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    // Generate QR data with merchant ID
    final merchantId = user.merchantId ?? user.id;
    final qrData = 'MERCHANT:$merchantId:${user.name}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // QR Code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Merchant Info
                    if (user.name.isNotEmpty)
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (user.shopName != null && user.shopName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.shopName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (merchantId.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ID: $merchantId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Show only to customer',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share QR functionality can be added here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR code shared')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


