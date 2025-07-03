import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'ui/theme/app_theme.dart';
import 'services/preferences_service.dart';
import 'data/repositories/budget_repository.dart';
import 'utils/currency_formatter.dart';
import 'utils/app_constants.dart';

// Import screens
import 'ui/screens/splash_screen.dart';
import 'ui/screens/onboarding_screens.dart';
import 'ui/screens/security_setup_screen.dart';
import 'ui/screens/app_lock_screen.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/transactions_screen.dart';
import 'ui/screens/add_transaction_screen.dart';
import 'ui/screens/transaction_detail_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/budgets_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/about_screen.dart';

// ViewModels
import 'viewmodel/theme_provider.dart';
import 'viewmodel/transaction_provider.dart';
import 'viewmodel/category_provider.dart';
import 'viewmodel/account_provider.dart';
import 'viewmodel/budget_provider.dart';
import 'viewmodel/savings_goal_provider.dart';
import 'viewmodel/security_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize preferences
  await PreferencesService.instance.init();
  
  // Set up currency formatting
  final prefs = PreferencesService.instance;
  CurrencyFormatter.setCurrency(prefs.currencyCode, prefs.currencySymbol);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider(BudgetRepository())),
        ChangeNotifierProvider(create: (_) => CategoryProvider(BudgetRepository())),
        ChangeNotifierProvider(create: (_) => AccountProvider(BudgetRepository())),
        ChangeNotifierProvider(create: (_) => BudgetProvider(BudgetRepository())),
        ChangeNotifierProvider(create: (_) => SavingsGoalProvider(BudgetRepository())),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Router configuration
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

// GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreens(),
    ),
    
    // Security Setup
    GoRoute(
      path: '/security-setup',
      builder: (context, state) => const SecuritySetupScreen(),
    ),
    
    // App Lock
    GoRoute(
      path: '/app-lock',
      builder: (context, state) => const AppLockScreen(),
    ),
    
    // Main App with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) => MainNavigationScreen(child: child),
      routes: [
        // Dashboard
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        
        // Transactions
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        
        // Reports
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        
        // Budgets
        GoRoute(
          path: '/budgets',
          builder: (context, state) => const BudgetsScreen(),
        ),
        
        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    
    // Transaction Management
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    
    GoRoute(
      path: '/edit-transaction/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddTransactionScreen(transactionId: id);
      },
    ),
    
    GoRoute(
      path: '/transaction-detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TransactionDetailScreen(transactionId: id);
      },
    ),
    
    // About Screen
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
  
  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    ),
  ),
  
  // Redirect logic
  redirect: (context, state) async {
    final prefs = PreferencesService.instance;
    final location = state.location;
    
    // Always allow splash screen
    if (location == '/splash') {
      return null;
    }
    
    // Check if first launch
    if (prefs.isFirstLaunch && location != '/onboarding') {
      return '/onboarding';
    }
    
    // Check if security is enabled and user is not on security screens
    if (prefs.isSecurityEnabled && 
        !location.startsWith('/app-lock') && 
        !location.startsWith('/security-setup') &&
        location != '/onboarding') {
      return '/app-lock';
    }
    
    // Default redirect to dashboard if on root
    if (location == '/') {
      return '/dashboard';
    }
    
    return null;
  },
);