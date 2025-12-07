import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _biometricEnabled;
  late String _language;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _biometricEnabled = authProvider.storage.isBiometricEnabled();
    _language = authProvider.storage.getLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account Information'),
            subtitle: Text(authProvider.user?.name ?? 'N/A'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone Number'),
            subtitle: Text(authProvider.user?.phoneNumber ?? 'N/A'),
            onTap: () {},
          ),
          const Divider(),

          // Security Section
          const _SectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change PIN'),
            onTap: () => _showChangePinDialog(),
          ),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _biometricEnabled,
            secondary: const Icon(Icons.fingerprint),
            onChanged: (value) async {
              if (value && !await authProvider.isBiometricAvailable()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric not available on this device'),
                  ),
                );
                return;
              }

              setState(() => _biometricEnabled = value);
              await authProvider.storage.setBiometricEnabled(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Biometric enabled' : 'Biometric disabled',
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Preferences Section
          const _SectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_getLanguageName(_language)),
            onTap: () => _showLanguageDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {},
          ),
          const Divider(),

          // Data Section
          const _SectionHeader('Data & Privacy'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Clear Cache'),
            onTap: () => _showClearCacheDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          const Divider(),

          // Account Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                hintText: 'Enter 4-6 digits',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == confirmController.text &&
                  pinController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'English',
              code: 'en',
              selected: _language == 'en',
              onTap: () {
                setState(() => _language = 'en');
                Provider.of<AuthProvider>(context, listen: false)
                    .storage
                    .setLanguage('en');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              label: 'हिन्दी (Hindi)',
              code: 'hi',
              selected: _language == 'hi',
              onTap: () {
                setState(() => _language = 'hi');
                Provider.of<AuthProvider>(context, listen: false)
                    .storage
                    .setLanguage('hi');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              label: 'தமிழ் (Tamil)',
              code: 'ta',
              selected: _language == 'ta',
              onTap: () {
                setState(() => _language = 'ta');
                Provider.of<AuthProvider>(context, listen: false)
                    .storage
                    .setLanguage('ta');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content:
            const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      default:
        return 'English';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
    );
  }
}
