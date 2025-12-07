# Offline QR Payment App

A Flutter application for offline QR payments designed for rural areas with limited internet connectivity.

## Features

- **Offline-First Architecture**: Process payments without internet connection
- **QR Code Payments**: Scan QR codes to pay merchants
- **Merchant QR**: Generate QR codes to receive payments
- **Transaction Management**: Track pending and completed transactions
- **Biometric Authentication**: Secure payments with fingerprint/face ID
- **Multi-language Support**: English, Hindi, and Tamil
- **Offline Wallet**: Dedicated offline wallet balance separate from online bank balance

## Screens

1. **Onboarding & Login**: Phone number OTP verification and PIN setup
2. **Home Dashboard**: View balances and recent transactions
3. **Scan & Pay**: Camera-based QR scanning and payment flow
4. **Merchant Receipt**: Transaction QR code for merchant verification
5. **My QR**: Static QR code for receiving payments
6. **Transactions List**: View pending and completed transactions
7. **Settings & Security**: PIN change, biometric, language settings

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Android Setup

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### iOS Setup

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── transaction.dart
│   └── wallet.dart
├── screens/                  # UI screens
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── scan_pay/            # Payment flow screens
│   ├── receipt_screen.dart
│   ├── my_qr_screen.dart
│   ├── transactions_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── balance_card.dart
│   ├── transaction_item.dart
│   ├── loading_overlay.dart
│   └── error_widget.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── payment_service.dart
│   ├── sync_service.dart
│   ├── storage_service.dart
│   ├── api_service.dart
│   └── mock_data.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── wallet_provider.dart
│   ├── transaction_provider.dart
│   └── payment_provider.dart
└── utils/                    # Utilities
    ├── app_router.dart
    └── app_theme.dart
```

## State Management

The app uses **Provider** for state management with the following providers:

- `AuthProvider`: Authentication and user state
- `WalletProvider`: Wallet balance management
- `TransactionProvider`: Transaction list and sync
- `PaymentProvider`: Payment flow state

## Offline Functionality

- All transactions are stored locally first
- Transactions are queued for sync when internet is available
- Clear visual indicators show sync status (Pending/Synced)
- Offline wallet balance is separate from online bank balance

## Security

- PIN encryption using SHA-256
- Biometric authentication support
- Secure transaction signing
- Local data encryption

## API Integration

The app includes mock data fallback for offline development. To integrate with a real API:

1. Update `lib/services/api_service.dart` with your API endpoints
2. Replace `baseUrl` constant with your API URL
3. Update request/response handling as needed

## License

This project is created for demonstration purposes.





