import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../viewmodel/security_provider.dart';

class SecuritySetupScreen extends StatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String _pin = '';
  String _confirmPin = '';
  bool _isCreatingPin = true;
  bool _biometricsAvailable = false;
  bool _enableBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      setState(() {
        _biometricsAvailable = isAvailable && 
                              isDeviceSupported && 
                              availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _biometricsAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: _currentPage > 0 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildWelcomePage(),
          _buildPinSetupPage(),
          _buildPinConfirmPage(),
          if (_biometricsAvailable) _buildBiometricsPage(),
          _buildCompletePage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'Secure Your Budget',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Protect your financial data with a secure PIN and biometric authentication.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          _buildSecurityFeatureItem(
            Icons.pin,
            'PIN Protection',
            'Create a 4-digit PIN to secure your app',
          ),
          const SizedBox(height: 16),
          
          if (_biometricsAvailable)
            _buildSecurityFeatureItem(
              Icons.fingerprint,
              'Biometric Authentication',
              'Use your fingerprint or face for quick access',
            ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Started'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _skipSetup,
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSetupPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.pin,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Create Your PIN',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a 4-digit PIN to secure your app',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          _buildPinDisplay(_pin),
          const SizedBox(height: 48),
          
          _buildPinKeypad(),
        ],
      ),
    );
  }

  Widget _buildPinConfirmPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Confirm Your PIN',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your PIN again to confirm',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          _buildPinDisplay(_confirmPin),
          const SizedBox(height: 48),
          
          _buildPinKeypad(),
        ],
      ),
    );
  }

  Widget _buildBiometricsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fingerprint,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'Enable Biometric Authentication',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Use your fingerprint or face for quick and secure access to your budget tracker.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Enhanced Security',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your biometric data is stored securely on your device and never leaves it.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _testBiometrics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Enable Biometrics'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _enableBiometrics = false;
                });
                _nextPage();
              },
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 120,
            color: Colors.green,
          ),
          const SizedBox(height: 32),
          Text(
            'Security Setup Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your budget tracker is now secured with ${_enableBiometrics ? 'PIN and biometric authentication' : 'PIN authentication'}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin, color: Colors.green),
                    const SizedBox(width: 12),
                    const Text(
                      'PIN Protection',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.green),
                  ],
                ),
                if (_enableBiometrics) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.fingerprint, color: Colors.green),
                      const SizedBox(width: 12),
                      const Text(
                        'Biometric Authentication',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue to App'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDisplay(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: index < pin.length 
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: 2,
            ),
            color: index < pin.length 
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
          child: index < pin.length
              ? Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        );
      }),
    );
  }

  Widget _buildPinKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildKeypadRow(['', '0', 'del']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        
        return InkWell(
          onTap: () => _onKeypadPressed(number),
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number == 'del' 
                  ? Colors.red.withOpacity(0.1)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: number == 'del' 
                    ? Colors.red.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: number == 'del'
                ? const Icon(
                    Icons.backspace,
                    color: Colors.red,
                    size: 24,
                  )
                : Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _onKeypadPressed(String key) {
    setState(() {
      if (key == 'del') {
        if (_isCreatingPin && _pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        } else if (!_isCreatingPin && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_isCreatingPin && _pin.length < 4) {
          _pin += key;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _nextPage();
            });
          }
        } else if (!_isCreatingPin && _confirmPin.length < 4) {
          _confirmPin += key;
          if (_confirmPin.length == 4) {
            _validatePin();
          }
        }
      }
    });
  }

  void _validatePin() {
    if (_pin == _confirmPin) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _nextPage();
      });
    } else {
      setState(() {
        _confirmPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testBiometrics() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        setState(() {
          _enableBiometrics = true;
        });
        _nextPage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage == 1) {
      _isCreatingPin = false;
    }
    
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage == 2) {
      _isCreatingPin = true;
      setState(() {
        _confirmPin = '';
      });
    }
    
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipSetup() {
    context.read<SecurityProvider>().skipSecuritySetup();
    context.go('/dashboard');
  }

  void _completeSetup() async {
    final securityProvider = context.read<SecurityProvider>();
    
    await securityProvider.setupSecurity(
      pin: _pin,
      enableBiometrics: _enableBiometrics,
    );
    
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}