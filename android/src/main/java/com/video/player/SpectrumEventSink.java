package com.video.player;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel;

public class SpectrumEventSink implements EventChannel.EventSink{
    private EventChannel.EventSink eventSink;
    private Handler handler;

    public void  MainThreadEventSink(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(Object event) {
        if(handler == null) return;

        handler.post(new Runnable() {
            @Override
            public void run() {
                eventSink.success(event);
            }
        });
    }

    @Override
    public void error(String errorCode, String errorMessage, Object errorDetails) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                eventSink.error(errorCode, errorMessage, errorDetails);
            }
        });
    }

    @Override
    public void endOfStream() {

    }
}
