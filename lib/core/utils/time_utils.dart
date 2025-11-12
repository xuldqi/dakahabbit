/// 时间管理工具类
class TimeUtils {
  // 私有构造函数，防止实例化
  TimeUtils._();

  /// 格式化日期为YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化时间为HH:MM
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间为YYYY-MM-DD HH:MM
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// 解析日期字符串（YYYY-MM-DD）
  static DateTime parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw FormatException('无效的日期格式: $dateString');
    }
  }

  /// 解析时间字符串（HH:MM）
  static DateTime parseTime(String timeString, {DateTime? date}) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) {
        throw FormatException('时间格式应为 HH:MM');
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw FormatException('无效的时间值');
      }

      final targetDate = date ?? DateTime.now();
      return DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        hour,
        minute,
      );
    } catch (e) {
      throw FormatException('无效的时间格式: $timeString');
    }
  }

  /// 获取今天的日期字符串
  static String getTodayDateString() {
    return formatDate(DateTime.now());
  }

  /// 获取昨天的日期字符串
  static String getYesterdayDateString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return formatDate(yesterday);
  }

  /// 获取明天的日期字符串
  static String getTomorrowDateString() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return formatDate(tomorrow);
  }

  /// 获取当前时间字符串
  static String getCurrentTimeString() {
    return formatTime(DateTime.now());
  }

  /// 判断是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// 判断是否是昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// 判断是否是明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  /// 判断是否是本周
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 判断是否是本月
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// 判断是否是本年
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// 获取两个日期之间的天数差
  static int getDaysDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inDays.abs();
  }

  /// 获取两个日期之间的小时数差
  static int getHoursDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inHours.abs();
  }

  /// 获取两个日期之间的分钟数差
  static int getMinutesDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inMinutes.abs();
  }

  /// 获取相对时间描述
  static String getRelativeTimeDescription(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // 未来时间
      final futureDifference = date.difference(now);
      
      if (futureDifference.inMinutes < 60) {
        if (futureDifference.inMinutes == 0) {
          return '现在';
        }
        return '${futureDifference.inMinutes} 分钟后';
      } else if (futureDifference.inHours < 24) {
        return '${futureDifference.inHours} 小时后';
      } else if (futureDifference.inDays == 1) {
        return '明天';
      } else if (futureDifference.inDays < 7) {
        return '${futureDifference.inDays} 天后';
      } else {
        return formatDate(date);
      }
    } else {
      // 过去时间
      if (difference.inMinutes < 60) {
        if (difference.inMinutes == 0) {
          return '刚刚';
        }
        return '${difference.inMinutes} 分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} 小时前';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} 天前';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks 周前';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months 个月前';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years 年前';
      }
    }
  }

  /// 获取本周的开始和结束日期
  static Map<String, DateTime> getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return {
      'start': DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      'end': DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    };
  }

  /// 获取本月的开始和结束日期
  static Map<String, DateTime> getThisMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return {
      'start': startOfMonth,
      'end': endOfMonth,
    };
  }

  /// 获取本年的开始和结束日期
  static Map<String, DateTime> getThisYearRange() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return {
      'start': startOfYear,
      'end': endOfYear,
    };
  }

  /// 获取指定日期范围内的所有日期
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!currentDate.isAfter(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// 获取本周的所有日期
  static List<DateTime> getThisWeekDates() {
    final weekRange = getThisWeekRange();
    return getDateRange(weekRange['start']!, weekRange['end']!);
  }

  /// 获取本月的所有日期
  static List<DateTime> getThisMonthDates() {
    final monthRange = getThisMonthRange();
    return getDateRange(monthRange['start']!, monthRange['end']!);
  }

  /// 获取星期几的中文名称
  static String getWeekdayName(int weekday) {
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    if (weekday < 1 || weekday > 7) {
      return '未知';
    }
    return weekdays[weekday];
  }

  /// 获取月份的中文名称
  static String getMonthName(int month) {
    const months = ['', '一月', '二月', '三月', '四月', '五月', '六月',
                   '七月', '八月', '九月', '十月', '十一月', '十二月'];
    if (month < 1 || month > 12) {
      return '未知';
    }
    return months[month];
  }

  /// 获取友好的日期描述
  static String getFriendlyDateDescription(DateTime date) {
    if (isToday(date)) {
      return '今天';
    } else if (isYesterday(date)) {
      return '昨天';
    } else if (isTomorrow(date)) {
      return '明天';
    } else if (isThisWeek(date)) {
      return getWeekdayName(date.weekday);
    } else {
      return formatDate(date);
    }
  }

  /// 验证时间字符串格式（HH:MM）
  static bool isValidTimeFormat(String timeString) {
    final timePattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timePattern.hasMatch(timeString);
  }

  /// 验证日期字符串格式（YYYY-MM-DD）
  static bool isValidDateFormat(String dateString) {
    try {
      parseDate(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 计算年龄
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// 获取时间段描述
  static String getTimePeriodDescription(DateTime start, DateTime end) {
    final startDateStr = formatDate(start);
    final endDateStr = formatDate(end);
    
    if (startDateStr == endDateStr) {
      return getFriendlyDateDescription(start);
    }
    
    final daysDifference = getDaysDifference(start, end);
    
    if (daysDifference == 1) {
      return '${getFriendlyDateDescription(start)} - ${getFriendlyDateDescription(end)}';
    } else if (daysDifference < 7) {
      return '${daysDifference + 1} 天';
    } else if (daysDifference < 30) {
      final weeks = ((daysDifference + 1) / 7).ceil();
      return '$weeks 周';
    } else if (daysDifference < 365) {
      final months = ((daysDifference + 1) / 30).ceil();
      return '$months 个月';
    } else {
      final years = ((daysDifference + 1) / 365).ceil();
      return '$years 年';
    }
  }

  /// 判断是否在指定时间范围内
  static bool isTimeInRange(DateTime time, String startTime, String endTime) {
    try {
      final start = parseTime(startTime, date: time);
      final end = parseTime(endTime, date: time);
      
      if (start.isBefore(end)) {
        // 同一天的时间范围
        return time.isAfter(start.subtract(const Duration(seconds: 1))) &&
               time.isBefore(end.add(const Duration(seconds: 1)));
      } else {
        // 跨天的时间范围（如 22:00 - 06:00）
        return time.isAfter(start.subtract(const Duration(seconds: 1))) ||
               time.isBefore(end.add(const Duration(seconds: 1)));
      }
    } catch (e) {
      return false;
    }
  }

  /// 获取下一个指定时间的DateTime
  static DateTime getNextOccurrence(String timeString, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final targetTime = parseTime(timeString, date: now);
    
    if (targetTime.isAfter(now)) {
      return targetTime;
    } else {
      // 如果目标时间已过，返回明天的该时间
      return targetTime.add(const Duration(days: 1));
    }
  }

  /// 格式化时长（分钟数转为可读格式）
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes 分钟';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours 小时';
      } else {
        return '$hours 小时 $remainingMinutes 分钟';
      }
    } else {
      final days = minutes ~/ 1440;
      final remainingMinutes = minutes % 1440;
      final hours = remainingMinutes ~/ 60;
      final mins = remainingMinutes % 60;
      
      String result = '$days 天';
      if (hours > 0) {
        result += ' $hours 小时';
      }
      if (mins > 0) {
        result += ' $mins 分钟';
      }
      return result;
    }
  }
}