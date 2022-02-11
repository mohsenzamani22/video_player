import 'dart:math' as math;

import 'package:cache_video_player/interface/video_player_platform_interface.dart';
import 'package:example/collection.dart';
import 'package:example/num.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FFTBand extends StatefulWidget {
  final VideoSpectrumEvent? spectrumEvent;

  FFTBand({Key? key, this.spectrumEvent}) : super(key: key);

  @override
  State<FFTBand> createState() => _FFTBandState();
}

class _FFTBandState extends State<FFTBand> {
  final int SAMPLE_SIZE = 4096;
  final List<double> FREQUENCY_BAND_LIMITS = const [
    20,
    25,
    31.5,
    40,
    50,
    63,
    80,
    100,
    125,
    160,
    200,
    250,
    315,
    400,
    500,
    630,
    800,
    1000,
    1250,
    1600,
    2000,
    2500,
    3150,
    4000,
    5000,
    6300,
    8000,
    10000,
    12500,
    16000,
    20000
  ];

  late int bands = FREQUENCY_BAND_LIMITS.length;
  late int size = SAMPLE_SIZE ~/ 2;
  final int maxConst = 4000;
  late List<double> fft = List.filled(size, 0.0);
  final int smoothingFactor = 3;
  late List<double> previousValues = List.filled(bands * smoothingFactor, 0.0);
  int startedAt = 0;
  late Size _size;
  final int minGrowth = 8;
  final Size spectrumSize = const Size(200, 200);

  @override
  void initState() {
    super.initState();
  }

  double coerceAtMost(double target, double maximumValue) {
    return target > maximumValue ? maximumValue : target;
  }

  Map<String, dynamic> parseFFTdata(double width, double height) {
    Map<String, dynamic> res = {};
    fft.setRange(0, size, widget.spectrumEvent?.fft ?? [], 2);
    List<double> bars = [];
    int currentFftPosition = 0;
    int currentFrequencyBandLimitIndex = 0;

    double currentAverage = 0;
    while (currentFftPosition < size) {
      double accum = 0;

      int nextLimitAtPosition = (FREQUENCY_BAND_LIMITS[currentFrequencyBandLimitIndex] / 20000 * size).floor().toInt();

      for (int j = 0; j < (nextLimitAtPosition - currentFftPosition); j += 2) {
        double raw =
            (math.pow(fft[currentFftPosition + j], 2.0) + math.pow(fft[currentFftPosition + j + 1], 2.0)).toDouble();

        double m = bands / 2;
        double windowed = raw * (0.54 + 0.46 * math.cos((currentFrequencyBandLimitIndex - m) * math.pi / (m + 1)));
        accum += windowed;
      }

      if (nextLimitAtPosition - currentFftPosition != 0) {
        accum /= (nextLimitAtPosition - currentFftPosition);
      } else {
        accum = 0.0;
      }
      currentFftPosition = nextLimitAtPosition;

      double smoothedAccum = accum;
      for (int i = 0; i < smoothingFactor; i++) {
        smoothedAccum += previousValues[i * bands + currentFrequencyBandLimitIndex];
        if (i != smoothingFactor - 1) {
          previousValues[i * bands + currentFrequencyBandLimitIndex] =
              previousValues[(i + 1) * bands + currentFrequencyBandLimitIndex];
        } else {
          previousValues[i * bands + currentFrequencyBandLimitIndex] = accum;
        }
      }
      smoothedAccum /= (smoothingFactor + 1);

      currentAverage += smoothedAccum / bands;

      double barHeight = (height * coerceAtMost(smoothedAccum / maxConst, 1.0));
      bars.add(barHeight);

      currentFrequencyBandLimitIndex++;
    }

    res = {
      "avg": height * (1 - (currentAverage / maxConst)),
      "bars": bars,
    };
    return res;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    Map<String, dynamic> spectrum = parseFFTdata(_size.width, 1);
    return Stack(
      children: [
        SizedBox.fromSize(
          size: spectrumSize,
          child: CustomPaint(
            painter: SpectrumPainter(
              color: const Color(0x40002AFF),
              paintingStyle: PaintingStyle.stroke,
              spectrumData: spectrum["bars"] as List<double>,
              minGrowth: minGrowth,
            ),
            isComplex: true,
          ),
        ),
        SizedBox.fromSize(
          size: spectrumSize,
          child: Transform.rotate(
            angle: -math.pi / (spectrum["avg"] * 2),
            child: CustomPaint(
              painter: SpectrumPainter(
                // debug: true,
                color: const Color(0x40FF0000),

                paintingStyle: PaintingStyle.fill,
                spectrumData: spectrum["bars"] as List<double>,
                minGrowth: minGrowth,
              ),
              isComplex: true,
            ),
          ),
        ),
        SizedBox(
          height: spectrumSize.height,
          width: spectrumSize.width,
          child: UnconstrainedBox(
            child: Image.network(
              "https://upermall.ir/assets/favicon.png",
              height: spectrumSize.height / 2,
              width: spectrumSize.width / 2,
            ),
          ),
        ),
      ],
    );
  }
}

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

    var path = Path();
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

    var path = Path();
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
