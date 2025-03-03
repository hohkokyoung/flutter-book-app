import 'package:flutter/material.dart';

class FloatingBottomButton extends StatelessWidget {
  const FloatingBottomButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      shape: const CircleBorder(),
      onPressed: () {},
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.secondary,
      elevation: 10,
      child: const Icon(Icons.add),
    );
  }
}
