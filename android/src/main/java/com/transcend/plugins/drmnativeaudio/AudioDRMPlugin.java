package com.transcend.plugins.drmnativeaudio;

import static android.media.AudioAttributes.ALLOW_CAPTURE_BY_NONE;
import android.annotation.SuppressLint;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.PowerManager;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.Player;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.ExoPlaybackException;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.drm.DrmSessionManager;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
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
import android.content.ServiceConnection;

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
    private AudioPlaybackService playbackService;
    private boolean isBound = false;



    @SuppressLint("UnsafeOptInUsageError")
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

    private PowerManager.WakeLock wakeLock;

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            AudioPlaybackService.LocalBinder binder = (AudioPlaybackService.LocalBinder) iBinder;
            playbackService = binder.getService();
            isBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            isBound = false;
            playbackService = null;
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
                System.out.println("soundEnded");
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
        PowerManager powerManager = (PowerManager) getContext().getSystemService(Context.POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "AudioDRMPlugin::WakeLock");
        wakeLock.acquire();
        Intent intent = new Intent(getContext(), AudioPlaybackService.class);
        getContext().bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    private void releaseResources() {
        if (player != null) {
            player.release();
            player = null;
        }
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
        }
        if (isBound) {
            getContext().unbindService(serviceConnection);
        }

        if (handler != null && runnable != null) {
            handler.removeCallbacks(runnable);
        }
    }

    @Override
    protected void handleOnDestroy() {
        super.handleOnDestroy();
        releaseResources();
    }

    private void startForegroundService() {
        Intent serviceIntent = new Intent(getContext(), AudioPlaybackService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getContext().startForegroundService(serviceIntent);
        } else {
            getContext().startService(serviceIntent);
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    "audio_playback",
                    "Audio Playback",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager notificationManager = getContext().getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }

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

        if (audioUrl == null || token == null) {
            call.reject("Invalid arguments: audioURL and token are required");
            return;
        }

        if (Util.SDK_INT > 23) {
            try {
                PallyConDrmConfigration config = new PallyConDrmConfigration("USE5", token);
                ContentData content = new ContentData(audioUrl, config);
                WVMAgent = PallyConWvSDK.Companion.createPallyConWvSDK(getContext(),content);
                //WVMAgent = PallyConWvSDK.createPallyConWvSDK(getContext(),content);
                DrmSessionManager manager = WVMAgent.getDrmSessionManager();
                WVMAgent.setPallyConEventListener(drmListener);
                try {
                    mediaSource = WVMAgent.getMediaSource(manager);
                    trackSelector = new DefaultTrackSelector(getContext());


                } catch (PallyConException.ContentDataException e) {
                    System.out.println("285:"+e.getLocalizedMessage());
                    e.printStackTrace();
                    return;
                } catch (PallyConException.DetectedDeviceTimeModifiedException e) {
                    System.out.println("285:"+e.getLocalizedMessage());
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
                startForegroundService();
                call.resolve();
            }catch (Exception ex)
            {
                System.out.println("320:"+ex.getLocalizedMessage());
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
            call.resolve();
        }

    }

    @PluginMethod
    public void setAudioPlaybackRate(PluginCall call)
    {
        float speed = call.getFloat("speed");
        if(player != null && String.valueOf(speed) != null )
        {
            PlaybackParameters playbackParameters = new PlaybackParameters(speed);
            player.setPlaybackParameters(playbackParameters);
            call.resolve();
        }else {
            call.reject("Cannot set playback rate");
            Toast.makeText(getContext(),"Cannot set playback rate",Toast.LENGTH_LONG).show();
        }
    }

    @PluginMethod
    public void playAudio(PluginCall call)
    {
        if(player !=null && !player.isPlaying())
        {
            player.play();
            call.resolve();
        }
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
            call.reject("Player is not initialised");
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

        if (wakeLock.isHeld()) {
            wakeLock.release();
        }

        call.resolve();
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
            call.reject("Player is not initialised");
        }
    }

    //  loadAudioLecture(options: { audioURL:String, author:String, notificationThumbnail:String,title:String, seekTime:number, contentId:String }):Promise<void>;

    @PluginMethod
    public  void loadAudioLecture(PluginCall call)
    {
        JSObject ret = new JSObject();
        String audioUrl = call.getString("audioURL");

        try
        {
            if (player != null) {
                player.release();
            }

            Uri uri = Uri.parse(audioUrl);
            player = new ExoPlayer.Builder(getActivity().getApplicationContext()).build();
            MediaItem mediaItem = new MediaItem.Builder().setUri(uri).setMimeType(MimeTypes.APPLICATION_M3U8).build();
            player.setMediaItem(mediaItem);
            if (player.isPlaying()) {
                player.stop();
            }
            player.prepare();
            player.play();
            player.addListener(playerEventListener);

            startPlaybackCheck();

            call.resolve();
        }catch (Exception exception)
        {
            notifyListeners(exception.getMessage(),ret);
            call.reject(exception.getMessage());
        }
    }


}
