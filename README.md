A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

The example app running in iOS

Installation
First, add cache_video_player as a dependency in your pubspec.yaml file.

Android
Ensure the following permission is present in your Android Manifest file, located in <project root>/android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.INTERNET"/>
The Flutter project template adds it, so it may already be there.

Supported Formats
On Android, the backing player is ExoPlayer, please refer here for list of supported formats.
import 'package:cahe_video_player/video_player.dart';
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
Usage
The following section contains usage information that goes beyond what is included in the documentation in order to give a more elaborate overview of the API.

This is not complete as of now. You can contribute to this section by opening a pull request.

Playback speed
You can set the playback speed on your _controller (instance of VideoPlayerController) by calling _controller.setPlaybackSpeed. setPlaybackSpeed takes a double speed value indicating the rate of playback for your video.
For example, when given a value of 2.0, your video will play at 2x the regular playback speed and so on.

To learn about playback speed limitations, see the setPlaybackSpeed method documentation.

Furthermore, see the example app for an example playback speed implementation.