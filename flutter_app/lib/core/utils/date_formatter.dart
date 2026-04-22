/// Returns a human-readable relative timestamp for display in note cards.
/// Examples: "just now", "5 min ago", "2 hr ago", "yesterday", "Apr 21", "21 Apr 2024"
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m min ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h hr ago';
  }

  final today = DateTime(now.year, now.month, now.day);
  final dayOf = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final daysDiff = today.difference(dayOf).inDays;

  if (daysDiff == 1) return 'yesterday';

  final month = _monthAbbr(dateTime.month);
  if (dateTime.year == now.year) return '$month ${dateTime.day}';
  return '$month ${dateTime.day}, ${dateTime.year}';
}

String _monthAbbr(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];
