package com.video.player;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;

public final class FlutterState {
    final Context applicationContext;
    final BinaryMessenger binaryMessenger;
    final KeyForAssetFn keyForAsset;
    final KeyForAssetAndPackageName keyForAssetAndPackageName;
    final TextureRegistry textureRegistry;

    FlutterState(
            Context applicationContext,
            BinaryMessenger messenger,
            KeyForAssetFn keyForAsset,
            KeyForAssetAndPackageName keyForAssetAndPackageName,
            TextureRegistry textureRegistry) {
        this.applicationContext = applicationContext;
        this.binaryMessenger = messenger;
        this.keyForAsset = keyForAsset;
        this.keyForAssetAndPackageName = keyForAssetAndPackageName;
        this.textureRegistry = textureRegistry;
    }

    void startListening(VideoPlayerPlugin methodCallHandler, BinaryMessenger messenger) {
        Messages.VideoPlayerApi.setup(messenger, methodCallHandler);
    }

    void stopListening(BinaryMessenger messenger) {
        Messages.VideoPlayerApi.setup(messenger, null);
    }
}

interface KeyForAssetFn {
    String get(String asset);
}

interface KeyForAssetAndPackageName {
    String get(String asset, String packageName);
}
