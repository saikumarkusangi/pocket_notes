import 'package:intl/intl.dart';

class DateFormats {
  static const String dateFormat = 'MMM d, yyyy';
  static const String dayOfWeekFormat = 'EEEE';

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDayOfWeek(int day) {
    return DateFormat('EEEE').format(DateTime(0, 0, day));
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatHomeSubtitleDate(DateTime date) {
    return DateFormat('d MMM, yy').format(date);
  }
}
