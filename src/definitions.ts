import { PluginListenerHandle } from "@capacitor/core";

export interface AudioDRMPlugin {
  
  loadPallyconSound(options: { audioURL:String, author:String, token:String,notificationThumbnail:String,title:String, seekTime:number, contentId:String, isSampleAudio:Boolean, email:String  }):Promise<void>;
  pauseAudio(): Promise<void>;
  setAudioPlaybackRate(options: { speed: number }): Promise<void>;
  seekToTime(options: { seekTime: number }): Promise<void>;
  stopCurrentAudio(): Promise<void>;
  addListener(eventName: 'soundEnded', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isBuffering', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'audioLoaded', listenerFunc: (soundDuration: number) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'notificationPreviousCalled', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'notificationNextCalled', listenerFunc: () => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'playerError', listenerFunc: (message: any) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isAudioPlaying', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'isAudioPause', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  playAudio(): Promise<void>;
  getPaused(): Promise<{ paused: boolean }>;
  getCurrentTime():Promise<{time:number }>;
  removeNotificationAndClearAudio():Promise<void>;

  loadAudioLecture(options: { audioURL:String, author:String, notificationThumbnail:String,title:String, seekTime:number, contentId:String }):Promise<void>;


}



