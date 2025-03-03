import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class BookmarkPainter extends CustomPainter {
  final Color _color;
  final Color _shadowColor;

  BookmarkPainter(this._color, this._shadowColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;
    final double width = size.width;

    var paint = Paint()
      ..color = _color
      ..strokeWidth = 20.0;

    Path path = Path();
    // path.moveTo(0, height * 0.13 * scale); // Starting point on the left
    path.lineTo(0, height); // Draw to the top-right corner
    path.lineTo(width / 2, max(height - 4, 0)); // Draw to the top-right corner
    path.lineTo(width, height); // Draw to the top-right corner
    path.lineTo(width, 0); // Draw back to the top-left corner
    path.close(); //

    canvas.drawShadow(
      path, // The path for the shadow
      _shadowColor, // Shadow color
      2.0, // Shadow elevation (blur intensity)
      true, // Transparent object casting the shadow (false if solid)
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}