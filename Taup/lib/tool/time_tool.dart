class TimeTool {
  static String countFile(int size) {
    if (size / 1024 < 1) {
      return '${size}B';
    } else if (size / 1024 < 1024) {
      String fileSize = (size / 1024).toStringAsFixed(2);
      return '${fileSize}KB';
    } else if (size / 1024 / 1024 < 1024) {
      String fileSize = (size / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}MB';
    } else {
      String fileSize = (size / 1024 / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}GB';
    }
  }

  static int millisecondsSince() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static String formatString(int seconds) {
    if (seconds == 0) return '00:00';
    int hour = seconds ~/ 3600;
    int minute = (seconds % 3600) ~/ 60;
    int second = seconds % 60;
    if (hour > 0) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    } else {
      return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    }
  }

  static String formatYmd(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  static String formatYmdHm(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
