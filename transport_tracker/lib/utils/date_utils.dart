/// Returns a [DateTime] representing the date portion (year, month, day) of [dt].
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Returns the first day of the week (Monday) for [dt].
DateTime startOfWeek(DateTime dt) {
  final d = dateOnly(dt);
  final weekday = d.weekday; // 1=Mon..7=Sun
  return d.subtract(Duration(days: weekday - 1));
}

/// Returns the last day (Sunday) of the week for [dt].
DateTime endOfWeek(DateTime dt) {
  final start = startOfWeek(dt);
  return start.add(const Duration(days: 6));
}

/// Returns the first day of the month for [dt].
DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

/// Returns the last day of the month for [dt].
DateTime endOfMonth(DateTime dt) {
  final firstNext = (dt.month == 12)
      ? DateTime(dt.year + 1, 1, 1)
      : DateTime(dt.year, dt.month + 1, 1);
  return firstNext.subtract(const Duration(days: 1));
}