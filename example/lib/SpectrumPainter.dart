import 'dart:math' as math;

import 'package:example/collection.dart';
import 'package:example/num.dart';
import 'package:flutter/material.dart';

class SpectrumPainter extends CustomPainter {
  final List<double> spectrumData;
  final int minGrowth;
  final Color color;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final bool debug;

  SpectrumPainter({
    required this.spectrumData,
    this.minGrowth = 8,
    this.color = Colors.blue,
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 3,
    this.debug = false,
  });

  double _magicPoint(double value, double min, double max) {
    double radius = min + (value * (max - min));
    if (radius > max) {
      radius = radius - min;
    } else if (radius < min) {
      radius = radius + min;
    }
    return radius;
  }

  Offset _point(Offset origin, double radius, double degree) {
    double x = origin.dx + (radius * math.cos(degree.toRadian()));
    double y = origin.dy + (radius * math.sin(degree.toRadian()));
    return Offset(x.round().toDouble(), y.round().toDouble());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double circleSliceDegree = 360 / spectrumData.length;
    final double outerRad = size.width / 2;
    final double innerRad = minGrowth * (outerRad / 10);
    final Offset center = Offset(size.width / 2, size.height / 2);

    List<Offset> originPoints = [];
    List<Offset> destPoints = [];

    spectrumData.forEachIndexed((int index, double bandHeight) {
      double currentDegree = index * circleSliceDegree;
      double O = _magicPoint(bandHeight, innerRad, outerRad);
      Offset start = _point(center, innerRad, currentDegree);
      Offset end = _point(center, O, currentDegree);
      originPoints.add(start);
      destPoints.add(end);
    });

    Offset mid = (destPoints[0] + destPoints[1]) / 2;
    Path path = Path();
    path.moveTo(mid.dx, mid.dy);

    for (int i = 0; i < destPoints.length; i++) {
      Offset point1 = destPoints[(i + 1) % destPoints.length];
      Offset point2 = destPoints[(i + 2) % destPoints.length];
      mid = (point1 + point2) / 2;
      path.quadraticBezierTo(point1.dx, point1.dy, mid.dx, mid.dy);
    }
    path.close();

    Paint paint = Paint();
    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.style = paintingStyle;

    canvas.drawPath(path, paint);

    if (debug) {
      _drawCircle(canvas, center, outerRad);
      _drawCircle(canvas, center, innerRad);
      _drawDot(canvas, center);
      originPoints.forEachIndexed(
        (index, point) => _drawLines(canvas, point, destPoints[index]),
      );
    }
  }

  _drawLine(Canvas canvas, Offset start, Offset end) {
    Paint paint = Paint();
    paint.color = Color(0xff596275).withOpacity(0.5);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  _drawCircle(Canvas canvas, Offset center, double radius) {
    Paint paint = Paint();
    paint.color = Color(0xffef5777);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;

    Path path = Path();
    path.addOval(Rect.fromCircle(
      center: center,
      radius: radius,
    ));
    canvas.drawPath(path, paint);
  }

  _drawDot(Canvas canvas, Offset center) {
    Paint paint = Paint();
    paint.color = Color(0xff1e272e);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.fill;
    paint.strokeCap = StrokeCap.round;

    Path path = Path();
    path.addOval(Rect.fromCircle(
      center: center,
      radius: 3,
    ));
    canvas.drawPath(path, paint);
  }

  _drawLines(Canvas c, Offset p0, Offset p1) {
    _drawDot(c, p0);
    _drawDot(c, p1);
    _drawLine(c, p0, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
