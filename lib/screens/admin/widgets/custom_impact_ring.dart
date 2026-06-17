import 'package:flutter/material.dart';
import 'dart:math';

class CustomImpactRing extends StatelessWidget {
  final double progress; 
  final double size;

  const CustomImpactRing({Key? key, required this.progress, this.size = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
        child: Center(
          child: Icon(Icons.eco, color: Colors.green[800], size: size * 0.5),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 3.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    double angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}