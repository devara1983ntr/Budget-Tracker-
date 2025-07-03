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

  /// Formats a number as currency
  static String formatForInput(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Formats amount for display with no decimal if it's a whole number
  static String formatClean(double amount) {
    if (amount == amount.roundToDouble()) {
      return format(amount).replaceAll('.00', '');
    }
    return format(amount);
  }

  /// Gets currency without symbol for calculations
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Converts string currency to double
  static double currencyToDouble(String currency) {
    return parseAmount(currency);
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Format large numbers with K, M suffixes
  static String formatShort(double amount) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}