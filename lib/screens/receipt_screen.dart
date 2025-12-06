import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const ReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // Generate QR data for transaction verification
    final qrData = 'TXN:${transaction.id}:${transaction.amount}:${transaction.timestamp.toIso8601String()}';
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Transaction QR Code
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
                    // Transaction Details
                    _buildDetailRow('Transaction ID', transaction.id),
                    const Divider(),
                    _buildDetailRow(
                      'Amount',
                      '₹${transaction.amount}',
                      isAmount: true,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Time',
                      dateFormat.format(transaction.timestamp),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Status',
                      'Offline Confirmed',
                      statusColor: Colors.blue,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Merchant',
                      transaction.counterpartyName,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Show this QR code to the merchant for payment verification',
                      style: TextStyle(color: Colors.blue),
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
                  // Share functionality can be added here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt shared')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Receipt'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isAmount = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 20 : 16,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: statusColor ?? (isAmount ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}


