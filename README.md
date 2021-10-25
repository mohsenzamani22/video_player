# Video Player plugin for Flutter

[![pub package](https://img.shields.io/pub/v/cache_video_player.svg)](https://pub.dev/packages/cache_video_player)

A Flutter plugin Android for playing back video on a Widget surface.

## Installation

First, add `cache_video_player` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

The Flutter project template adds it, so it may already be there.

## Supported Formats
- On Android, the backing player is [ExoPlayer](https://google.github.io/ExoPlayer/),
  please refer [here](https://google.github.io/ExoPlayer/supported-formats.html) for list of supported formats.

## Example

```dart
import 'package:video_player/cache_video_player.dart';
import 'package:flutter/material.dart';
void main() => runApp(VideoApp());
class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}
class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
```

## Usage

The following section contains usage information that goes beyond what is included in the
documentation in order to give a more elaborate overview of the API.

This is not complete as of now. You can contribute to this section by [opening a pull request](https://github.com/flutter/plugins/pulls).

### Playback speed

You can set the playback speed on your `_controller` (instance of `VideoPlayerController`) by
calling `_controller.setPlaybackSpeed`. `setPlaybackSpeed` takes a `double` speed value indicating
the rate of playback for your video.  
For example, when given a value of `2.0`, your video will play at 2x the regular playback speed
and so on.

Furthermore, see the example app for an example playback speed implementation.