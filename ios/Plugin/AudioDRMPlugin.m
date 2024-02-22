#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(AudioDRMPlugin, "AudioDRM",
           CAP_PLUGIN_METHOD(pauseAudio, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(playAudio, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(loadAzureDRMSoundURL, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setAudioPlaybackRate, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(seekToTime, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stopCurrentAudio, CAPPluginReturnPromise);
           
)

