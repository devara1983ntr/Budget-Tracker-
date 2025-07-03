import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  PreferencesService._internal();

  static PreferencesService get instance {
    _instance ??= PreferencesService._internal();
    return _instance!;
  }

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // First Launch
  bool get isFirstLaunch {
    return _preferences?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _preferences?.setBool(AppConstants.keyFirstLaunch, false);
  }

  // Theme Mode
  String get themeMode {
    return _preferences?.getString(AppConstants.keyThemeMode) ?? AppConstants.themeSystem;
  }

  Future<void> setThemeMode(String mode) async {
    await _preferences?.setString(AppConstants.keyThemeMode, mode);
  }

  // Currency
  String get currencyCode {
    return _preferences?.getString('${AppConstants.keyCurrency}_code') ?? AppConstants.defaultCurrency;
  }

  String get currencySymbol {
    return _preferences?.getString('${AppConstants.keyCurrency}_symbol') ?? AppConstants.defaultCurrencySymbol;
  }

  Future<void> setCurrency(String code, String symbol) async {
    await _preferences?.setString('${AppConstants.keyCurrency}_code', code);
    await _preferences?.setString('${AppConstants.keyCurrency}_symbol', symbol);
  }

  // Security
  bool get isSecurityEnabled {
    return _preferences?.getBool(AppConstants.keySecurityEnabled) ?? false;
  }

  Future<void> setSecurityEnabled(bool enabled) async {
    await _preferences?.setBool(AppConstants.keySecurityEnabled, enabled);
  }

  String? get userPin {
    return _preferences?.getString(AppConstants.keyPin);
  }

  Future<void> setUserPin(String pin) async {
    await _preferences?.setString(AppConstants.keyPin, pin);
  }

  Future<void> removeUserPin() async {
    await _preferences?.remove(AppConstants.keyPin);
  }

  bool get isBiometricEnabled {
    return _preferences?.getBool(AppConstants.keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferences?.setBool(AppConstants.keyBiometricEnabled, enabled);
  }

  // Last backup/export dates
  DateTime? get lastBackupDate {
    final timestamp = _preferences?.getInt('last_backup_date');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setLastBackupDate(DateTime date) async {
    await _preferences?.setInt('last_backup_date', date.millisecondsSinceEpoch);
  }

  DateTime? get lastExportDate {
    final timestamp = _preferences?.getInt('last_export_date');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setLastExportDate(DateTime date) async {
    await _preferences?.setInt('last_export_date', date.millisecondsSinceEpoch);
  }

  // App usage tracking
  int get appLaunchCount {
    return _preferences?.getInt('app_launch_count') ?? 0;
  }

  Future<void> incrementAppLaunchCount() async {
    final count = appLaunchCount + 1;
    await _preferences?.setInt('app_launch_count', count);
  }

  DateTime? get lastAppLaunchDate {
    final timestamp = _preferences?.getInt('last_app_launch_date');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setLastAppLaunchDate(DateTime date) async {
    await _preferences?.setInt('last_app_launch_date', date.millisecondsSinceEpoch);
  }

  // Notification settings
  bool get notificationsEnabled {
    return _preferences?.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferences?.setBool('notifications_enabled', enabled);
  }

  bool get budgetNotificationsEnabled {
    return _preferences?.getBool('budget_notifications_enabled') ?? true;
  }

  Future<void> setBudgetNotificationsEnabled(bool enabled) async {
    await _preferences?.setBool('budget_notifications_enabled', enabled);
  }

  bool get recurringNotificationsEnabled {
    return _preferences?.getBool('recurring_notifications_enabled') ?? true;
  }

  Future<void> setRecurringNotificationsEnabled(bool enabled) async {
    await _preferences?.setBool('recurring_notifications_enabled', enabled);
  }

  // Default values for forms
  String get defaultAccount {
    return _preferences?.getString('default_account') ?? AppConstants.defaultAccount;
  }

  Future<void> setDefaultAccount(String account) async {
    await _preferences?.setString('default_account', account);
  }

  // Dashboard preferences
  bool get showRecentTransactions {
    return _preferences?.getBool('show_recent_transactions') ?? true;
  }

  Future<void> setShowRecentTransactions(bool show) async {
    await _preferences?.setBool('show_recent_transactions', show);
  }

  int get recentTransactionsLimit {
    return _preferences?.getInt('recent_transactions_limit') ?? 5;
  }

  Future<void> setRecentTransactionsLimit(int limit) async {
    await _preferences?.setInt('recent_transactions_limit', limit);
  }

  // Data privacy
  bool get analyticsEnabled {
    return _preferences?.getBool('analytics_enabled') ?? false;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _preferences?.setBool('analytics_enabled', enabled);
  }

  bool get crashReportingEnabled {
    return _preferences?.getBool('crash_reporting_enabled') ?? true;
  }

  Future<void> setCrashReportingEnabled(bool enabled) async {
    await _preferences?.setBool('crash_reporting_enabled', enabled);
  }

  // Clear all preferences (for reset/logout)
  Future<void> clearAll() async {
    await _preferences?.clear();
  }

  // Generic methods for custom settings
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }
}