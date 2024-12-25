class DateUtils {
  static String getCurrentMonth() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }
}
