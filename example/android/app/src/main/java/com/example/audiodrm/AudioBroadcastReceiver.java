package com.example.audiodrm;

//import android.content.BroadcastReceiver;
//import android.content.Context;
//import android.content.Intent;
//import android.media.AudioManager;
//import android.os.Handler;
//import android.os.HandlerThread;
//import android.util.Log;
//import android.widget.Toast;

//public class AudioBroadcastReceiver extends BroadcastReceiver {
//
//  private static HandlerThread handlerThread;
//  private static Handler handler;
//
//  public AudioBroadcastReceiver() {
//    if (handlerThread == null) {
//      handlerThread = new HandlerThread("AudioBroadcastReceiverThread");
//      handlerThread.start();
//      handler = new Handler(handlerThread.getLooper());
//    }
//  }
//
//  @Override
//  public void onReceive(Context context, Intent intent) {
//    String action = intent.getAction();
//    handler.post(() -> {
//      if (AudioManager.ACTION_AUDIO_BECOMING_NOISY.equals(action)) {
//        Log.d("AudioBroadcastReceiver", "Audio becoming noisy");
//        Toast.makeText(context, "Audio becoming noisy", Toast.LENGTH_LONG).show();
//      } else if (AudioManager.ACTION_MICROPHONE_MUTE_CHANGED.equals(action)) {
//        Toast.makeText(context.getApplicationContext(), "ACTION_MICROPHONE_MUTE_CHANGED", Toast.LENGTH_LONG).show();
//        boolean isMuted = intent.getBooleanExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, false);
//        Log.d("AudioBroadcastReceiver", "Microphone mute state changed: " + isMuted);
//      } else {
//        Log.d("AudioBroadcastReceiver", "DEFAULT");
//      }
//    });
//  }
//}
