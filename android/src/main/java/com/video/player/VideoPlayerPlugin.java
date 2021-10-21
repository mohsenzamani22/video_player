// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package com.video.player;

import android.os.Build;
import android.util.LongSparseArray;

import io.flutter.FlutterInjector;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

import io.flutter.view.TextureRegistry;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;

/**
 * Android platform implementation of the VideoPlayerPlugin.
 */
public class VideoPlayerPlugin implements FlutterPlugin, Messages.VideoPlayerApi {
    private static final String TAG = "VideoPlayerPlugin";
    private final LongSparseArray<VideoPlayer> videoPlayers = new LongSparseArray<>();
    private FlutterState flutterState;
    private final VideoPlayerOptions options = new VideoPlayerOptions();

    /**
     * Register this with the v2 embedding for the plugin to respond to lifecycle callbacks.
     */
    public VideoPlayerPlugin() {
    }

    @SuppressWarnings("deprecation")
    private VideoPlayerPlugin(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        this.flutterState =
                new FlutterState(
                        registrar.context(),
                        registrar.messenger(),
                        registrar::lookupKeyForAsset,
                        registrar::lookupKeyForAsset,
                        registrar.textures());
        flutterState.startListening(this, registrar.messenger());
    }

    /**
     * Registers this with the stable v1 embedding. Will not respond to lifecycle events.
     */
    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final VideoPlayerPlugin plugin = new VideoPlayerPlugin(registrar);
        registrar.addViewDestroyListener(
                view -> {
                    plugin.onDestroy();
                    return false; // We are not interested in assuming ownership of the NativeView.
                });
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            try {
                HttpsURLConnection.setDefaultSSLSocketFactory(new CustomSSLSocketFactory());
            } catch (KeyManagementException | NoSuchAlgorithmException e) {
                Log.w(
                        TAG,
                        "Failed to enable TLSv1.1 and TLSv1.2 Protocols for API level 19 and below.\n"
                                + "For more information about Socket Security, please consult the following link:\n"
                                + "https://developer.android.com/reference/javax/net/ssl/SSLSocket",
                        e);
            }
        }

        final FlutterInjector injector = FlutterInjector.instance();
        this.flutterState =
                new FlutterState(
                        binding.getApplicationContext(),
                        binding.getBinaryMessenger(),
                        injector.flutterLoader()::getLookupKeyForAsset,
                        injector.flutterLoader()::getLookupKeyForAsset,
                        binding.getTextureRegistry());
        flutterState.startListening(this, binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (flutterState == null) {
            Log.wtf(TAG, "Detached from the engine before registering to it.");
        }
        flutterState.stopListening(binding.getBinaryMessenger());
        flutterState = null;
        initialize();
    }

    private void disposeAllPlayers() {
        for (int i = 0; i < videoPlayers.size(); i++) {
            videoPlayers.valueAt(i).dispose();
        }
        videoPlayers.clear();
    }

    private void onDestroy() {
        disposeAllPlayers();
    }

    public void initialize() {
        disposeAllPlayers();
    }

    public Messages.TextureMessage create(Messages.CreateMessage arg) {
        TextureRegistry.SurfaceTextureEntry handle =
                flutterState.textureRegistry.createSurfaceTexture();
        EventChannel eventChannel =
                new EventChannel(
                        flutterState.binaryMessenger, "video/videoEvents" + handle.id());

        VideoPlayer player;
        if (arg.getAsset() != null) {
            String assetLookupKey;
            if (arg.getPackageName() != null) {
                assetLookupKey =
                        flutterState.keyForAssetAndPackageName.get(arg.getAsset(), arg.getPackageName());
            } else {
                assetLookupKey = flutterState.keyForAsset.get(arg.getAsset());
            }
            player =
                    new VideoPlayer(
                            flutterState.applicationContext,
                            eventChannel,
                            handle,
                            "asset:///" + assetLookupKey,
                            null,
                            null,
                            options);
        } else {
            @SuppressWarnings("unchecked")
            Map<String, String> httpHeaders = arg.getHttpHeaders();
            player =
                    new VideoPlayer(
                            flutterState.applicationContext,
                            eventChannel,
                            handle,
                            arg.getUri(),
                            arg.getFormatHint(),
                            httpHeaders,
                            options);
        }
        videoPlayers.put(handle.id(), player);

        Messages.TextureMessage result = new Messages.TextureMessage();
        result.setTextureId(handle.id());
        return result;
    }

    public void dispose(Messages.TextureMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.dispose();
        videoPlayers.remove(arg.getTextureId());
    }

    public void setLooping(Messages.LoopingMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.setLooping(arg.getIsLooping());
    }

    public void setVolume(Messages.VolumeMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.setVolume(arg.getVolume());
    }

    public void setPlaybackSpeed(Messages.PlaybackSpeedMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.setPlaybackSpeed(arg.getSpeed());
    }

    public void play(Messages.TextureMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.play();
    }

    public Messages.PositionMessage position(Messages.TextureMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        Messages.PositionMessage result = new Messages.PositionMessage();
        result.setPosition(player.getPosition());
        player.sendBufferingUpdate();
        return result;
    }

    public void seekTo(Messages.PositionMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.seekTo(arg.getPosition().intValue());
    }

    public void pause(Messages.TextureMessage arg) {
        VideoPlayer player = videoPlayers.get(arg.getTextureId());
        player.pause();
    }

    @Override
    public void setMixWithOthers(Messages.MixWithOthersMessage arg) {
        options.mixWithOthers = arg.getMixWithOthers();
    }
}
