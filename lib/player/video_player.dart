import 'dart:async';
import 'dart:io';

import 'package:cache_video_player/interface/video_player_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'src/closed_caption_file.dart';

export 'src/closed_caption_file.dart';

final VideoPlayerPlatform _videoPlayerPlatform = VideoPlayerPlatform.instance..init();

class VideoPlayerValue {
  VideoPlayerValue({
    required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.caption = Caption.none,
    this.buffered = const <DurationRange>[],
    this.isInitialized = false,
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.errorDescription,
    this.errorDetails,
  });

  VideoPlayerValue.uninitialized() : this(duration: Duration.zero, isInitialized: false);

  VideoPlayerValue.erroneous(String errorDescription, String errorDetails)
      : this(
    duration: Duration.zero, isInitialized: false, errorDescription: errorDescription, errorDetails: errorDetails,);

  final Duration duration;
  final Duration position;
  final Caption caption;
  final List<DurationRange> buffered;
  final bool isPlaying;
  final bool isLooping;
  final bool isBuffering;
  final double volume;
  final double playbackSpeed;
  final String? errorDescription;
  final String? errorDetails;
  final Size size;
  final bool isInitialized;

  bool get hasError => errorDescription != null;

  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  VideoPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    Caption? caption,
    List<DurationRange>? buffered,
    bool? isInitialized,
    bool? isPlaying,
    bool? isLooping,
    bool? isBuffering,
    double? volume,
    double? playbackSpeed,
    String? errorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      caption: caption ?? this.caption,
      buffered: buffered ?? this.buffered,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'caption: $caption, '
        'buffered: [${buffered.join(', ')}], '
        'isInitialized: $isInitialized, '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'volume: $volume, '
        'playbackSpeed: $playbackSpeed, '
        'errorDescription: $errorDescription)';
  }
}

