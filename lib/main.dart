import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/models/enum.dart';
import 'package:booksum/modules/books/screens/book_detail_screen.dart';
import 'package:booksum/modules/books/screens/book_list_screen.dart';
import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/core/models/enum.dart';
import 'package:booksum/modules/home/screens/home_screen.dart';
import 'package:booksum/modules/home/widgets/bottom_navigation_bar.dart';
import 'package:booksum/modules/home/widgets/floating_bottom_button.dart';
import 'package:booksum/modules/quotes/screens/quote_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(const ProviderScope(child: BookSum()));
}

class BookSum extends StatefulWidget {
  const BookSum({super.key});

  @override
  State<BookSum> createState() => _BookSumState();
}

class _BookSumState extends State<BookSum> {
  int _activeIndex = 0;
  // List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const BookListScreen(),
    const QuoteListScreen(),
    // const NewsScreen(),
    // const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _activeIndex = index; // Update active index on tab tap
    });
  }

  static const Color primaryColor = Color.fromARGB(255, 32, 147, 185);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    return MaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        // Calculate the scaled text factor using the clamp function to ensure it stays within a specified range.
        final scale = mediaQuery.textScaler.clamp(
          minScaleFactor: 1.0, // Minimum scale factor allowed.
          maxScaleFactor: 1.3, // Maximum scale factor allowed.
        );

        return MediaQuery(
          // Copy the original MediaQueryData and replace the textScaler with the calculated scale.
          data: mediaQuery.copyWith(
            textScaler: scale,
          ),
          // Pass the original child widget to maintain the widget hierarchy.
          child: child!,
        );
      },
      title: 'BookSum',
      theme: ThemeData(
        fontFamily: 'Lexend',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22),
          titleMedium: TextStyle(fontSize: 16.0),
          titleSmall: TextStyle(fontSize: 12.0),
          bodySmall: TextStyle(fontSize: 10.0),
          bodyMedium: TextStyle(fontSize: 12.0),
          bodyLarge: TextStyle(fontSize: 14.0),
          labelSmall: TextStyle(fontSize: 10.0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          primaryFixedDim: const Color.fromARGB(255, 160, 202, 216),
          onPrimary: Colors.white,
          secondary: const Color.fromARGB(255, 0, 0, 0),
          onSecondary: Colors.white,
          secondaryFixedDim: const Color.fromARGB(255, 165, 165, 165),
          tertiary: const Color.fromARGB(255, 252, 178, 42),
          surface: Colors.white,
          surfaceDim: const Color.fromARGB(255, 221, 230, 233),
          // surfaceDim: const Color.fromARGB(255, 211, 236, 245),
          shadow: Colors.black,
          error: const Color.fromARGB(255, 170, 40, 40),
        ),
        useMaterial3: true,
      ),
      home: Consumer(
        builder: (context, ref, child) => Scaffold(
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
            child: FloatingActionButton.small(
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                ref.read(bookProvider.notifier).selectTemporaryBook();
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: const BookDetailScreen(
                      screenState: ScreenState.edit,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          body: _screens[_activeIndex],
          bottomNavigationBar: CurvedBottomNavigationBar(
            activeIndex: _activeIndex,
            onTabTapped: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
