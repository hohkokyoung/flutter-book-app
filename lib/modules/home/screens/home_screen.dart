import 'package:flutter/material.dart';
import 'package:booksum/modules/core/widgets/background_paint.dart';
import 'package:booksum/modules/home/widgets/welcome_bar.dart';
import 'package:booksum/modules/home/widgets/trending_news.dart';
import 'package:booksum/modules/home/widgets/daily_quote.dart';
import 'package:booksum/modules/home/widgets/last_read.dart';
import 'package:booksum/modules/home/widgets/statistics.dart';
import 'package:booksum/modules/home/models/chart_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Statistics(),
                        SizedBox(height: 25),
                        LastRead(),
                        SizedBox(height: 25),
                        DailyQuote(),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  TrendingNews(),
                  SizedBox(height: 60),
                ],
              ),
            ),
            BackgroundPaint(),
            WelcomeBar(),
          ],
        ),
      ),
    );
  }
}
