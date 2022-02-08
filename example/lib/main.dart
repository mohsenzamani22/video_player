import 'package:blobs/blobs.dart';
import 'package:cache_video_player/interface/video_player_platform_interface.dart';
import 'package:cache_video_player/player/video_player.dart';
import 'package:example/FFTBand.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: _App()));
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text('Video player example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud),
                text: "Remote",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _BumbleBeeRemoteVideo(),
          ],
        ),
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
      'https://dv174.toakiiikarrrt.xyz/dl/2VeYkS6FfM8/1644333730/0db2f6ffc5d1d467c1330aa429f64b65efbf9ca541e74f810bc6286c4b5149a8?file=aHR0cHM6Ly9ycjEtLS1zbi00ZzVlNm5zei5nb29nbGV2aWRlby5jb20vdmlkZW9wbGF5YmFjaz9leHBpcmU9MTY0NDMzMTc4MyZlaT1weTRDWXNyT012LUI2ZHNQODRTbTRBVSZpcD0xOTUuMjAxLjEwOS4yOSZpZD1vLUFEWFlZMmduZS1hTlAtYm4xaGxvdS0yLTd0ejkwcFI1bGJzRHM2bDBYUnVUJml0YWc9MjImc291cmNlPXlvdXR1YmUmcmVxdWlyZXNzbD15ZXMmbWg9SXgmbW09MzElMkMyOSZtbj1zbi00ZzVlNm5zeiUyQ3NuLTRnNWVkbnN5Jm1zPWF1JTJDcmR1Jm12PW0mbXZpPTEmcGw9MjUmdnBydj0xJm1pbWU9dmlkZW8lMkZtcDQmY25yPTE0JnJhdGVieXBhc3M9eWVzJmR1cj0yMDQuNjM3JmxtdD0xNjA4OTg5MzQ3MzI1MDE0Jm10PTE2NDQzMDk5MDEmZnZpcD0xJmZleHA9MjQwMDEzNzMlMkMyNDAwNzI0NiZjPUFORFJPSUQmdHhwPTU1MzU0MzImc3BhcmFtcz1leHBpcmUlMkNlaSUyQ2lwJTJDaWQlMkNpdGFnJTJDc291cmNlJTJDcmVxdWlyZXNzbCUyQ3ZwcnYlMkNtaW1lJTJDY25yJTJDcmF0ZWJ5cGFzcyUyQ2R1ciUyQ2xtdCZzaWc9QU9xMFFKOHdSUUlnSDBVZDdReWlaNjh2QmszajRrSEtTV1FZTGQwSDQtU013ekVRRFhDTDg4VUNJUURyWWcwZkVNeU52MkZKekFzUWVpOHQzLTh3UElDbTNfSmdsT0NieTAxZ2hBJTNEJTNEJmxzcGFyYW1zPW1oJTJDbW0lMkNtbiUyQ21zJTJDbXYlMkNtdmklMkNwbCZsc2lnPUFHM0NfeEF3UkFJZ0w0SFZvcXBxVVE0aUI5Y0hXR1dqdms3RElOMWpCQlg2TTFvYVFZNmN1WTBDSUhCRGxNVzVGYjZRT3VHajhUZmx1M08tRHkzSlMySTNGeU9xSVN4Y0diVlAmaG9zdD1ycjEtLS1zbi00ZzVlNm5zei5nb29nbGV2aWRlby5jb20mbmFtZT15dDVzLmNvbS1HdXN0YXZvK1NhbnRhb2xhbGxhKy0rQmFiZWwrKE90bmlja2ErUmVtaXgpKyU3YytUb20rSGFyZHkrJTI3VGhlK0dhbmdzdGVyJTI3KDcyMHApLm1wNA',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.setLooping(true);

    _controller.initialize().then((value) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox.square(
              dimension: 250,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  ClosedCaption(text: _controller.value.caption.text),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
          StreamBuilder<VideoSpectrumEvent>(
            // initialData: VideoSpectrumEvent(1600, 2,[10.2]),
            stream: _controller.spectrum,
            builder: (BuildContext context,
                AsyncSnapshot<VideoSpectrumEvent> snapshot) {
              // print("fft data: ${snapshot.data?.fft}");
              if (snapshot.hasData) {
                return FFTBand(spectrumEvent: snapshot.data);
              } else {
                return Text("Waiting for new random number...");
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _exampleCaptionOffsets = [
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration(milliseconds: 0),
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        // Align(
        //   alignment: Alignment.topLeft,
        //   child: PopupMenuButton<Duration>(
        //     initialValue: controller.value.captionOffset,
        //     tooltip: 'Caption Offset',
        //     onSelected: (delay) {},
        //     itemBuilder: (context) {
        //       return [
        //         for (final offsetDuration in _exampleCaptionOffsets)
        //           PopupMenuItem(
        //             value: offsetDuration,
        //             child: Text('${offsetDuration.inMilliseconds}ms'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
