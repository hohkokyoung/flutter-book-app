import 'dart:io';

import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/screens/book_pdf_screen.dart';
import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/core/widgets/default_clickable_container.dart';
import 'package:booksum/modules/core/widgets/default_image_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:booksum/modules/home/models/chart_data.dart';

class LastRead extends ConsumerStatefulWidget {
  const LastRead({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LastReadState();
}

class _LastReadState extends ConsumerState<LastRead> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final latestReadBookState = ref.watch(latestReadBookProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last read",
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 375),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: latestReadBookState.when(
            data: (latestReadBook) => LastReadContainer(
              key: const ValueKey<bool>(false),
              latestReadBook: latestReadBook ?? ref.read(bookRepositoryProvider).defaultBooks.first,
              isLoading: false,
            ),
            loading: () => LastReadContainer(
              key: const ValueKey<bool>(true),
              latestReadBook:
                  ref.read(bookRepositoryProvider).defaultBooks.first,
              isLoading: true,
            ),
            error: (error, stack) => Center(child: Text("Error: $error")),
          ),
        ),
      ],
    );
  }
}

class LastReadContainer extends ConsumerWidget {
  final Book latestReadBook;
  final bool isLoading;

  const LastReadContainer({
    super.key,
    required this.latestReadBook,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultClickableContainer(
      isLoading: isLoading,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookPdfScreen(),
          ),
        );
      },
      children: [
        Container(
          decoration: BoxDecoration(
            color: isLoading ? Colors.transparent : Colors.white,
            borderRadius: defaultBorderRadius,
          ),
          child: ListTile(
            horizontalTitleGap: 16,
            visualDensity: const VisualDensity(horizontal: 4, vertical: 1),
            leading: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AspectRatio(
                  aspectRatio: 9 / 12,
                  child: DefaultImageField(
                    imagePath: latestReadBook.imageFilePath,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            title: Container(
              height: isLoading ? 20 : 36,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  latestReadBook.title,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            subtitle: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: isLoading ? 0 : 2),
                child: Text(
                  latestReadBook.author,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryFixedDim,
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  ),
                ),
              ),
            ),
            trailing: SizedBox(
              width: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLoading)
                    Text(
                      "${latestReadBook.readPercentage}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                      ),
                    ),
                  SfCircularChart(
                    series: <CircularSeries>[
                      RadialBarSeries<ChartData, int>(
                        dataSource: [
                          ChartData(
                            0,
                            latestReadBook.readPercentage.toDouble(),
                            Theme.of(context).colorScheme.primary,
                          ),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        pointColorMapper: (ChartData data, _) => data.color,
                        radius: "24",
                        innerRadius: "20",
                        cornerStyle: CornerStyle.bothCurve,
                        maximumValue: 100,
                        trackColor:
                            Theme.of(context).colorScheme.primaryFixedDim,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