class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  VideoPlayerController.asset(this.dataSource, {this.package, this.closedCaptionFile, this.videoPlayerOptions})
      : dataSourceType = DataSourceType.asset,
        formatHint = null,
        httpHeaders = const {},
        super(VideoPlayerValue(duration: Duration.zero));

  VideoPlayerController.network(this.dataSource, {
    this.formatHint,
    this.closedCaptionFile,
    this.videoPlayerOptions,
    this.httpHeaders = const {},
  })
      : dataSourceType = DataSourceType.network,
        package = null,
        super(VideoPlayerValue(duration: Duration.zero));

  VideoPlayerController.file(File file, {this.closedCaptionFile, this.videoPlayerOptions})
      : dataSource = 'file://${file.path}',
        dataSourceType = DataSourceType.file,
        package = null,
        formatHint = null,
        httpHeaders = const {},
        super(VideoPlayerValue(duration: Duration.zero));

  VideoPlayerController.contentUri(Uri contentUri, {this.closedCaptionFile, this.videoPlayerOptions})
      : assert(defaultTargetPlatform == TargetPlatform.android,
  'VideoPlayerController.contentUri is only supported on Android.'),
        dataSource = contentUri.toString(),
        dataSourceType = DataSourceType.contentUri,
        package = null,
        formatHint = null,
        httpHeaders = const {},
        super(VideoPlayerValue(duration: Duration.zero));

  final String dataSource;

  final Map<String, String> httpHeaders;

  final VideoFormat? formatHint;

  final DataSourceType dataSourceType;

  final VideoPlayerOptions? videoPlayerOptions;

  final String? package;

  final Future<ClosedCaptionFile>? closedCaptionFile;

  // StreamSubscription<VideoSpectrumEvent>? spectrum;

  ClosedCaptionFile? _closedCaptionFile;
  Timer? _timer;
  bool _isDisposed = false;
  Completer<void>? _creatingCompleter;
  StreamSubscription<dynamic>? _eventSubscription;
  Stream<VideoSpectrumEvent>? spectrum;

  late _VideoAppLifeCycleObserver _lifeCycleObserver;

  @visibleForTesting
  static const int kUninitializedTextureId = -1;
  int _textureId = kUninitializedTextureId;

  @visibleForTesting
  int get textureId => _textureId;

  // Stream<VideoSpectrumEvent> get spectrum {
  //   return _videoPlayerPlatform.videoSpectrumEventsFor(_textureId);
  // }

  Future<void> initialize() async {
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    late DataSource dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.asset,
          asset: dataSource,
          package: package,
        );
        break;
      case DataSourceType.network:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.network,
          uri: dataSource,
          formatHint: formatHint,
          httpHeaders: httpHeaders,
        );
        break;
      case DataSourceType.file:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.file,
          uri: dataSource,
        );
        break;
      case DataSourceType.contentUri:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.contentUri,
          uri: dataSource,
        );
        break;
    }

    if (videoPlayerOptions?.mixWithOthers != null) {
      await _videoPlayerPlatform.setMixWithOthers(videoPlayerOptions!.mixWithOthers);
    }

    _textureId = (await _videoPlayerPlatform.create(dataSourceDescription)) ?? kUninitializedTextureId;
    _creatingCompleter!.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    void eventListener(VideoEvent event) {
      if (_isDisposed) {
        return;
      }

      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
            isInitialized: event.duration != null,
          );
          initializingCompleter.complete(null);
          _applyLooping();
          _applyVolume();
          _applyPlayPause();
          break;
        case VideoEventType.completed:
        // In this case we need to stop _timer, set isPlaying=false, and
        // position=value.duration. Instead of setting the values directly,
        // we use pause() and seekTo() to ensure the platform stops playing
        // and seeks to the last frame of the video.
          pause().then((void pauseResult) => seekTo(value.duration));
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.unknown:
          break;
      }
    }

    if (closedCaptionFile != null) {
      _closedCaptionFile ??= await closedCaptionFile;
      value = value.copyWith(caption: _getCaptionAt(value.position));
    }

    void errorListener(Object obj) {
      final PlatformException e = obj as PlatformException;
      value = VideoPlayerValue.erroneous(e.message!, e.details!);
      _timer?.cancel();
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    void spectrumErrorListener(Object obj) {
      print("SpectrumError : $obj");
      // final PlatformException e = obj as PlatformException;
      // value = VideoPlayerValue.erroneous(e.message!);
      // _timer?.cancel();
      // if (!initializingCompleter.isCompleted) {
      //   initializingCompleter.completeError(obj);
      // }
    }

    void spectrumEventListener(VideoSpectrumEvent event) {
      // return VideoSpectrumEvent(sampleRateHz: 1, channelCount: 1, fft: [10,2]);
      print("VideoSpectrumEvent is: ${event.toString()}");
    }

    _eventSubscription = _videoPlayerPlatform.videoEventsFor(_textureId).listen(eventListener, onError: errorListener);
    spectrum = _videoPlayerPlatform.videoSpectrumEventsFor(_textureId);

    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter!.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        await _videoPlayerPlatform.dispose(_textureId);
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;

    super.dispose();
  }

  Future<void> play() async {
    if (value.position == value.duration) {
      await seekTo(const Duration());
    }
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<void> _applyLooping() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    await _videoPlayerPlatform.setLooping(_textureId, value.isLooping);
  }

  Future<void> _applyPlayPause() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (value.isPlaying) {
      await _videoPlayerPlatform.play(_textureId);
      _timer?.cancel();
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
            (Timer timer) async {
          if (_isDisposed) {
            return;
          }
          final Duration? newPosition = await position;
          if (newPosition == null) {
            return;
          }
          _updatePosition(newPosition);
        },
      );

      // This ensures that the correct playback speed is always applied when
      // playing back. This is necessary because we do not set playback speed
      // when paused.
      await _applyPlaybackSpeed();
    } else {
      _timer?.cancel();
      await _videoPlayerPlatform.pause(_textureId);
    }
  }

  Future<void> _applyVolume() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    await _videoPlayerPlatform.setVolume(_textureId, value.volume);
  }

  Future<void> _applyPlaybackSpeed() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (!value.isPlaying) return;
    await _videoPlayerPlatform.setPlaybackSpeed(
      _textureId,
      value.playbackSpeed,
    );
  }

  Future<Duration?> get position async {
    if (_isDisposed) {
      return null;
    }
    return await _videoPlayerPlatform.getPosition(_textureId);
  }

  Future<void> seekTo(Duration position) async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (position > value.duration) {
      position = value.duration;
    } else if (position < const Duration()) {
      position = const Duration();
    }
    await _videoPlayerPlatform.seekTo(_textureId, position);
    _updatePosition(position);
  }

  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0) {
      throw ArgumentError.value(
        speed,
        'Negative playback speeds are generally unsupported.',
      );
    } else if (speed == 0) {
      throw ArgumentError.value(
        speed,
        'Zero playback speed is generally unsupported. Consider using [pause].',
      );
    }

    value = value.copyWith(playbackSpeed: speed);
    await _applyPlaybackSpeed();
  }

  Caption _getCaptionAt(Duration position) {
    if (_closedCaptionFile == null) {
      return Caption.none;
    }

    // TODO: This would be more efficient as a binary search.
    for (final caption in _closedCaptionFile!.captions) {
      if (caption.start <= position && caption.end >= position) {
        return caption;
      }
    }

    return Caption.none;
  }

  void _updatePosition(Duration position) {
    value = value.copyWith(position: position);
    value = value.copyWith(caption: _getCaptionAt(position));
  }

  @override
  void removeListener(VoidCallback listener) {
    // Prevent VideoPlayer from causing an exception to be thrown when attempting to
    // remove its own listener after the controller has already been disposed.
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }

  bool get _isDisposedOrNotInitialized => _isDisposed || !value.isInitialized;
}

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  void initialize() {
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
  }
}

class VideoPlayer extends StatefulWidget {
  const VideoPlayer(this.controller);

  final VideoPlayerController controller;

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  late VoidCallback _listener;

  late int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == VideoPlayerController.kUninitializedTextureId
        ? Container()
        : _videoPlayerPlatform.buildView(_textureId);
  }
}

class VideoProgressColors {
  const VideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;

  final Color bufferedColor;

  final Color backgroundColor;
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class VideoProgressIndicator extends StatefulWidget {
  VideoProgressIndicator(this.controller, {
    this.colors = const VideoProgressColors(),
    required this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  });

  final VideoPlayerController controller;

  final VideoProgressColors colors;

  final bool allowScrubbing;

  final EdgeInsets padding;

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}

class ClosedCaption extends StatelessWidget {
  const ClosedCaption({Key? key, this.text, this.textStyle}) : super(key: key);

  final String? text;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    if (text == null || text.isEmpty) {
      return SizedBox.shrink();
    }

    final TextStyle effectiveTextStyle = textStyle ??
        DefaultTextStyle
            .of(context)
            .style
            .copyWith(
          fontSize: 36.0,
          color: Colors.white,
        );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xB8000000),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(text, style: effectiveTextStyle),
          ),
        ),
      ),
    );
  }
}

T? _ambiguate<T>(T? value) => value;
