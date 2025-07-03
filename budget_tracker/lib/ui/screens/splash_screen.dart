import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _logoSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Initialize providers
    await context.read<ThemeProvider>().initialize();
    await context.read<SecurityProvider>().initialize();
    
    // Start logo animation
    _logoController.forward();
    
    // Start text animation after a delay
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Navigate after splash duration
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigateToNext();
  }

  void _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
    
    if (isFirstLaunch) {
      context.go('/onboarding');
    } else {
      final securityProvider = context.read<SecurityProvider>();
      if (securityProvider.requiresAuthentication && 
          !securityProvider.isAuthenticated) {
        context.go('/app-lock');
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    SlideTransition(
                      position: _logoSlideAnimation,
                      child: ScaleTransition(
                        scale: _logoAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 60,
                            color: Color(AppConstants.primaryGreen),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App Name with animation
                    FadeTransition(
                      opacity: _textAnimation,
                      child: Text(
                        AppConstants.appName,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline
                    FadeTransition(
                      opacity: _textAnimation,
                      child: Text(
                        'Track. Save. Succeed.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Creator Credit
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: FadeTransition(
                opacity: _textAnimation,
                child: Column(
                  children: [
                    Text(
                      'Created with ❤️ by',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.creatorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}