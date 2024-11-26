package com.transcend.plugins.drmnativeaudio;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AudioEventReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action != null && action.startsWith("com.transcend.plugins.drmnativeaudio.")) {

            String eventData = intent.getStringExtra("data");
            if (eventData != null) {
            }
        }
    }
}
