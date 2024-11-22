package com.transcend.plugins.drmnativeaudio;

import static android.media.AudioAttributes.ALLOW_CAPTURE_BY_NONE;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.graphics.Bitmap;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.StrictMode;
import android.view.WindowManager;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.appcompat.app.AppCompatActivity;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.Player;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.datasource.HttpDataSource;
import androidx.media3.exoplayer.ExoPlaybackException;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.drm.DrmSessionManager;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.ui.PlayerNotificationManager;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.pallycon.widevine.exception.PallyConException;
import com.pallycon.widevine.exception.PallyConLicenseServerException;
import com.pallycon.widevine.model.ContentData;
import com.pallycon.widevine.model.PallyConDrmConfigration;
import com.pallycon.widevine.model.PallyConEventListener;
import com.pallycon.widevine.sdk.PallyConWvSDK;
import java.util.List;


@CapacitorPlugin(name = "AudioDRM")

public class AudioDRMPlugin extends Plugin {

    MediaSource mediaSource = null;
    @SuppressLint("UnsafeOptInUsageError")
    private DefaultTrackSelector trackSelector;
    private Handler handler;
    private Runnable runnable;
    private final AudioDRM implementation = new AudioDRM();
    PallyConWvSDK WVMAgent = null;
    private ExoPlayer player;
    private String userAgent;
    private DataSource.Factory mediaDataSourceFactory;

    @SuppressLint("UnsafeOptInUsageError")
    private PlayerNotificationManager notificationManager;
    private final String CHANNEL_ID = "audio_playback";
    private PallyConEventListener drmListener = new PallyConEventListener() {
        @Override
        public void onFailed(@NonNull ContentData contentData, @Nullable PallyConLicenseServerException e) {
            JSObject ret = new JSObject();
            ret.put("message",e.message());
            notifyListeners("playerError",ret);
        }

        @Override
        public void onFailed(@NonNull ContentData contentData, @Nullable PallyConException e) {
            JSObject ret = new JSObject();
            ret.put("message",e.message());
            notifyListeners("playerError",ret);
        }

        @Override
        public void onPaused(@NonNull ContentData contentData) {

        }

        @Override
        public void onRemoved(@NonNull ContentData contentData) {

        }

        @Override
        public void onRestarting(@NonNull ContentData contentData) {

        }

        @Override
        public void onStopped(@NonNull ContentData contentData) {

        }

        @Override
        public void onProgress(@NonNull ContentData contentData, float v, long l) {

        }

        @Override
        public void onCompleted(@NonNull ContentData contentData) {

        }
    };

    @SuppressLint("UnsafeOptInUsageError")
    Player.Listener playerEventListener = new Player.Listener() {

        JSObject ret = new JSObject();
        @Override
        public void onPlayerError(PlaybackException error) {
            if (error.errorCode == ExoPlaybackException.TYPE_RENDERER) {
                ret.put("message",error.getLocalizedMessage());
                notifyListeners("playerError",ret);
            } else if (error.errorCode == ExoPlaybackException.TYPE_SOURCE) {
                ret.put("message",error.getLocalizedMessage());
                notifyListeners("playerError",ret);
            } else if (error.errorCode == ExoPlaybackException.TYPE_UNEXPECTED) {
                ret.put("message",error.getLocalizedMessage());
                notifyListeners("playerError",ret);
            } else {
                ret.put("message",error.getLocalizedMessage());
                notifyListeners("playerError",ret);
            }
        }


        public  void onPlaybackStateChanged(int playbackState)
        {
            JSObject ret = new JSObject();
            if(playbackState == Player.STATE_ENDED)
            {
                notifyListeners("soundEnded",null);
            }else if (playbackState == Player.STATE_BUFFERING)
            {
                notifyListeners("isBuffering",null);
            }else  if(playbackState == Player.STATE_READY)
            {
                ret.put("duration",player.getDuration()/1000);
                notifyListeners("audioLoaded",ret);

            }
        }

    };

    @SuppressLint("UnsafeOptInUsageError")
    @Override
    public void load() {
        super.load();
//        AppCompatActivity activity = getActivity();
//        activity.runOnUiThread(() -> {
//            activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
//            StrictMode.ThreadPolicy pol = new StrictMode.ThreadPolicy.Builder().permitNetwork().build();
//            StrictMode.setThreadPolicy(pol);
//
//            userAgent = Util.getUserAgent(getContext(), "Transcend");
//            mediaDataSourceFactory = buildDataSourceFactory();
//
//        });
    }

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    public void startPlaybackCheck()
    {
        handler = new Handler();
        runnable = new Runnable() {
            @Override
            public void run() {
                if (player != null) {
                    if (!player.isPlaying() && player.getPlaybackState() == Player.STATE_READY) {
                        notifyListeners("isAudioPause", null);
                    }else if(player.isPlaying())
                    {
                        notifyListeners("isAudioPlaying", null);
                    }
                }
                handler.postDelayed(this, 1000);
            }
        };
        handler.post(runnable);
    }

