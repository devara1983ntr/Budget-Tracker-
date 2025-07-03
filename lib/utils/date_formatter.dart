import 'package:intl/intl.dart';
import 'app_constants.dart';

class DateFormatter {
  static String formatDisplay(DateTime date) {
    return DateFormat(AppConstants.dateFormatDisplay).format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat(AppConstants.dateFormatFull).format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat(AppConstants.dateFormatShort).format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (targetDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return formatDisplay(date);
    }
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatYear(DateTime date) {
    return DateFormat('yyyy').format(date);
  }

  static String formatForFilename(DateTime date) {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1; // Monday as start of week
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday; // Sunday as end of week
    return endOfDay(date.add(Duration(days: daysToAdd)));
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

  static List<DateTime> getDateRange(String period, DateTime? customStart, DateTime? customEnd) {
    final now = DateTime.now();
    
    switch (period.toLowerCase()) {
      case 'today':
        return [startOfDay(now), endOfDay(now)];
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return [startOfDay(yesterday), endOfDay(yesterday)];
      case 'this_week':
        return [startOfWeek(now), endOfWeek(now)];
      case 'last_week':
        final lastWeek = now.subtract(const Duration(days: 7));
        return [startOfWeek(lastWeek), endOfWeek(lastWeek)];
      case 'this_month':
        return [startOfMonth(now), endOfMonth(now)];
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        return [startOfMonth(lastMonth), endOfMonth(lastMonth)];
      case 'this_year':
        return [startOfYear(now), endOfYear(now)];
      case 'last_year':
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        return [startOfYear(lastYear), endOfYear(lastYear)];
      case 'custom':
        if (customStart != null && customEnd != null) {
          return [startOfDay(customStart), endOfDay(customEnd)];
        }
        return [startOfDay(now), endOfDay(now)];
      default:
        return [startOfDay(now), endOfDay(now)];
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  static int daysBetween(DateTime date1, DateTime date2) {
    final start = startOfDay(date1);
    final end = startOfDay(date2);
    return end.difference(start).inDays;
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''}';
    }
  }
}