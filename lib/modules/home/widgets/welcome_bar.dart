import 'package:flutter/material.dart';

class WelcomeBar extends StatelessWidget {
  const WelcomeBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              "Welcome back, Kelvin",
              style: TextStyle(
                fontSize:
                    Theme.of(context).textTheme.titleLarge?.fontSize,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          const Icon(Icons.notifications),
        ],
      ),
    );
  }
}
