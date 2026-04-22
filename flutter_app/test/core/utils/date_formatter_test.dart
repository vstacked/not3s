import 'package:flutter_test/flutter_test.dart';
import 'package:not3s/core/utils/date_formatter.dart';

void main() {
  group('formatRelativeTime', () {
    // ── Seconds ──────────────────────────────────────────────────────────────

    test('returns "just now" for 0 seconds ago', () {
      expect(formatRelativeTime(DateTime.now()), 'just now');
    });

    test('returns "just now" for 30 seconds ago', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 30));
      expect(formatRelativeTime(dt), 'just now');
    });

    test('returns "just now" for 59 seconds ago', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 59));
      expect(formatRelativeTime(dt), 'just now');
    });

    // ── Boundary at 60 s ────────────────────────────────────────────────────

    test('returns "1 min ago" at exactly 60 seconds', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 60));
      expect(formatRelativeTime(dt), '1 min ago');
    });

    // ── Minutes ──────────────────────────────────────────────────────────────

    test('returns "5 min ago" for 5 minutes ago', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(formatRelativeTime(dt), '5 min ago');
    });

    test('returns "59 min ago" for 59 minutes ago', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 59));
      expect(formatRelativeTime(dt), '59 min ago');
    });

    // ── Boundary at 60 min ───────────────────────────────────────────────────

    test('returns "1 hr ago" at exactly 60 minutes', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 60));
      expect(formatRelativeTime(dt), '1 hr ago');
    });

    // ── Hours ─────────────────────────────────────────────────────────────────

    test('returns "2 hr ago" for 2 hours ago', () {
      final dt = DateTime.now().subtract(const Duration(hours: 2));
      expect(formatRelativeTime(dt), '2 hr ago');
    });

    test('returns "23 hr ago" for 23 hours ago', () {
      final dt = DateTime.now().subtract(const Duration(hours: 23));
      expect(formatRelativeTime(dt), '23 hr ago');
    });

    // ── Yesterday ─────────────────────────────────────────────────────────────

    test('returns "yesterday" for previous calendar day', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      expect(formatRelativeTime(yesterday), 'yesterday');
    });

    // ── Same year ─────────────────────────────────────────────────────────────

    test('returns "Jan 15" for Jan 15 of current year (when not today)', () {
      final now = DateTime.now();
      // Only valid when today is not Jan 15 or 16
      if (now.month == 1 && (now.day == 15 || now.day == 16)) return;
      final sameYear = DateTime(now.year, 1, 15);
      expect(formatRelativeTime(sameYear), 'Jan 15');
    });

    test('returns "Apr 1" format for same year using correct month abbr', () {
      final now = DateTime.now();
      if (now.month == 4 && now.day <= 2) return;
      final dt = DateTime(now.year, 4, 1);
      expect(formatRelativeTime(dt), 'Apr 1');
    });

    // ── Previous year ─────────────────────────────────────────────────────────

    test('returns "Apr 5, 2023" for a date in a previous year', () {
      expect(formatRelativeTime(DateTime(2023, 4, 5)), 'Apr 5, 2023');
    });

    test('returns correct format for December 31, 2020', () {
      expect(formatRelativeTime(DateTime(2020, 12, 31)), 'Dec 31, 2020');
    });

    // ── Month abbreviations ───────────────────────────────────────────────────

    test('all 12 month abbreviations are correct', () {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      for (var i = 1; i <= 12; i++) {
        final result = formatRelativeTime(DateTime(2020, i, 1));
        expect(result, '${months[i - 1]} 1, 2020', reason: 'Month $i');
      }
    });

    // ── Edge cases ────────────────────────────────────────────────────────────

    test('future timestamps return "just now" (negative diff < 60 s)', () {
      final future = DateTime.now().add(const Duration(minutes: 5));
      // diff is negative; diff.inSeconds < 60, so returns 'just now'
      expect(formatRelativeTime(future), 'just now');
    });

    test('handles leap-year date Feb 29', () {
      expect(formatRelativeTime(DateTime(2024, 2, 29)), 'Feb 29, 2024');
    });

    test('handles start-of-epoch date gracefully', () {
      // Very old date should fall through to month+day+year format
      final result = formatRelativeTime(DateTime(1970, 1, 1));
      expect(result, 'Jan 1, 1970');
    });
  });
}