    @SuppressLint("UnsafeOptInUsageError")
    @PluginMethod
    public void loadPallyconSound(PluginCall call)
    {
        JSObject ret = new JSObject();

        String audioUrl = call.getString("audioURL");
        String token = call.getString("token");

        if (Util.SDK_INT > 23) {
            try {
                PallyConDrmConfigration config = new PallyConDrmConfigration("USE5", token);
                ContentData content = new ContentData(audioUrl, config);
                WVMAgent = PallyConWvSDK.createPallyConWvSDK(getContext(),content);
                DrmSessionManager manager = WVMAgent.getDrmSessionManager();
                WVMAgent.setPallyConEventListener(drmListener);
                try {
                    mediaSource = WVMAgent.getMediaSource(manager);
                    trackSelector = new DefaultTrackSelector(getContext());


                } catch (PallyConException.ContentDataException e) {
                    e.printStackTrace();
                    return;
                } catch (PallyConException.DetectedDeviceTimeModifiedException e) {
                    e.printStackTrace();
                    return;
                }

                AudioManager audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    audioManager.setAllowedCapturePolicy(ALLOW_CAPTURE_BY_NONE);
                }

                AudioAttributes audioAttributes = new AudioAttributes.Builder()
                        .setUsage(C.USAGE_MEDIA)
                        .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                        .setAllowedCapturePolicy(C.ALLOW_CAPTURE_BY_NONE)
                        .build();



                player = new ExoPlayer.Builder( getContext())
                        .setTrackSelector(trackSelector)
                        .build();
                player.setMediaSource(mediaSource);
                player.addListener(playerEventListener);
                player.setAudioAttributes(audioAttributes,true);
                player.setPlayWhenReady(true);
                player.prepare();
                startPlaybackCheck();

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    NotificationChannel channel = new NotificationChannel(
                            CHANNEL_ID,
                            "Audio Playback",
                            NotificationManager.IMPORTANCE_LOW
                    );
                    NotificationManager notificationManager = getContext().getSystemService(NotificationManager.class);
                    notificationManager.createNotificationChannel(channel);
                }

                notificationManager = new PlayerNotificationManager.Builder(getContext(), 1, CHANNEL_ID)
                        .setMediaDescriptionAdapter(new PlayerNotificationManager.MediaDescriptionAdapter() {
                            @Override
                            public String getCurrentContentTitle(Player player) {
                                return "Now Playing"; // Customize as needed
                            }

                            @Override
                            public PendingIntent createCurrentContentIntent(Player player) {
                                return null; // Add PendingIntent for app interaction
                            }

                            @Override
                            public String getCurrentContentText(Player player) {
                                return "Audio Content Description"; // Customize
                            }

                            @Override
                            public Bitmap getCurrentLargeIcon(Player player, PlayerNotificationManager.BitmapCallback callback) {
                                return null; // Add album art if available
                            }
                        })
                        .build();

                notificationManager.setPlayer(player);
                startPlaybackCheck();
            }catch (Exception ex)
            {
                ret.put("message",ex.getMessage());
                notifyListeners("playerError",ret);
            }


        }

    }

    @SuppressLint("UnsafeOptInUsageError")
    @PluginMethod
    public void pauseAudio(PluginCall call)
    {
        if(player !=null && player.isPlaying())
        {
            player.pause();
        }
        call.resolve();
    }

    @PluginMethod
    public void setAudioPlaybackRate(PluginCall call)
    {
        float speed = call.getFloat("speed");
        if(player != null && String.valueOf(speed) != null )
        {
            PlaybackParameters playbackParameters = new PlaybackParameters(speed);
            player.setPlaybackParameters(playbackParameters);
        }else {
            Toast.makeText(getContext(),"Cannot set playback rate",Toast.LENGTH_LONG).show();
        }
    }

    @PluginMethod
    public void playAudio(PluginCall call)
    {
        if(player !=null && !player.isPlaying())
        {
            player.play();
        }

        call.resolve();
    }

    @PluginMethod
    public void seekToTime(PluginCall call)
    {
        var speed = call.getInt("seekTime");
        if(player != null && String.valueOf(speed) != null)
        {
            player.seekTo(player.getCurrentMediaItemIndex(),speed.longValue() * 1000);
            call.resolve();
        }else
        {
            Toast.makeText(getContext(),"Seek failed due to internal error",Toast.LENGTH_LONG).show();
        }
    }

    @PluginMethod
    public void stopCurrentAudio(PluginCall call)
    {
        if (handler != null && runnable != null) {
            handler.removeCallbacks(runnable);
        }
        if (player != null) {
            player.release();
        }
    }

    @PluginMethod
    public void getCurrentTime(PluginCall call)
    {
      JSObject ret = new JSObject();
      ret.put("time",player.getCurrentPosition()/1000);
      call.resolve(ret);
    }

    @PluginMethod
    public  void removeNotificationAndClearAudio(PluginCall call)
    {
        call.resolve();
    }

    @PluginMethod
    public void getPaused(PluginCall call)
    {
        JSObject ret = new JSObject();
        if(player != null)
        {
            if(player.isPlaying())
            {
                ret.put("paused",false);
                call.resolve(ret);
            }else
            {
                ret.put("paused",true);
                call.resolve(ret);
            }
        }else
        {
            //Error
        }
    }

    private DataSource.Factory buildDataSourceFactory() {
        HttpDataSource.Factory httpDataSourceFactory = buildHttpDataSourceFactory();

        return new DefaultDataSource.Factory(getContext(), httpDataSourceFactory);
    }

    @OptIn(markerClass = UnstableApi.class)
    private HttpDataSource.Factory buildHttpDataSourceFactory() {
        return new DefaultHttpDataSource.Factory()
                .setUserAgent(Util.getUserAgent(getContext(), "Transcend"));
    }
}
