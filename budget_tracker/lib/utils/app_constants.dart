class AppConstants {
  // App Info
  static const String appName = 'Budget Tracker';
  static const String appVersion = '1.0.0';
  static const String creatorName = 'Roshan';
  static const String packageName = 'com.roshan.budgettracker';
  
  // Colors
  static const int primaryGreen = 0xFF10B981;
  static const int darkCharcoal = 0xFF1F2937;
  static const int errorRed = 0xFFEF4444;
  static const int lightGray = 0xFFF3F4F6;
  static const int mediumGray = 0xFF6B7280;
  static const int darkGray = 0xFF374151;
  
  // Database
  static const String databaseName = 'budget_tracker.db';
  static const int databaseVersion = 1;
  
  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyUserPin = 'user_pin';
  static const String keyCurrency = 'currency';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Transaction Types
  static const String incomeType = 'income';
  static const String expenseType = 'expense';
  
  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 0xFFFF6B6B, 'type': 'expense'},
    {'name': 'Transportation', 'icon': 'directions_car', 'color': 0xFF4ECDC4, 'type': 'expense'},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFF45B7D1, 'type': 'expense'},
    {'name': 'Entertainment', 'icon': 'movie', 'color': 0xFF96CEB4, 'type': 'expense'},
    {'name': 'Bills & Utilities', 'icon': 'receipt', 'color': 0xFFFEC107, 'type': 'expense'},
    {'name': 'Healthcare', 'icon': 'local_hospital', 'color': 0xFFE056FD, 'type': 'expense'},
    {'name': 'Education', 'icon': 'school', 'color': 0xFF686DE0, 'type': 'expense'},
    {'name': 'Travel', 'icon': 'flight', 'color': 0xFF30336B, 'type': 'expense'},
    {'name': 'Salary', 'icon': 'work', 'color': 0xFF26DE81, 'type': 'income'},
    {'name': 'Freelance', 'icon': 'laptop', 'color': 0xFF2BCBBA, 'type': 'income'},
    {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFFFFD93D, 'type': 'income'},
    {'name': 'Gift', 'icon': 'card_giftcard', 'color': 0xFFFF6B9D, 'type': 'income'},
  ];
  
  // Default Accounts
  static const List<Map<String, dynamic>> defaultAccounts = [
    {'name': 'Cash', 'icon': 'account_balance_wallet', 'color': 0xFF4CAF50, 'balance': 0.0},
    {'name': 'Bank Account', 'icon': 'account_balance', 'color': 0xFF2196F3, 'balance': 0.0},
    {'name': 'Credit Card', 'icon': 'credit_card', 'color': 0xFFFF9800, 'balance': 0.0},
  ];
  
  // Chart Colors
  static const List<int> chartColors = [
    0xFF10B981,
    0xFF3B82F6,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF8B5CF6,
    0xFF06B6D4,
    0xFFF97316,
    0xFFEC4899,
    0xFF84CC16,
    0xFF6366F1,
  ];
  
  // Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
  ];
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // UI Constraints
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double avatarRadius = 20.0;
}