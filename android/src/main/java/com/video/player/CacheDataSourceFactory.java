package com.video.player;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.exoplayer2.database.DatabaseProvider;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.FileDataSource;
import com.google.android.exoplayer2.upstream.cache.CacheDataSink;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;

import java.io.File;
import java.util.Map;

class CacheDataSourceFactory implements DataSource.Factory {
    private final Context context;
    private final long maxFileSize, maxCacheSize;
    private final File cacheDirectoryPath;

    private final DefaultHttpDataSource.Factory defaultHttpDataSourceFactory2;

    CacheDataSourceFactory(Context context, long maxCacheSize, long maxFileSize, @Nullable File cacheDirectoryPath) {
        super();
        this.context = context;
        this.maxCacheSize = maxCacheSize;
        this.maxFileSize = maxFileSize;
        if (cacheDirectoryPath == null) {
            this.cacheDirectoryPath = context.getCacheDir();
        } else {
            this.cacheDirectoryPath = cacheDirectoryPath;
        }
        defaultHttpDataSourceFactory2 = new DefaultHttpDataSource.Factory()
                .setUserAgent("ExoPlayer")
                .setConnectTimeoutMs(DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS)
                .setReadTimeoutMs(DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS);
    }

    void setHeaders(Map<String, String> httpHeaders) {
        defaultHttpDataSourceFactory2.setDefaultRequestProperties(httpHeaders);
    }

    @NonNull
    @Override
    public DataSource createDataSource() {
        DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter.Builder(context).build();
        DefaultDataSourceFactory defaultDatasourceFactory = new DefaultDataSourceFactory(this.context,
                bandwidthMeter, defaultHttpDataSourceFactory2);
//        SimpleCache simpleCache = SimpleCacheSingleton.getInstance(context, maxCacheSize).simpleCache;
        SimpleCache simpleCache = new SimpleCache(cacheDirectoryPath, new LeastRecentlyUsedCacheEvictor(maxCacheSize), (DatabaseProvider) null);
        return new CacheDataSource(simpleCache, defaultDatasourceFactory.createDataSource(),
                new FileDataSource(), new CacheDataSink(simpleCache, maxFileSize),
                CacheDataSource.FLAG_BLOCK_ON_CACHE | CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR, null);
    }

}
