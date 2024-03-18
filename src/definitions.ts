import { PluginListenerHandle } from "@capacitor/core";

export interface AudioDRMPlugin {
  loadAzureDRMSoundURL(options: { audioURL:String, authorName: String,title:String,notificationThumbnail:String,seekTime:number, token:String}):Promise<void>;
  pauseAudio(): Promise<void>;
  setAudioPlaybackRate(options: { speed: number }): Promise<void>;
  seekToTime(options: { seekTime: number }): Promise<void>;
  stopCurrentAudio(): Promise<void>;
  addListener(eventName: 'soundEnded', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isBuffering', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'audioLoaded', listenerFunc: (soundDuration: number) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'notificationPreviousCalled', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'notificationNextCalled', listenerFunc: () => void): Promise<PluginListenerHandle>;
  // addListener(eventName: 'timeUpdate', listenerFunc: (currentTime: number) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'playerError', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isAudioPlaying', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isAudioPause', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  playAudio(): Promise<void>;
  getPaused(): Promise<{ paused: boolean }>;
  getCurrentTime():Promise<{time:number }>;
  removeNotificationAndClearAudio():Promise<void>;

}



