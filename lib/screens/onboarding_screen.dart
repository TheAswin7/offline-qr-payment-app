import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'ta', 'name': 'தமிழ்'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await authProvider.sendOtp(_phoneController.text);

    // Hide loading
    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      setState(() {
        _currentStep = 1;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await authProvider.verifyOtp(
      _phoneController.text,
      _otpController.text,
    );

    // Hide loading
    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
        );
      }
    }
  }

  Future<void> _setPin() async {
    if (_pinController.text.isEmpty || _pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await authProvider.setPin(_pinController.text);

    if (success && authProvider.user != null) {
      // Load wallet
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.loadWallet(authProvider.user!.id);

      // Hide loading
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    } else {
      // Hide loading
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set PIN')),
        );
      }
    }
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isExpanded: true,
          items: _languages.map((lang) {
            return DropdownMenuItem(
              value: lang['code'],
              child: Text(lang['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Offline QR Payments',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Offline QR Payments for Rural Areas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91 9876543210',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendOtp,
              child: const Text('Get OTP'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sms,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'OTP sent to ${_phoneController.text}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: '123456',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _sendOtp,
            child: const Text('Resend OTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildPinStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Set Wallet PIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a 4-6 digit PIN to secure your wallet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: _obscurePin,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'PIN',
              hintText: 'Enter PIN',
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
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPinController,
            keyboardType: TextInputType.number,
            obscureText: _obscureConfirmPin,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              hintText: 'Re-enter PIN',
              prefixIcon: const Icon(Icons.pin),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPin ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPin = !_obscureConfirmPin;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _setPin,
              child: const Text('Set PIN'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 120,
              child: _buildLanguageSelector(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentStep,
          children: [
            _buildPhoneStep(),
            _buildOtpStep(),
            _buildPinStep(),
          ],
        ),
      ),
    );
  }
}

