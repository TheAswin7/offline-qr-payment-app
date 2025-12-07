// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';

// class MyQrScreen extends StatelessWidget {
//   const MyQrScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.user;

//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not found')),
//       );
//     }

//     // Generate QR data with merchant ID
//     final merchantId = user.merchantId ?? user.id;
//     final qrData = 'MERCHANT:$merchantId:${user.name}';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My QR Code'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),
//             // QR Code
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: QrImageView(
//                         data: qrData,
//                         version: QrVersions.auto,
//                         size: 250,
//                         backgroundColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Merchant Info
//                     if (user.name.isNotEmpty)
//                       Text(
//                         user.name,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     if (user.shopName != null && user.shopName!.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         user.shopName!,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                     if (merchantId.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         'ID: $merchantId',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Instructions
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.orange),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Show only to customer',
//                       style: TextStyle(color: Colors.orange),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Action Buttons
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // Share QR functionality can be added here
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('QR code shared')),
//                   );
//                 },
//                 icon: const Icon(Icons.share),
//                 label: const Text('Share QR Code'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    // Generate QR data: merchantId:merchantName:userId
    final qrData =
        '${user.merchantId ?? user.id}:${user.shopName ?? user.name}:${user.id}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  if (user.isMerchant) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Merchant Account',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            const Text(
              'Your Payment QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 280,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'How to use',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Show this QR code to customers\n'
                    '2. They can scan and send you payment\n'
                    '3. Your account balance will update\n'
                    '4. Transactions sync automatically when online',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code saved to gallery')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Save QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code shared')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
