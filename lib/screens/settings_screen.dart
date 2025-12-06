import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../utils/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;
  String _selectedLanguage = 'en';
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'ta', 'name': 'தமிழ்'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Access storage service through auth provider
    final storage = (authProvider as dynamic)._storage as StorageService?;
    if (storage != null) {
      setState(() {
        _biometricEnabled = storage.isBiometricEnabled();
        _selectedLanguage = storage.getLanguage();
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storage = (authProvider as dynamic)._storage as StorageService?;

    if (value) {
      // Check if biometric is available
      final isAvailable = await authProvider.isBiometricAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not available')),
        );
        return;
      }
    }

    if (storage != null) {
      await storage.setBiometricEnabled(value);
      setState(() {
        _biometricEnabled = value;
      });
    }
  }

  Future<void> _changeLanguage(String language) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storage = (authProvider as dynamic)._storage as StorageService?;

    if (storage != null) {
      await storage.setLanguage(language);
      setState(() {
        _selectedLanguage = language;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language changed')),
      );
    }
  }

  Future<void> _requestOtpForPinChange() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    final success = await authProvider.sendOtp(authProvider.user!.phoneNumber);
    if (success) {
      _showChangePinDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
      );
    }
  }

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Wallet PIN'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '123456',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPinController,
                keyboardType: TextInputType.number,
                obscureText: _obscureNewPin,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPin ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPin = !_obscureNewPin;
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _otpController.clear();
              _newPinController.clear();
              _confirmPinController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _confirmPinChange,
            child: const Text('Change PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPinChange() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    if (_newPinController.text.isEmpty || _newPinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    // Verify OTP
    final otpVerified = await authProvider.verifyOtp(
      authProvider.user!.phoneNumber,
      _otpController.text,
    );

    if (!otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
      return;
    }

    // Set new PIN
    final success = await authProvider.setPin(_newPinController.text);

    if (success) {
      Navigator.pop(context);
      _otpController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change PIN')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.onboarding,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Security'),
      ),
      body: ListView(
        children: [
          // Security Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Wallet PIN'),
            subtitle: const Text('Requires OTP verification'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _requestOtpForPinChange,
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face ID'),
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              );
            },
          ),
          const Divider(),
          // Language Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                }
              },
            );
          }),
          const Divider(),
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: _logout,
          ),
          const Divider(),
          // Help Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone_disabled),
            title: const Text('Report Lost Phone'),
            subtitle: const Text(
              'Contact support immediately if your phone is lost or stolen',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report Lost Phone'),
                  content: const Text(
                    'If your phone is lost or stolen, contact support immediately at:\n\n'
                    'Support: +91-1800-XXX-XXXX\n'
                    'Email: support@example.com\n\n'
                    'Your wallet can be temporarily disabled to prevent unauthorized access.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


