import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../viewmodel/security_provider.dart';
import '../../services/preferences_service.dart';
import '../../utils/app_constants.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _isShaking = false;
  bool _showBiometric = false;
  int _failedAttempts = 0;
  
  late AnimationController _shakeController;
  late AnimationController _fadeController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;
  
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final prefs = PreferencesService.instance;
      
      setState(() {
        _showBiometric = isAvailable && prefs.isBiometricEnabled;
      });
      
      // Auto-trigger biometric if enabled
      if (_showBiometric) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _authenticateWithBiometric();
        });
      }
    } catch (e) {
      // Biometric not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildAppLogo(),
                const SizedBox(height: 32),
                _buildWelcomeText(),
                const SizedBox(height: 48),
                _buildPinDisplay(),
                const SizedBox(height: 32),
                _buildBiometricButton(),
                const Spacer(flex: 2),
                _buildNumpad(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Stylized "B" for Budget
            Text(
              'B',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -2,
              ),
            ),
            
            // Lock icon overlay
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your PIN to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
          child: Row(
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
                    width: 1,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBiometricButton() {
    if (!_showBiometric) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: _authenticateWithBiometric,
        icon: const Icon(Icons.fingerprint),
        label: const Text('Use Biometric'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    const numbers = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: numbers.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((value) {
                if (value.isEmpty) {
                  return const SizedBox(width: 80, height: 80);
                }
                
                return _buildNumpadButton(value);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumpadButton(String value) {
    final isBackspace = value == 'backspace';
    
    return Container(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNumpadTap(value),
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: isBackspace
                  ? const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNumpadTap(String value) {
    if (value == 'backspace') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
    } else {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin += value;
        });
        
        if (_enteredPin.length == 4) {
          _verifyPin();
        }
      }
    }
  }

  Future<void> _verifyPin() async {
    final securityProvider = context.read<SecurityProvider>();
    final isCorrect = await securityProvider.verifyPin(_enteredPin);
    
    if (isCorrect) {
      _onAuthenticationSuccess();
    } else {
      _onAuthenticationFailed();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Budget Tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (isAuthenticated) {
        _onAuthenticationSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onAuthenticationSuccess() {
    final securityProvider = context.read<SecurityProvider>();
    securityProvider.unlock();
    
    if (mounted) {
      context.go('/dashboard');
    }
  }

  void _onAuthenticationFailed() {
    setState(() {
      _enteredPin = '';
      _failedAttempts++;
      _isShaking = true;
    });
    
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        setState(() {
          _isShaking = false;
        });
      });
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect PIN. ${3 - _failedAttempts} attempts remaining.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    if (_failedAttempts >= 3) {
      _showTooManyAttemptsDialog();
    }
  }

  void _showTooManyAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Failed Attempts'),
        content: const Text(
          'You have exceeded the maximum number of PIN attempts. '
          'Please wait 30 seconds before trying again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startCooldown();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startCooldown() {
    setState(() {
      _failedAttempts = 0;
    });
    
    // Disable input for 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can now try entering your PIN again.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}