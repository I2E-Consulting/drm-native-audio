package com.transcend.plugins.drmnativeaudio;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import com.getcapacitor.JSObject;

public class AudioPlaybackService extends Service {

    private void notifyPlugin(String eventName, @Nullable JSObject data) {
        Intent intent = new Intent(this, AudioEventReceiver.class); // Explicit target
        intent.setAction("com.transcend.plugins.drmnativeaudio." + eventName);
        if (data != null) {
            intent.putExtra("data", data.toString());
        }
        sendBroadcast(intent);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        createNotificationChannel();

        Notification notification = new NotificationCompat.Builder(this, "audio_playback")
                .setContentTitle("Playing Audio")
                .setContentText("Your audio is playing.")
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build();

        startForeground(1, notification);

        // Example of sending an event
        notifyPlugin("isAudioPlaying", null);

        return START_NOT_STICKY;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    "audio_playback",
                    "Audio Playback",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
