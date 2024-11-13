//package com.example.audiodrm;
//
//import android.app.Notification;
//import android.app.NotificationChannel;
//import android.app.NotificationManager;
//import android.app.PendingIntent;
//import android.app.Service;
//import android.content.Intent;
//import android.content.pm.PackageManager;
//import android.media.AudioRecord;
//import android.os.Build;
//import android.os.Handler;
//import android.os.IBinder;
//
//import androidx.annotation.Nullable;
//import androidx.core.app.ActivityCompat;
//import androidx.core.app.NotificationCompat;
//
//import android.Manifest;
//import android.util.Log;
//
//public class AudioFocusService extends Service {
//
////  private static final int NOTIFICATION_ID = 1;
////  private static final String CHANNEL_ID = "AudioFocusServiceChannel";
////
////  private AudioRecord audioRecord;
////  private Handler handler;
////  private Runnable checkMicrophoneUsage;
//
//  @Override
//  public void onCreate() {
//    super.onCreate();
//
////    handler = new Handler();
////
////    checkMicrophoneUsage = new Runnable() {
////      @Override
////      public void run() {
////        if (isMicrophoneInUse()) {
////          Log.e("Started Recording","Thread");
////          handleMicrophoneUsage();
////        } else {
////          handler.postDelayed(this, 1000);
////        }
////      }
////    };
//  }
//
////  @Override
////  public int onStartCommand(Intent intent, int flags, int startId) {
////    createNotificationChannel();
////    Intent notificationIntent = new Intent(this, MainActivity.class);
////    PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
////
////    Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
////      .setContentTitle("Audio Focus Service")
////      .setContentText("Monitoring microphone usage")
////      .setSmallIcon(R.drawable.ic_launcher_background)
////      .setContentIntent(pendingIntent)
////      .build();
////
////    startForeground(NOTIFICATION_ID, notification);
////    handler.post(checkMicrophoneUsage);
////
////    return START_NOT_STICKY;
////  }
////
////  @Override
////  public void onDestroy() {
////    super.onDestroy();
////    handler.removeCallbacks(checkMicrophoneUsage);
////  }
////
////  @Nullable
////  @Override
////  public IBinder onBind(Intent intent) {
////    return null;
////  }
////
////  private void createNotificationChannel() {
////    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
////      NotificationChannel serviceChannel = new NotificationChannel(
////        CHANNEL_ID,
////        "Audio Focus Service Channel",
////        NotificationManager.IMPORTANCE_DEFAULT
////      );
////      NotificationManager manager = getSystemService(NotificationManager.class);
////      if (manager != null) {
////        manager.createNotificationChannel(serviceChannel);
////      }
////    }
////  }
////
////  private boolean isMicrophoneInUse() {
////    try {
////      Log.e("Started Recording","--");
////
////      if (audioRecord == null) {
////        int bufferSize = AudioRecord.getMinBufferSize(44100,
////          android.media.AudioFormat.CHANNEL_IN_MONO,
////          android.media.AudioFormat.ENCODING_PCM_16BIT);
////        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
////
////          return false;
////        }
////        audioRecord = new AudioRecord(
////          android.media.MediaRecorder.AudioSource.MIC,
////          44100,
////          android.media.AudioFormat.CHANNEL_IN_MONO,
////          android.media.AudioFormat.ENCODING_PCM_16BIT,
////          bufferSize);
////      }
////      audioRecord.startRecording();
//////      audioRecord.startRecording();
//////      audioRecord.startRecording();
//////      audioRecord.startRecording();
////
////      Log.e("Started Recording","INIT");
////      int recordingState = audioRecord.getRecordingState();
////      audioRecord.stop();
////      return recordingState != AudioRecord.RECORDSTATE_STOPPED;
////    } catch (Exception e) {
////      Log.e("ERROR Recording",e.getMessage());
////      e.printStackTrace();
////      return true;
////    }
////  }
////
////  private void handleMicrophoneUsage() {
////    // Exit the app when microphone usage is detected
//////    stopSelf();
//////    System.exit(0);
////  }
//}
