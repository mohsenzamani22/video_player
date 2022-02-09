import 'dart:math' as math;

import 'package:blobs/blobs.dart';
import 'package:cache_video_player/interface/video_player_platform_interface.dart';
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

  @override
  void initState() {
    super.initState();
  }

  double coerceAtMost(double target, double maximumValue) {
    return target > maximumValue ? maximumValue : target;
  }

  List<double> getAudio(double width, double height) {
    fft.setRange(0, size, widget.spectrumEvent?.fft ?? [], 2);
    List<double> bars = [];
    int currentFftPosition = 0;
    int currentFrequencyBandLimitIndex = 0;

    double currentAverage = 0;
    print("-" * 100);
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
      print("barHeight: $barHeight");
      bars.add(barHeight);

      currentFrequencyBandLimitIndex++;
    }
    print("-" * 100);

    print("avg: ${height * (1 - (currentAverage / maxConst))}");
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    List<double> a = getAudio(_size.width, 100);
    return SizedBox(
      height: 100,
      width: _size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        // mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: a
            .map((e) => Container(
                  width: 10,
                  height: e,
                  color: Colors.red,
                  // duration: Duration(milliseconds: 500),
                ))
            .toList(),
      ),
    );
  }
}
