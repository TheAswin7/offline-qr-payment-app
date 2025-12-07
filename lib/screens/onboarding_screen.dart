import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/loading_overlay.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0; // 0: Phone, 1: OTP, 2: PIN
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    // Validate phone number (allow both formats)
    if (phone.isEmpty ||
        (!phone.startsWith('+91') && phone.length != 10) ||
        phone.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid 10-digit mobile number')),
      );
      return;
    }

    // Format phone number with country code if not present
    String formattedPhone;
    if (phone.startsWith('+91')) {
      formattedPhone = phone;
    } else if (phone.startsWith('91')) {
      formattedPhone = '+$phone';
    } else {
      formattedPhone = '+91$phone';
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(formattedPhone);

    if (success && mounted) {
      setState(() => _currentStep = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent! Check your SMS'),
          duration: Duration(seconds: 5),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP. Check Firebase console for errors.')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid OTP')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await authProvider.verifyOtp(_phoneController.text, otp);

    if (success && mounted) {
      setState(() => _currentStep = 2);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
      );
    }
  }

  Future<void> _setPin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin.isEmpty || pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setPin(pin);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authProvider.isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                const Icon(
                  Icons.account_balance_wallet,
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
                  'Secure payments anywhere, anytime',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Step Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...[0, 1, 2].map((step) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _currentStep >= step
                                  ? Colors.blue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 48),

                // Step Content
                Expanded(
                  child: _buildStepContent(),
                ),

                const SizedBox(height: 24),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : _getButtonAction(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _getButtonLabel(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                if (_currentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: // Phone Number
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91 9876543210',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );

      case 1: // OTP
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${_phoneController.text}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '------',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );

      case 2: // PIN Setup
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Security PIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a 4-6 digit PIN for transactions',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'PIN',
                prefixIcon: const Icon(Icons.pin),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePin = !_obscurePin),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
                prefixIcon: const Icon(Icons.pin),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPin
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _getButtonLabel() {
    switch (_currentStep) {
      case 0:
        return 'Send OTP';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'Create Account';
      default:
        return 'Next';
    }
  }

  VoidCallback _getButtonAction() {
    switch (_currentStep) {
      case 0:
        return _sendOtp;
      case 1:
        return _verifyOtp;
      case 2:
        return _setPin;
      default:
        return () {};
    }
  }
}
