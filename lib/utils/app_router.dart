import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/scan_pay/scan_screen.dart';
import '../screens/scan_pay/payment_details_screen.dart';
import '../screens/scan_pay/payment_confirm_screen.dart';
import '../screens/scan_pay/payment_success_screen.dart';
import '../screens/receipt_screen.dart';
import '../screens/my_qr_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/settings_screen.dart';

import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String paymentDetails = '/payment-details';
  static const String paymentConfirm = '/payment-confirm';
  static const String paymentSuccess = '/payment-success';
  static const String receipt = '/receipt';
  static const String myQr = '/my-qr';
  static const String transactions = '/transactions';
  static const String settings = '/settings';

  static final Set<String> protectedRoutes = {
    home,
    scan,
    paymentDetails,
    paymentConfirm,
    paymentSuccess,
    receipt,
    myQr,
    transactions,
    settings,
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? onboarding;

    return MaterialPageRoute(
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        /// Access storage service using getter
        final StorageService storageService = authProvider.storage;

        /// Check onboarding
        if (routeName != onboarding) {
          if (!storageService.isOnboarded()) {
            return const OnboardingScreen();
          }
        }

        /// Check authentication
        if (protectedRoutes.contains(routeName) &&
            !authProvider.isAuthenticated) {
          return const OnboardingScreen();
        }

        return _buildRoute(routeName, settings);
      },
    );
  }

  static Widget _buildRoute(String routeName, RouteSettings routeSettings) {
    switch (routeName) {
      case onboarding:
        return const OnboardingScreen();
      case home:
        return const HomeScreen();
      case scan:
        return const ScanScreen();

      case paymentDetails:
        final args = routeSettings.arguments;
        if (args is Map && args['merchant'] != null) {
          return PaymentDetailsScreen(merchant: args['merchant']);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid route arguments')),
        );

      case paymentConfirm:
        final args = routeSettings.arguments;
        if (args is Map && args['merchant'] != null) {
          return PaymentConfirmScreen(merchant: args['merchant']);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid route arguments')),
        );

      case paymentSuccess:
        final args = routeSettings.arguments;
        if (args is Map && args['transaction'] != null) {
          return PaymentSuccessScreen(transaction: args['transaction']);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid route arguments')),
        );

      case receipt:
        final args = routeSettings.arguments;
        if (args is Map && args['transaction'] != null) {
          return ReceiptScreen(transaction: args['transaction']);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid route arguments')),
        );

      case myQr:
        return const MyQrScreen();

      case transactions:
        return const TransactionsScreen();

      case settings:
        return const SettingsScreen();

      default:
        return const Scaffold(
          body: Center(child: Text('Route not found')),
        );
    }
  }

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingScreen(),
    home: (context) => const HomeScreen(),
    scan: (context) => const ScanScreen(),
    myQr: (context) => const MyQrScreen(),
    transactions: (context) => const TransactionsScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
