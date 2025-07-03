import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../services/security_service.dart';
import '../../utils/app_constants.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final SecurityService _securityService = SecurityService();
  String _enteredPin = '';
  bool _isLoading = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final biometricEnabled = await _securityService.isBiometricEnabled();
    final biometricAvailable = await _securityService.isBiometricAvailable();
    
    setState(() {
      _showBiometric = biometricEnabled && biometricAvailable;
    });

    if (_showBiometric) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final success = await _securityService.authenticateWithBiometrics();
      if (success) {
        await context.read<SecurityProvider>().authenticate();
        _navigateToDashboard();
      }
    } catch (e) {
      // Biometric failed, show PIN entry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // App logo and name
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: Color(AppConstants.primaryGreen),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'Enter your PIN to unlock',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 48),
              
              // Numpad
              _buildNumpad(),
              
              const SizedBox(height: 24),
              
              // Biometric button
              if (_showBiometric)
                IconButton(
                  onPressed: _authenticateWithBiometric,
                  icon: const Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          ...List.generate(9, (index) => _buildNumpadButton('${index + 1}')),
          const SizedBox(),
          _buildNumpadButton('0'),
          _buildNumpadButton('⌫', isBackspace: true),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String text, {bool isBackspace = false}) {
    return InkWell(
      onTap: _isLoading ? null : () => _onNumpadTap(text, isBackspace),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _onNumpadTap(String value, bool isBackspace) {
    if (_isLoading) return;

    setState(() {
      if (isBackspace) {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin += value;
          if (_enteredPin.length == 4) {
            _verifyPin();
          }
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<SecurityProvider>().verifyPin(_enteredPin);
      
      if (success) {
        _navigateToDashboard();
      } else {
        _showIncorrectPinFeedback();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _enteredPin = '';
      });
    }
  }

  void _showIncorrectPinFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incorrect PIN. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Shake animation for PIN dots
    setState(() {
      _enteredPin = '';
    });
  }

  void _navigateToDashboard() {
    context.go('/dashboard');
  }
}