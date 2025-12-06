import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/payment_provider.dart';
import 'services/storage_service.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService)),
        ChangeNotifierProvider(create: (_) => WalletProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(storageService)),
        ChangeNotifierProvider(create: (_) => PaymentProvider(storageService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Determine initial route based on authentication
        final initialRoute = authProvider.isAuthenticated
            ? AppRouter.home
            : AppRouter.onboarding;

        return MaterialApp(
          title: 'Offline QR Payments',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('hi', ''),
            Locale('ta', ''),
          ],
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: initialRoute,
        );
      },
    );
  }
}

