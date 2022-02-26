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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video player example'),
      ),
      body: _BumbleBeeRemoteVideo(),
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
      // 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-ogv-file.ogv',
      'https://hajifirouz5.cdn.asset.aparat.cloud/aparat-video/337dbaa5ea7c9d4e77d9aac5aff9b1c042882824-144p.mp4?wmsAuthSign=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6IjlmYTE3M2VmYzkzMjlhMmQyZWFiOGMyZDI4NGNmMGMzIiwiZXhwIjoxNjQ1OTMwNTcwLCJpc3MiOiJTYWJhIElkZWEgR1NJRyJ9.ROCdwBHSOXCsf38brCX3jyb1vQSQKrZQ-3iE93WSV0A',
      // 'https://as10.cdn.asset.aparat.com/aparat-video/f1154d8132af75f5a4b6eb35f6b430a622216822-240p.mp4?wmsAuthSign=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6Ijg2MDJjNjJkMmFiYmNiMzc5ODFmYzA2ZjBlOGMwMDhkIiwiZXhwIjoxNjQ0NTYzODQ2LCJpc3MiOiJTYWJhIElkZWEgR1NJRyJ9.06lxphXJCQ7k9nVQWZZstTunwQWd05rVdaT-7H8nvGA',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller.initialize().then((value) => setState(() {}));
    _controller.setLooping(true);
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
          StreamBuilder<VideoSpectrumEvent>(
            stream: _controller.spectrum,
            builder: (BuildContext context, AsyncSnapshot<VideoSpectrumEvent> snapshot) {
              if (snapshot.hasData) {
                return FFTBand(spectrumEvent: snapshot.data);
              } else {
                return Text("Waiting for play video...");
              }
            },
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
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
          SizedBox.square(
            dimension: 200,
          )
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

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
