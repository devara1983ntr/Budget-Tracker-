import 'package:intl/intl.dart';
import 'app_constants.dart';

class CurrencyFormatter {
  static String _currentCurrencySymbol = AppConstants.defaultCurrencySymbol;
  static String _currentCurrencyCode = AppConstants.defaultCurrency;

  static void setCurrency(String code, String symbol) {
    _currentCurrencyCode = code;
    _currentCurrencySymbol = symbol;
  }

  static String format(double amount, {bool showSymbol = true, int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      symbol: showSymbol ? _currentCurrencySymbol : '',
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }

  static String formatWithSign(double amount, String type, {bool showSymbol = true, int decimalPlaces = 2}) {
    final formattedAmount = format(amount.abs(), showSymbol: showSymbol, decimalPlaces: decimalPlaces);
    
    if (type == AppConstants.incomeType) {
      return '+$formattedAmount';
    } else {
      return '-$formattedAmount';
    }
  }

  static String formatCompact(double amount, {bool showSymbol = true}) {
    if (amount.abs() >= 1000000) {
      return '${format(amount / 1000000, showSymbol: showSymbol, decimalPlaces: 1)}M';
    } else if (amount.abs() >= 1000) {
      return '${format(amount / 1000, showSymbol: showSymbol, decimalPlaces: 1)}K';
    } else {
      return format(amount, showSymbol: showSymbol);
    }
  }

  static String getCurrentCurrencySymbol() {
    return _currentCurrencySymbol;
  }

  static String getCurrentCurrencyCode() {
    return _currentCurrencyCode;
  }

  static double parseAmount(String text) {
    // Remove currency symbol and spaces
    String cleanText = text.replaceAll(_currentCurrencySymbol, '').replaceAll(',', '').trim();
    
    try {
      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }

  static bool isValidAmount(String text) {
    if (text.isEmpty) return false;
    
    final amount = parseAmount(text);
    return amount >= 0 && amount <= AppConstants.maxTransactionAmount;
  }
}