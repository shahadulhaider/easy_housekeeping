import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('d MMM').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatMonthKey(DateTime date) =>
      DateFormat('yyyy-MM').format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return formatDateShort(date);
  }

  static String daysRemaining(int days) {
    if (days <= 0) return 'Overdue';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
