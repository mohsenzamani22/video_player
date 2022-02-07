package com.video.player;

import static com.google.android.exoplayer2.Player.REPEAT_MODE_ALL;
import static com.google.android.exoplayer2.Player.REPEAT_MODE_OFF;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;
import android.view.Surface;


import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Player.Listener;
import com.google.android.exoplayer2.Renderer;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.audio.AudioAttributes;
import com.google.android.exoplayer2.audio.AudioCapabilities;
import com.google.android.exoplayer2.audio.AudioProcessor;
import com.google.android.exoplayer2.audio.AudioRendererEventListener;
import com.google.android.exoplayer2.audio.AudioSink;
import com.google.android.exoplayer2.audio.DefaultAudioSink;
import com.google.android.exoplayer2.audio.MediaCodecAudioRenderer;
import com.google.android.exoplayer2.mediacodec.MediaCodecSelector;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.ProgressiveMediaSource;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource;
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;

final class VideoPlayer {
    private static final String FORMAT_SS = "ss";
    private static final String FORMAT_DASH = "dash";
    private static final String FORMAT_HLS = "hls";
    private static final String FORMAT_OTHER = "other";

    private final SimpleExoPlayer exoPlayer;

    private Surface surface;

    private final TextureRegistry.SurfaceTextureEntry textureEntry;

    private final QueuingEventSink eventSink = new QueuingEventSink();
    private final SpectrumEventSink spectrumEventSink = new SpectrumEventSink();

    private final EventChannel eventChannel;
    private final EventChannel spectrumEventChannel;

    private boolean isInitialized = false;

    private final VideoPlayerOptions options;

    VideoPlayer(
            Context context,
            EventChannel spectrumEventChannel,
            EventChannel eventChannel,
            TextureRegistry.SurfaceTextureEntry textureEntry,
            String dataSource,
            String formatHint,
            Map<String, String> httpHeaders,
            VideoPlayerOptions options) {
        this.spectrumEventChannel = spectrumEventChannel;
        this.eventChannel = eventChannel;
        this.textureEntry = textureEntry;
        this.options = options;
        Uri uri = Uri.parse(dataSource);
        FFTAudioProcessor fftAudioProcessor = new FFTAudioProcessor();
        DefaultRenderersFactory defaultRenderersFactory = new DefaultRenderersFactory(context) {
            @Override
            protected void buildAudioRenderers(Context context, int extensionRendererMode, MediaCodecSelector mediaCodecSelector, boolean enableDecoderFallback, AudioSink audioSink, Handler eventHandler, AudioRendererEventListener eventListener, ArrayList<Renderer> out) {
                out.add(new MediaCodecAudioRenderer(
                        context,
                        mediaCodecSelector, enableDecoderFallback, eventHandler, eventListener, new DefaultAudioSink(
                        AudioCapabilities.getCapabilities(context), new AudioProcessor[]{fftAudioProcessor}
                )
                ));
                super.buildAudioRenderers(context, extensionRendererMode, mediaCodecSelector, enableDecoderFallback, audioSink, eventHandler, eventListener, out);
            }
        };
        exoPlayer = new SimpleExoPlayer.Builder(context, defaultRenderersFactory).build();
        DataSource.Factory dataSourceFactory;
        if (isHTTP(uri)) {
            CacheDataSourceFactory httpDataSourceFactory =
                    new CacheDataSourceFactory(context, 100 * 1024 * 1024, 10 * 1024 * 1024);
            if (httpHeaders != null && !httpHeaders.isEmpty()) {
                httpDataSourceFactory.setHeaders(httpHeaders);
            }
            dataSourceFactory = httpDataSourceFactory;
        } else {
            dataSourceFactory = new DefaultDataSourceFactory(context, "ExoPlayer");
        }

        MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory, formatHint, context);
        exoPlayer.setMediaSource(mediaSource);
        exoPlayer.prepare();




        setupVideoPlayer(eventChannel, spectrumEventChannel, fftAudioProcessor,  textureEntry);
    }

    private static boolean isHTTP(Uri uri) {
        if (uri == null || uri.getScheme() == null) {
            return false;
        }
        String scheme = uri.getScheme();
        return scheme.equals("http") || scheme.equals("https");
    }

    private MediaSource buildMediaSource(
            Uri uri, DataSource.Factory mediaDataSourceFactory, String formatHint, Context context) {
        int type;
        if (formatHint == null) {
            type = Util.inferContentType(uri.getLastPathSegment());
        } else {
            switch (formatHint) {
                case FORMAT_SS:
                    type = C.TYPE_SS;
                    break;
                case FORMAT_DASH:
                    type = C.TYPE_DASH;
                    break;
                case FORMAT_HLS:
                    type = C.TYPE_HLS;
                    break;
                case FORMAT_OTHER:
                    type = C.TYPE_OTHER;
                    break;
                default:
                    type = -1;
                    break;
            }
        }
        switch (type) {
            case C.TYPE_SS:
                return new SsMediaSource.Factory(
                        new DefaultSsChunkSource.Factory(mediaDataSourceFactory),
                        new DefaultDataSourceFactory(context, null, mediaDataSourceFactory))
                        .createMediaSource(MediaItem.fromUri(uri));
            case C.TYPE_DASH:
                return new DashMediaSource.Factory(
                        new DefaultDashChunkSource.Factory(mediaDataSourceFactory),
                        new DefaultDataSourceFactory(context, null, mediaDataSourceFactory))
                        .createMediaSource(MediaItem.fromUri(uri));
            case C.TYPE_HLS:
                return new HlsMediaSource.Factory(mediaDataSourceFactory)
                        .createMediaSource(MediaItem.fromUri(uri));
            case C.TYPE_OTHER:
                return new ProgressiveMediaSource.Factory(mediaDataSourceFactory)
                        .createMediaSource(MediaItem.fromUri(uri));
            default: {
                throw new IllegalStateException("Unsupported type: " + type);
            }
        }
    }
    private void setupVideoPlayer(
            EventChannel eventChannel, EventChannel spectrumEventChannel, FFTAudioProcessor fftAudioProcessor, TextureRegistry.SurfaceTextureEntry textureEntry) {
        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        eventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        eventSink.setDelegate(null);
                    }
                });
        spectrumEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        spectrumEventSink.MainThreadEventSink(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
//                        spectrumEventSink.MainThreadEventSink(null);
                    }
                });
        surface = new Surface(textureEntry.surfaceTexture());
        exoPlayer.setVideoSurface(surface);
        setAudioAttributes(exoPlayer, options.mixWithOthers);



