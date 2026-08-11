import 'package:intl/intl.dart';

class DateHelpers {
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  static String formatDateFull(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  static String formatGreetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isUpcomingWithin7Days(DateTime date) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final nextWeekEnd = todayStart.add(const Duration(days: 7));
    return date.isAfter(todayStart.add(const Duration(hours: 23, minutes: 59))) &&
        date.isBefore(nextWeekEnd);
  }

  static bool isOverdue(DateTime scheduledTime, bool isCompleted) {
    if (isCompleted) return false;
    return scheduledTime.isBefore(DateTime.now());
  }
}
