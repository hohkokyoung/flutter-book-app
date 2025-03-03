import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/home/states/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Statistics extends ConsumerWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Stats",
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "Details >>",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius:  defaultBorderRadius,
            boxShadow: getDefaultBoxShadow(context)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReadCompletionDays(),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timelapse_sharp,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${ref.read(statisticsNotifierProvider.notifier).durationReadToday.inMinutes} minutes",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${ref.read(statisticsNotifierProvider.notifier).pagesReadToday} pages",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_sharp,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${ref.read(statisticsNotifierProvider.notifier).readStreakDays} days",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReadCompletionDays extends ConsumerWidget {
  const ReadCompletionDays({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _buildDaysOfWeek(context, ref),
    );
  }

  List<Widget> _buildDaysOfWeek(BuildContext context, WidgetRef ref) {
    final weeklyStatistics =
        ref.watch(weeklyStatisticsProvider);

    return weeklyStatistics.map((dailyStatistics) {
      return Column(
        children: [
          Text(
            dailyStatistics["day"],
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            ),
          ),
          Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: dailyStatistics["hasRead"]
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryFixedDim,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}