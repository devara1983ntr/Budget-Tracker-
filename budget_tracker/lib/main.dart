import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/theme/app_theme.dart';
import 'viewmodel/transaction_provider.dart';
import 'services/security_service.dart';
import 'utils/formatters.dart';
import 'utils/app_constants.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/security_setup_screen.dart';
import 'ui/screens/app_lock_screen.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/transactions_screen.dart';
import 'ui/screens/add_transaction_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/budgets_screen.dart';
import 'ui/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize formatters
  await CurrencyFormatter.initialize();
  
  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDark => _themeMode == ThemeMode.dark;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemeMode, mode.index);
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  bool _isAuthenticated = false;
  bool _requiresAuthentication = false;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get requiresAuthentication => _requiresAuthentication;
  
  Future<void> initialize() async {
    _requiresAuthentication = await _securityService.requiresAuthentication();
    if (_requiresAuthentication) {
      _isAuthenticated = await _securityService.isSessionValid();
    } else {
      _isAuthenticated = true;
    }
    notifyListeners();
  }
  
  Future<bool> authenticate() async {
    if (!_requiresAuthentication) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    
    final result = await _securityService.authenticateUser();
    if (result) {
      _isAuthenticated = true;
      await _securityService.updateSessionTime();
      notifyListeners();
    }
    return result;
  }
  
  Future<void> logout() async {
    _isAuthenticated = false;
    await _securityService.clearSession();
    notifyListeners();
  }
  
  Future<void> enablePin(String pin) async {
    await _securityService.setPin(pin);
    _requiresAuthentication = true;
    notifyListeners();
  }
  
  Future<void> disablePin() async {
    await _securityService.disablePin();
    _requiresAuthentication = await _securityService.requiresAuthentication();
    notifyListeners();
  }
  
  Future<bool> verifyPin(String pin) async {
    final result = await _securityService.verifyPin(pin);
    if (result) {
      _isAuthenticated = true;
      await _securityService.updateSessionTime();
      notifyListeners();
    }
    return result;
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      return null; // No synchronous redirect logic
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/security-setup',
        builder: (context, state) => const SecuritySetupScreen(),
      ),
      GoRoute(
        path: '/app-lock',
        builder: (context, state) => const AppLockScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
    ],
  );
}
