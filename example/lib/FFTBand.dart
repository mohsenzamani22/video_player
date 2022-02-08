import 'dart:math' as math;

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
    32,
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
  final int maxConst = 25000;
  late List<double> fft = List.filled(size, 0.0);
  final int smoothingFactor = 3;
  late List<double> previousValues = List.filled(bands * smoothingFactor, 0.0);
  int startedAt = 0;
  late Size _size;
  @override
  void initState() {
    super.initState();
  }

  double coerceAtMost(double target, double maximumValue) =>
      target > maximumValue ? maximumValue : target;
  getAudio() {
    List.copyRange(fft, 0, widget.spectrumEvent?.fft ?? [], 0, size);
    // print("fft: ${fft.length}, fft: ${widget.spectrumEvent?.fft}");

    int currentFftPosition = 0;
    int currentFrequencyBandLimitIndex = 0;

    double currentAverage = 0;

    while (currentFftPosition < size) {
      double accum = 0;

      int nextLimitAtPosition =
          (FREQUENCY_BAND_LIMITS[currentFrequencyBandLimitIndex] /
                  20000.0 *
                  size)
              .floor()
              .toInt();

      for (int j = 0; j < (nextLimitAtPosition - currentFftPosition); j += 2) {
        double raw = (math.pow(fft[currentFftPosition + j].toDouble(), 2.0) +
                math.pow(fft[currentFftPosition + j + 1].toDouble(), 2.0))
            .toDouble();

        double m = bands / 2;
        double windowed = raw *
            (0.54 +
                    0.46 *
                        math.cos((currentFrequencyBandLimitIndex - m) *
                            math.pi /
                            (m + 1)))
                .toDouble();
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

      double leftX =
          _size.width * (currentFrequencyBandLimitIndex / bands.toDouble());
      double rightX = leftX + _size.width / bands.toDouble();

      double barHeight = (_size.height *
              coerceAtMost(smoothedAccum / maxConst.toDouble(), 1.0))
          .toDouble();
      double top = _size.height - barHeight;
      print(
          "currentAverage: $currentAverage, barHeight: $barHeight, leftX: $leftX, rightX: $rightX");
      currentFrequencyBandLimitIndex++;
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    getAudio();
    return Container(
      height: 100,
      width: 100,
      color: Colors.red,
    );
  }
}
