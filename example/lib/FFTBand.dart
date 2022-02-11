import 'dart:math' as math;

import 'package:cache_video_player/interface/video_player_platform_interface.dart';
import 'package:example/SpectrumPainter.dart';
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
  late Size _screenSize;

  late int bands = FREQUENCY_BAND_LIMITS.length;
  late int size = SAMPLE_SIZE ~/ 2;
  late List<double> fft = List.filled(size, 0.0);
  late List<double> previousValues = List.filled(bands * smoothingFactor, 0.0);

  final int maxConst = 4000;
  final int smoothingFactor = 3;
  int startedAt = 0;
  final int minGrowth = 8;
  final Size spectrumSize = const Size(100, 100);

  @override
  void initState() {
    super.initState();
  }

  double coerceAtMost(double target, double maximumValue) {
    return target > maximumValue ? maximumValue : target;
  }

  Map<String, dynamic> analyzeFFTData(double maxSpectrumHeight) {
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

      double barHeight = (maxSpectrumHeight * coerceAtMost(smoothedAccum / maxConst, 1.0));
      bars.add(barHeight);

      currentFrequencyBandLimitIndex++;
    }

    res = {
      "avg": maxSpectrumHeight * (1 - (currentAverage / maxConst)),
      "bars": bars,
    };
    return res;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> spectrum = analyzeFFTData(1);
    return Stack(
      children: [
        SizedBox.fromSize(
          size: spectrumSize,
          child: CustomPaint(
            painter: SpectrumPainter(
              color: Color(0xff4ac7b7).withOpacity(.5),
              paintingStyle: PaintingStyle.fill,
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
                color: Color(0xff0092ff).withOpacity(.5),

                paintingStyle: PaintingStyle.fill,
                spectrumData: spectrum["bars"] as List<double>,
                minGrowth: minGrowth,
              ),
              isComplex: true,
            ),
          ),
        ),
        SizedBox.fromSize(
          size: spectrumSize,
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
