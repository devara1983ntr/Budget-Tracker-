class AppConstants {
  // App Info
  static const String appName = 'Budget Tracker';
  static const String appVersion = '1.0.0';
  static const String createdBy = 'Roshan';
  
  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';
  static const String keySecurityEnabled = 'security_enabled';
  static const String keyPin = 'user_pin';
  static const String keyBiometricEnabled = 'biometric_enabled';
  
  // Theme Options
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';
  
  // Transaction Types
  static const String incomeType = 'income';
  static const String expenseType = 'expense';
  
  // Budget Periods
  static const String periodDaily = 'daily';
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';
  static const String periodYearly = 'yearly';
  
  // Recurring Transaction Frequencies
  static const List<String> frequencies = [
    periodDaily,
    periodWeekly,
    periodMonthly,
    periodYearly,
  ];
  
  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatFull = 'EEEE, MMMM dd, yyyy';
  static const String dateFormatShort = 'MM/dd/yy';
  
  // Currency Options
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
  ];
  
  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
  static const String defaultAccount = 'Cash';
  static const String defaultCategory = 'Other';
  
  // File Export
  static const String csvFileName = 'budget_tracker_export';
  static const String backupFileName = 'budget_tracker_backup';
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const double maxTransactionAmount = 999999999.99;
  static const int maxDescriptionLength = 100;
  static const int maxNotesLength = 500;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Chart Colors
  static const List<int> chartColors = [
    0xFF10B981, // Primary Green
    0xFF3B82F6, // Blue
    0xFFEF4444, // Red
    0xFFF59E0B, // Amber
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
    0xFF84CC16, // Lime
    0xFFF97316, // Orange
    0xFF6366F1, // Indigo
  ];
  
  // Notification Settings
  static const String notificationChannelId = 'budget_tracker_notifications';
  static const String notificationChannelName = 'Budget Tracker Notifications';
  static const String notificationChannelDescription = 'Notifications for budget limits and recurring transactions';
}