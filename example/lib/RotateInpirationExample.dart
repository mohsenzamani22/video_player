import 'dart:math' as math;

import 'package:example/blobs.dart';
import 'package:flutter/material.dart';

class RotateInpirationExample extends StatefulWidget {
  const RotateInpirationExample({Key? key}) : super(key: key);

  @override
  _RotateInpirationExampleState createState() =>
      _RotateInpirationExampleState();
}

class _RotateInpirationExampleState extends State<RotateInpirationExample> {
  @override
  void initState() {
    super.initState();
  }

  double degreeToRadian(double degree) {
    return degree * (math.pi / 180);
  }

  double radianToDegree(double radian) {
    return radian * (180 / math.pi);
  }

  List<double> getOriginalPoints(int bands_length) {
    final deg = 360 / bands_length;
    return List.generate(bands_length, (index) => index * deg);
  }

  Offset point(Offset origin, double radius, double degree) {
    double x = origin.dx + (radius * math.cos(degreeToRadian(degree)));
    double y = origin.dy + (radius * math.sin(degreeToRadian(degree)));
    return Offset(x.round().toDouble(), y.round().toDouble());
  }

  double magicPoint(double value, double min, double max) {
    double radius = min + (value * (max - min));
    if (radius > max) {
      radius = radius - min;
    } else if (radius < min) {
      radius = radius + min;
    }
    return radius;
  }

  List<Offset> getDestPoints(int width, int height) {
    double outerRad = width / 2;
    double innerRad = 9 * (outerRad / 10);
    Offset center = Offset(width / 2, height / 2);

    List<double> slices = getOriginalPoints(30);
    List<Offset> originPoints = [];
    List<Offset> destPoints = [];
    double i = 0;

    for (var degree in slices) {
      double O = magicPoint(7, innerRad, outerRad);
      Offset start = point(center, innerRad, degree);
      Offset end = point(center, O, degree);
      originPoints.add(start);
      destPoints.add(end);
      i += .2;
    }
    return destPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: BlobPainter(
                    debug: true,
                    blobData: BlobGenerator(
                      edgesCount: 30,
                      minGrowth: 9,
                      size: Size(200, 200),
                    ).generateFromPoints(getDestPoints(200, 200)),
                  ),
                ),
                // Transform.rotate(
                //   angle: (animation.value * 0.9) * 360.0,
                //   child: Blob.fromID(
                //     size: 200,
                //     id: ['20-9-12'],
                //     styles: BlobStyles(
                //       color: const Color(0x272f00ff),
                //       fillType: BlobFillType.fill,
                //     ),
                //   ),
                // ),
                // Transform.rotate(
                //   angle: animation.value * 360.0,
                //   child: Blob.fromID(
                //     size: 220,
                //     id: ['20-9-14'],
                //     controller: BlobController(),
                //     styles: BlobStyles(
                //       color: const Color(0x402f00ff),
                //       fillType: BlobFillType.fill,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
