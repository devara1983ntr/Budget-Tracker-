import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../services/security_service.dart';

class SecuritySetupScreen extends StatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  final SecurityService _securityService = SecurityService();
  bool _isBiometricAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _securityService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Secure Your App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to protect your financial data',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Security options
              _buildSecurityOption(
                icon: Icons.lock,
                title: 'PIN Protection',
                subtitle: 'Set a 4-digit PIN to secure your app',
                onTap: _setupPin,
              ),
              
              const SizedBox(height: 16),
              
              if (_isBiometricAvailable)
                _buildSecurityOption(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face recognition',
                  onTap: _setupBiometric,
                ),
              
              const SizedBox(height: 16),
              
              _buildSecurityOption(
                icon: Icons.security,
                title: 'No Security',
                subtitle: 'Skip security setup (not recommended)',
                onTap: _skipSecurity,
                isDestructive: true,
              ),
              
              const Spacer(),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can change these settings later in the app settings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      child: ListTile(
        onTap: _isLoading ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: isDestructive
              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Future<void> _setupPin() async {
    final pin = await _showPinSetupDialog();
    if (pin != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<SecurityProvider>().enablePin(pin);
        _navigateToDashboard();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set up PIN: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _securityService.authenticateWithBiometrics(
        reason: 'Set up biometric authentication for Budget Tracker',
      );

      if (success) {
        await _securityService.setBiometricEnabled(true);
        _navigateToDashboard();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set up biometric authentication: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _skipSecurity() {
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    context.go('/dashboard');
  }

  Future<String?> _showPinSetupDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PinSetupDialog(),
    );
  }
}

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isConfirming ? 'Confirm PIN' : 'Set PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isConfirming 
                ? 'Enter your PIN again to confirm'
                : 'Enter a 4-digit PIN to secure your app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final currentPin = _isConfirming ? _confirmPin : _pin;
              return Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    index < currentPin.length ? '●' : '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          _buildNumpad(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      children: [
        ...List.generate(9, (index) => _buildNumpadButton('${index + 1}')),
        const SizedBox(),
        _buildNumpadButton('0'),
        _buildNumpadButton('⌫', isBackspace: true),
      ],
    );
  }

  Widget _buildNumpadButton(String text, {bool isBackspace = false}) {
    return InkWell(
      onTap: () => _onNumpadTap(text, isBackspace),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _onNumpadTap(String value, bool isBackspace) {
    setState(() {
      if (isBackspace) {
        if (_isConfirming) {
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
        } else {
          if (_pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          }
        }
      } else {
        if (_isConfirming) {
          if (_confirmPin.length < 4) {
            _confirmPin += value;
            if (_confirmPin.length == 4) {
              _validatePin();
            }
          }
        } else {
          if (_pin.length < 4) {
            _pin += value;
            if (_pin.length == 4) {
              _isConfirming = true;
            }
          }
        }
      }
    });
  }

  void _validatePin() {
    if (_pin == _confirmPin) {
      Navigator.of(context).pop(_pin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match. Please try again.')),
      );
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }
}