//        fftAudioProcessor.setListener((sampleRateHz, channelCount, fft) -> {
//            Map<String, Object> event = new HashMap<>();
//            event.put("sampleRateHz", sampleRateHz);
//            event.put("channelCount", channelCount);
//            event.put("fft", fft);
//
////            new Handler().post(new Runnable() {
////                @Override
////                public void run() {
////                    spectrumEventSink.success(event);
////
////                }
////            });
//        });
//
//        for (int i = 0; i < 5000; i++) {
//            Map<String, Object> event = new HashMap<>();
//            float[] f = {10.10f,30.3f,40.60f,77.50f};
//            event.put("sampleRateHz", 10);
//            event.put("channelCount", 100);
//            event.put("fft", f);
//            spectrumEventSink.success(event);
//        }
        exoPlayer.addListener(
                new Listener() {
                    private boolean isBuffering = false;

                    public void setBuffering(boolean buffering) {
                        if (isBuffering != buffering) {
                            isBuffering = buffering;
                            Map<String, Object> event = new HashMap<>();
                            event.put("event", isBuffering ? "bufferingStart" : "bufferingEnd");
                            eventSink.success(event);
                        }
                    }

                    @Override
                    public void onPlaybackStateChanged(final int playbackState) {
                        if (playbackState == Player.STATE_BUFFERING) {
                            setBuffering(true);
                            sendBufferingUpdate();
                        } else if (playbackState == Player.STATE_READY) {
                            if (!isInitialized) {
                                isInitialized = true;
                                sendInitialized();
                            }
                        } else if (playbackState == Player.STATE_ENDED) {
                            Map<String, Object> event = new HashMap<>();
                            event.put("event", "completed");
                            eventSink.success(event);
                        }

                        if (playbackState != Player.STATE_BUFFERING) {
                            setBuffering(false);
                        }
                    }
                });
        fftAudioProcessor.setListener(this::onFFTReady);

    }

    void sendBufferingUpdate() {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "bufferingUpdate");
        List<? extends Number> range = Arrays.asList(0, exoPlayer.getBufferedPosition());
        // iOS supports a list of buffered ranges, so here is a list with a single range.
        event.put("values", Collections.singletonList(range));
        eventSink.success(event);
    }

    private static void setAudioAttributes(SimpleExoPlayer exoPlayer, boolean isMixMode) {
        exoPlayer.setAudioAttributes(
                new AudioAttributes.Builder().setContentType(C.CONTENT_TYPE_MOVIE).build(), !isMixMode);
    }

    void play() {
        exoPlayer.setPlayWhenReady(true);
    }

    void pause() {
        exoPlayer.setPlayWhenReady(false);
    }

    void setLooping(boolean value) {
        exoPlayer.setRepeatMode(value ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
    }

    void setVolume(double value) {
        float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
        exoPlayer.setVolume(bracketedValue);
    }

    void setPlaybackSpeed(double value) {
        final PlaybackParameters playbackParameters = new PlaybackParameters(((float) value));

        exoPlayer.setPlaybackParameters(playbackParameters);
    }

    void seekTo(int location) {
        exoPlayer.seekTo(location);
    }

    long getPosition() {
        return exoPlayer.getCurrentPosition();
    }

    @SuppressWarnings("SuspiciousNameCombination")
    private void sendInitialized() {
        if (isInitialized) {
            Map<String, Object> event = new HashMap<>();
            event.put("event", "initialized");
            event.put("duration", exoPlayer.getDuration());

            if (exoPlayer.getVideoFormat() != null) {
                Format videoFormat = exoPlayer.getVideoFormat();
                int width = videoFormat.width;
                int height = videoFormat.height;
                int rotationDegrees = videoFormat.rotationDegrees;
                // Switch the width/height if video was taken in portrait mode
                if (rotationDegrees == 90 || rotationDegrees == 270) {
                    width = exoPlayer.getVideoFormat().height;
                    height = exoPlayer.getVideoFormat().width;
                }
                event.put("width", width);
                event.put("height", height);
            }
            eventSink.success(event);
        }
    }

    void dispose() {
        if (isInitialized) {
            exoPlayer.stop();
        }
        textureEntry.release();
        eventChannel.setStreamHandler(null);
        if (surface != null) {
            surface.release();
        }
        if (exoPlayer != null) {
            exoPlayer.release();
        }
    }

    private void onFFTReady(int sampleRateHz, int channelCount, float[] fft) {
        Map<String, Object> event = new HashMap<>();
        event.put("sampleRateHz", sampleRateHz);
        event.put("channelCount", channelCount);
        event.put("fft", fft);
        spectrumEventSink.success(event);
    }
}
