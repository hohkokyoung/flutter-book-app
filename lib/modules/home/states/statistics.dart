import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/home/models/statistics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsNotifier extends StateNotifier<List<Statistics>> {
  final Ref ref;

  static final List<Statistics> _statistics = [
    Statistics(
      duration: const Duration(minutes: 4),
      pages: 2,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Statistics(
      duration: const Duration(minutes: 15),
      pages: 1,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Statistics(
      duration: const Duration(minutes: 3),
      pages: 3,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Initialize with empty list
  StatisticsNotifier(this.ref) : super(_statistics) {
    // Can use it to call an API to fetch notes
  }

  void addStatistics() {
    final now = DateTime.now();

    Statistics? todayStats = state
        .where((stat) =>
            stat.date.year == now.year &&
            stat.date.month == now.month &&
            stat.date.day == now.day)
        .singleOrNull;

    todayStats ??= Statistics(
      date: DateTime.now(),
      duration: Duration.zero,
      pages: 1,
    );

    if (!state.contains(todayStats)) {
      state = [...state, todayStats];
    }
  }

  void updateStatistics(readingStartTime) {
    final now = DateTime.now();

    // calculate the duration difference and create new statistics per one day
    final Duration readDuration = now.difference(readingStartTime);

    final daysPassed = readDuration.inDays;

    bool hasNewStatsCreated = false;

    for (int i = 0; i < daysPassed - 1; i++) {
      final daysLeftAfterSubtract = daysPassed - i;

      final subtractedDate = now.subtract(Duration(days: daysPassed));

      final isStatsCreated = state.any((stat) =>
          stat.date.year == subtractedDate.year &&
          stat.date.month == subtractedDate.month &&
          stat.date.day == subtractedDate.day);

      if (isStatsCreated) continue;

      hasNewStatsCreated = true;

      Duration readDurationStats = now.difference(
          readingStartTime.add(Duration(days: daysLeftAfterSubtract)));

      if (daysLeftAfterSubtract > 1) {
        readDurationStats = const Duration(days: 1);
      }

      Statistics newStats = Statistics(
        date: subtractedDate,
        duration: readDurationStats,
        pages: 1,
      );

      state = [...state, newStats];
    }

    if (!hasNewStatsCreated) {
      Statistics? todayStats = state
          .where((stat) =>
              stat.date.year == now.year &&
              stat.date.month == now.month &&
              stat.date.day == now.day)
          .singleOrNull;

      todayStats ??= Statistics(
        date: DateTime.now(),
        duration: Duration.zero,
        pages: 1,
      );

      if (!state.contains(todayStats)) {
        state = [...state, todayStats];
      } else {
        todayStats = todayStats.copyWith(
          duration: todayStats.duration + readDuration,
          pages: todayStats.pages + 1,
        );

        state = List.from(state)
          ..[state.indexWhere((stat) => stat.date == todayStats!.date)] =
              todayStats;
      }
    }

    ref.read(bookProvider.notifier).updateDurationRead(readDuration);
  }

  int get readStreakDays {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    final yesterdayStats = state
        .where((stat) =>
            stat.date.year == yesterday.year &&
            stat.date.month == yesterday.month &&
            stat.date.day == yesterday.day)
        .singleOrNull;

    if (yesterdayStats == null) {
      return 0;
    }

    final List<DateTime> dates = state.map((e) => e.date).toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort dates in descending order
    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final difference = dates[i].difference(dates[i + 1]).inDays.abs();
      if (difference == 1) {
        streak++;
      } else if (difference > 1) {
        break;
      }
    }
    return streak;
  }

  Duration get durationReadToday {
    final today = DateTime.now();
    final todayStats = state
        .where((stat) =>
            stat.date.year == today.year &&
            stat.date.month == today.month &&
            stat.date.day == today.day)
        .singleOrNull;
    return todayStats?.duration ?? Duration.zero;
  }

  int get pagesReadToday {
    final today = DateTime.now();
    final todayStats = state
        .where((stat) =>
            stat.date.year == today.year &&
            stat.date.month == today.month &&
            stat.date.day == today.day)
        .singleOrNull;
    return todayStats?.pages ?? 0;
  }
}

final statisticsNotifierProvider =
    StateNotifierProvider<StatisticsNotifier, List<Statistics>>((ref) {
  return StatisticsNotifier(ref);
});

final weeklyStatisticsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  // Watch the state of your statistics provider
  final stats = ref.watch(statisticsNotifierProvider);

  // Generate weekly statistics
  final weekStats = List.generate(7, (index) {
    final day = startOfWeek.add(Duration(days: index));
    return {
      'day': weekdays[day.weekday - 1].substring(0, 3),
      'hasRead': stats.any((stat) =>
          stat.date.year == day.year &&
          stat.date.month == day.month &&
          stat.date.day == day.day),
    };
  });

  return weekStats;
});
