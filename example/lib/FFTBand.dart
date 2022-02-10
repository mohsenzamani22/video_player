import 'dart:math' as math;

import 'package:cache_video_player/interface/video_player_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'blobs.dart';

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
  final int smoothingFactor = 1;
  late List<double> previousValues = List.filled(bands * smoothingFactor, 0.0);
  int startedAt = 0;
  late Size _size;
  final int minGrowth = 8;
  final Size spectrumSize = Size(200, 200);
  @override
  void initState() {
    super.initState();
  }

  double coerceAtMost(double target, double maximumValue) {
    return target > maximumValue ? maximumValue : target;
  }

  Map<String, dynamic> getAudio(double width, double height) {
    Map<String, dynamic> res = {};
    print(widget.spectrumEvent?.fft);
    fft.setRange(0, size, widget.spectrumEvent?.fft ?? [], 2);
    List<double> bars = [];
    int currentFftPosition = 0;
    int currentFrequencyBandLimitIndex = 0;

    double currentAverage = 0;
    while (currentFftPosition < size) {
      double accum = 0;

      int nextLimitAtPosition =
          (FREQUENCY_BAND_LIMITS[currentFrequencyBandLimitIndex] / 20000 * size)
              .floor()
              .toInt();

      for (int j = 0; j < (nextLimitAtPosition - currentFftPosition); j += 2) {
        double raw = (math.pow(fft[currentFftPosition + j], 2.0) +
                math.pow(fft[currentFftPosition + j + 1], 2.0))
            .toDouble();

        double m = bands / 2;
        double windowed = raw *
            (0.54 +
                0.46 *
                    math.cos((currentFrequencyBandLimitIndex - m) *
                        math.pi /
                        (m + 1)));
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
        smoothedAccum +=
            previousValues[i * bands + currentFrequencyBandLimitIndex];
        if (i != smoothingFactor - 1) {
          previousValues[i * bands + currentFrequencyBandLimitIndex] =
              previousValues[(i + 1) * bands + currentFrequencyBandLimitIndex];
        } else {
          previousValues[i * bands + currentFrequencyBandLimitIndex] = accum;
        }
      }
      smoothedAccum /= (smoothingFactor + 1);

      currentAverage += smoothedAccum / bands;
      // double leftX = width * (currentFrequencyBandLimitIndex / bands);
      // double rightX = leftX + width / bands;
      // double top = height - barHeight;

      double barHeight = (height * coerceAtMost(smoothedAccum / maxConst, 1.0));
      bars.add(barHeight);

      currentFrequencyBandLimitIndex++;
    }

    res = {
      "avg": height * (1 - (currentAverage / maxConst)),
      "bar": bars,
    };
    return res;
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

  List<Offset> getDestPoints(List<double> a) {
    double outerRad = spectrumSize.width / 2;
    double innerRad = minGrowth * (outerRad / 10);
    Offset center = Offset(spectrumSize.width / 2, spectrumSize.height / 2);

    List<double> slices = getOriginalPoints(a.length);
    List<Offset> originPoints = [];
    List<Offset> destPoints = [];
    int i = 0;

    for (var degree in slices) {
      double O = magicPoint(a[i], innerRad, outerRad);
      Offset start = point(center, innerRad, degree);
      Offset end = point(center, O, degree);
      originPoints.add(start);
      destPoints.add(end);
      i++;
    }
    return destPoints;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    Map<String, dynamic> a = getAudio(_size.width, 1);
    // print(a["avg"]);
    return Stack(
      children: [
        SizedBox(
          height: spectrumSize.height,
          width: spectrumSize.width,
          child: CustomPaint(
            painter: BlobPainter(
              debug: false,
              styles: BlobStyles(
                color: Color(0x40002AFF),
              ),
              // debug: true,
              blobData: BlobGenerator(
                edgesCount: (a["bar"] as List<double>).length,
                minGrowth: minGrowth,
                size: spectrumSize,
              ).generateFromPoints(getDestPoints((a["bar"] as List<double>))),
            ),
          ),
        ),
        SizedBox(
          height: spectrumSize.height,
          width: spectrumSize.width,
          child: Transform.scale(
            scale: math.min(math.max(.5, a["avg"]), 1.5),
            child: CustomPaint(
              painter: BlobPainter(
                debug: false,
                styles: BlobStyles(
                  color: Color(0x40002AFF),
                ),
                // debug: true,
                blobData: BlobGenerator(
                  edgesCount: (a["bar"] as List<double>).length,
                  minGrowth: minGrowth,
                  size: spectrumSize,
                ).generateFromPoints(getDestPoints(
                    (a["bar"] as List<double>).reversed.toList())),
              ),
            ),
          ),
        ),
        SizedBox(
          height: spectrumSize.height,
          width: spectrumSize.width,
          child: UnconstrainedBox(
            child: Image.network(
              "https://upermall.ir/assets/favicon.png",
              height: 100 / 2,
              width: 100 / 2,
            ),
          ),
        ),
      ],
    );
  }
}
