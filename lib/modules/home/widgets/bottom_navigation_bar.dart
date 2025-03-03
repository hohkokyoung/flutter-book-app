import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CurvedBottomNavigationBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTapped; // Callback for tab taps

  const CurvedBottomNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      icons: const [
        Icons.home,
        Icons.book_outlined,
        Icons.newspaper,
        Icons.person,
      ],
      activeIndex: activeIndex,
      gapLocation: GapLocation.center,
      leftCornerRadius: 24,
      rightCornerRadius: 24,
      notchSmoothness: NotchSmoothness.softEdge,
      backgroundColor: Theme.of(context).colorScheme.primary,
      activeColor: Theme.of(context).colorScheme.tertiary,
      splashColor: Theme.of(context).colorScheme.tertiary,
      inactiveColor: Theme.of(context).colorScheme.secondary,
      onTap: onTabTapped, // Notify the parent on tab tap
    );
  }
}
