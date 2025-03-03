import 'package:flutter/material.dart';

class BackgroundPaint extends StatelessWidget {
  const BackgroundPaint({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: CustomPaint(
          painter: BackgroundPainter(
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.shadow,
          ),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color _color;
  final Color _shadowColor;

  BackgroundPainter(this._color, this._shadowColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;
    final double width = size.width;

    var paint = Paint()
      ..color = _color
      ..strokeWidth = 20.0;

    // Path path = Path();
    // path.moveTo(0, height * 0.14 * 7); // Starting point on the left
    // path.quadraticBezierTo(width * .22, height * .22 * 6, width * .5, height * .1 * 6);
    // path.quadraticBezierTo(
    //     width * .6, height * 0.06 * 6, width * .72, height * .09 * 6);
    // path.quadraticBezierTo(
    //     width * .85, height * 0.12 * 6, width * 1.1, height * .12 * 6);
    // path.lineTo(width, 0); // Draw to the top-right corner
    // path.lineTo(0, 0); // Draw back to the top-left corner
    // path.close(); // Close the path

    double scale = 6;

    Path path = Path();
    path.moveTo(0, height * 0.13 * scale); // Starting point on the left
    path.quadraticBezierTo(
        width * .18, height * .19 * scale, width * .37, height * .14 * scale);
    path.quadraticBezierTo(
        width * .5, height * 0.10 * scale, width * .64, height * .13 * scale);
    path.quadraticBezierTo(
        width * .84, height * 0.182 * scale, width * 1, height * .19 * scale);
    path.lineTo(width, 0); // Draw to the top-right corner
    path.lineTo(0, 0); // Draw back to the top-left corner
    path.close(); //

    canvas.drawShadow(
      path, // The path for the shadow
      _shadowColor, // Shadow color
      5.0, // Shadow elevation (blur intensity)
      true, // Transparent object casting the shadow (false if solid)
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
