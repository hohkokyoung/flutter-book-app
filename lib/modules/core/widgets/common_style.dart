import 'package:flutter/material.dart';

List<BoxShadow> getDefaultBoxShadow(BuildContext context) {
  return [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(.1),
      spreadRadius: 0,
      blurRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];
}

BorderRadiusGeometry get defaultBorderRadius => BorderRadius.circular(10);