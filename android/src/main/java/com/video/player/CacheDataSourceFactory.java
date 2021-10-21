package com.video.player;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.upstream.FileDataSource;
import com.google.android.exoplayer2.upstream.cache.CacheDataSink;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;

import java.util.Map;

@SuppressWarnings("deprecation")
class CacheDataSourceFactory implements DataSource.Factory {
    private final Context context;
    private final long maxFileSize, maxCacheSize;

    private final DefaultHttpDataSourceFactory defaultHttpDataSourceFactory;
    CacheDataSourceFactory(Context context, long maxCacheSize, long maxFileSize) {
        super();
        this.context = context;
        this.maxCacheSize = maxCacheSize;
        this.maxFileSize = maxFileSize;
        defaultHttpDataSourceFactory = new DefaultHttpDataSourceFactory("ExoPlayer",
                null,
                DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS,
                DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS,
                true);

    }

    void setHeaders(Map<String, String> httpHeaders) {
        defaultHttpDataSourceFactory.getDefaultRequestProperties().set(httpHeaders);
    }

    @NonNull
    @Override
    public DataSource createDataSource() {
        DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter.Builder(context).build();
        DefaultDataSourceFactory defaultDatasourceFactory = new DefaultDataSourceFactory(this.context,
                bandwidthMeter, defaultHttpDataSourceFactory);
        SimpleCache simpleCache = SimpleCacheSingleton.getInstance(context, maxCacheSize).simpleCache;
        return new CacheDataSource(simpleCache, defaultDatasourceFactory.createDataSource(),
                new FileDataSource(), new CacheDataSink(simpleCache, maxFileSize),
                CacheDataSource.FLAG_BLOCK_ON_CACHE | CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR, null);
    }

}
