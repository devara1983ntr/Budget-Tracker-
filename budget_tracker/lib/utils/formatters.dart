import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class CurrencyFormatter {
  static String? _currentCurrency;
  static String? _currentSymbol;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString(AppConstants.keyCurrency) ?? 'USD';
    _currentSymbol = _getCurrencySymbol(_currentCurrency!);
  }

  static String _getCurrencySymbol(String currencyCode) {
    final currency = AppConstants.currencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => AppConstants.currencies.first,
    );
    return currency['symbol']!;
  }

  static Future<void> setCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrency, currencyCode);
    _currentCurrency = currencyCode;
    _currentSymbol = _getCurrencySymbol(currencyCode);
  }

  static String formatAmount(double amount) {
    if (_currentSymbol == null) {
      return '\$${amount.toStringAsFixed(2)}';
    }
    
    final formatter = NumberFormat.currency(
      symbol: _currentSymbol!,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatAmountWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  static String getCurrentCurrencyCode() {
    return _currentCurrency ?? 'USD';
  }

  static String getCurrentCurrencySymbol() {
    return _currentSymbol ?? '\$';
  }

  static String formatAmountCompact(double amount) {
    if (amount >= 1000000) {
      return '${_currentSymbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_currentSymbol}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount);
    }
  }

  static double parseAmount(String amountText) {
    // Remove currency symbols and formatting
    String cleanText = amountText.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanText) ?? 0.0;
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('MM/dd/yy');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy • hh:mm a');
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else if (date.year == now.year) {
      return DateFormat('MMM dd').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static String formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM yyyy');
    return formatter.format(date);
  }

  static String formatDayMonth(DateTime date) {
    final formatter = DateFormat('dd MMM');
    return formatter.format(date);
  }

  static String formatWeekRange(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startFormatter = DateFormat('MMM dd');
    final endFormatter = DateFormat('MMM dd');
    
    if (startOfWeek.month == endOfWeek.month) {
      return '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('dd').format(endOfWeek)}';
    } else {
      return '${startFormatter.format(startOfWeek)} - ${endFormatter.format(endOfWeek)}';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }
}

class NumberFormatter {
  static String formatPercentage(double value) {
    final formatter = NumberFormat('#0.0');
    return '${formatter.format(value)}%';
  }

  static String formatNumber(double value) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(value);
  }

  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}');
    return formatter.format(value);
  }

  static String formatCompactNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}