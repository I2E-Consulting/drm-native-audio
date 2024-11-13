package com.example.audiodrm;


import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.RemoteException;
import android.view.WindowManager;
import android.os.Handler;
import android.Manifest;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

//  private AudioRecord audioRecord;
//  private Handler handler;
//  private Runnable checkMicrophoneUsage;
//  private static final int PERMISSION_REQUEST_CODE = 1;
//
//  private AudioBroadcastReceiver audioBroadcastReceiver;

//  private static final int REQUEST_MIC_PERMISSION = 200;
//
//  private AudioRecord micRecorder;
//  private Handler micHandler;
//  private Runnable micChecker;
//  private static final int MIC_CHECK_INTERVAL = 1000; // 1 second

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

//    getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
//    micHandler = new Handler();
//    micChecker = new Runnable() {
//      @Override
//      public void run() {
//        try {
//          checkAndBlockMic();
//        } catch (MicUnaccessibleException | RemoteException e) {
//          e.printStackTrace();
//          // Handle the exception (e.g., notify the user)
//        }
//        // Re-run this check after the specified interval
//        micHandler.postDelayed(micChecker, MIC_CHECK_INTERVAL);
//      }
//    };
//    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
//      != PackageManager.PERMISSION_GRANTED) {
//      // Request microphone permission
//      ActivityCompat.requestPermissions(this,
//        new String[]{Manifest.permission.RECORD_AUDIO},
//        REQUEST_MIC_PERMISSION);
//    } else {
//      micHandler.post(micChecker);
//    }

  }

//  private void checkAndBlockMic() throws MicUnaccessibleException, RemoteException {
//    if (micRecorder == null || micRecorder.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
//      Toast.makeText(this, "Microphone check started", Toast.LENGTH_SHORT).show();
//
//      startMicBlocker();
//    }else {
//
//    }
//  }
//
//  @Override
//  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
//                                         @NonNull int[] grantResults) {
//    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//    if (requestCode == REQUEST_MIC_PERMISSION) {
//      if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//        micHandler.post(micChecker);
//      } else {
//        // Permission denied, show a message to the user
//        Toast.makeText(this, "Microphone permission is required to use this app", Toast.LENGTH_SHORT).show();
//      }
//    }
//  }
//
//
//  private void startMicBlocker() throws MicUnaccessibleException {
//    try {
//      micRecorder = new AudioRecord(
//        MediaRecorder.AudioSource.MIC, 44100,
//        AudioFormat.CHANNEL_IN_MONO,
//        AudioFormat.ENCODING_PCM_16BIT, 44100);
//
//      if (micRecorder.getState() != AudioRecord.STATE_INITIALIZED) {
//        throw new MicUnaccessibleException("Mic didn't successfully initialize");
//      }
//
//      micRecorder.startRecording();
//      if (micRecorder.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
//        micRecorder.release();
//        micRecorder = null;
//        throw new MicUnaccessibleException("Mic is in use and can't be accessed");
//      }
//      stopMicBlocker();
//    } catch (SecurityException e) {
//      e.printStackTrace();
//      throw new MicUnaccessibleException("Permission denied for microphone access");
//    }
//  }
//
//  private void stopMicBlocker() {
//    if (micRecorder != null) {
//      if (micRecorder.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
//        micRecorder.stop();
//      }
//      micRecorder.release();
//      micRecorder = null;
//    }
//  }
//
//
//
//  @Override
//  public void onDestroy() {
//    super.onDestroy();
//
//    micHandler.removeCallbacks(micChecker);
//    stopMicBlocker();
//
//   // unregisterReceiver(audioBroadcastReceiver);
//   // handler.removeCallbacks(checkMicrophoneUsage);
//  }
//
//  public static class MicUnaccessibleException extends Exception {
//    public MicUnaccessibleException(String message) {
//      super(message);
//    }
//  }

//  private void startMicrophoneCheck() {
//    handler = new Handler();
//    checkMicrophoneUsage = new Runnable() {
//      @Override
//      public void run() {
//        Toast.makeText(getApplicationContext(),"THREAD RUNNING",Toast.LENGTH_LONG).show();
//        Log.e("MICROPHONE TAG","THREAD STARTED");
//        if (isMicrophoneInUse()) {
//          Log.e("MICROPHONE TAG","isMicrophoneInUse");
//          handleMicrophoneUsage();
//        }
//        handler.postDelayed(this, 1000);
//      }
//    };
//    handler.post(checkMicrophoneUsage); // Start the initial check
//  }
//
//  private boolean isMicrophoneInUse() {
//    try {
//      if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
//        != PackageManager.PERMISSION_GRANTED) {
//        return false;
//      }
//
//      if (audioRecord == null) {
//        int bufferSize = AudioRecord.getMinBufferSize(44100,
//          android.media.AudioFormat.CHANNEL_IN_MONO,
//          android.media.AudioFormat.ENCODING_PCM_16BIT);
//        audioRecord = new AudioRecord(
//          android.media.MediaRecorder.AudioSource.MIC,
//          44100,
//          android.media.AudioFormat.CHANNEL_IN_MONO,
//          android.media.AudioFormat.ENCODING_PCM_16BIT,
//          bufferSize);
//      }
//      audioRecord.startRecording();
//      audioRecord.stop();
//
//      audioRecord.startRecording();
//      audioRecord.stop();
//
//      audioRecord.startRecording();
//      int recordingState = audioRecord.getRecordingState();
//      audioRecord.stop();
//
//      System.out.println(recordingState );
//      System.out.println(AudioRecord.RECORDSTATE_STOPPED);
//
//      return recordingState != AudioRecord.RECORDSTATE_STOPPED;
//    } catch (Exception e) {
//      e.printStackTrace();
//      return false;
//    }
//  }
//
//  private void handleMicrophoneUsage() {
//    Log.e("MICROPHONE TAG","HANDLE MICROPHONE USUAGE");
//  }
}
