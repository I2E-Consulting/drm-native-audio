import { Component, OnInit } from '@angular/core';
import { AudioDRM } from 'drm-native-audio';
import { timer } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {

  currentTime = 0;
  soundDuration = 0;
  title = 'example';

  constructor()
  {
    AudioDRM.addListener('soundEnded', () => {
      console.log('Sound playback ended');
    });


  }

  ngOnInit(): void {

  }

  playDRMAudio():void
  {
    AudioDRM.loadAzureDRMSoundURL(
      {
        audioURL:"https://transcendmediaservices-usea.streaming.media.azure.net/b03b8116-7fd2-489c-b860-64162ed35bc7/1681888961_05 Chapter 04.ism/manifest(format=m3u8-aapl,encryption=cbcs-aapl)",
        token:"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJteWlzc3VlciIsImF1ZCI6Im15YXVkaWVuY2UiLCJ1cm46bWljcm9zb2Z0OmF6dXJlOm1lZGlhc2VydmljZXM6Y29udGVudGtleWlkZW50aWZpZXIiOiI1YTljNzgwNS03MzlkLTRlNzAtYWQyNy1kM2IyNTdhNGE3YmUiLCJleHAiOjE3MTA4NTI5NTZ9._IHdI3d8TEYY3anikM-9LOsjPEtzQZh1_qVy0DAxCHg",
        notificationThumbnail: "https://picsum.photos/200/300",
        title:"Bhagvad Gita",
        seekTime:60,
        authorName: ""
      })

      AudioDRM.addListener('soundEnded', () => {
        console.log('Sound playback ended');
      });



      AudioDRM.addListener('notificationPreviousCalled', () => {
        console.log('NotificationPreviousCalled called ');
      });

      AudioDRM.addListener('notificationNextCalled', () => {
        console.log('NotificationNextCalled called ');
      });


    

      AudioDRM.addListener('audioLoaded', (info: any) => {
        this.soundDuration = info.duration;
        console.log('Duration:', info.duration);
    });

      AudioDRM.addListener('isAudioPause',() => {
        console.log("Event audio is paused")
      })

      AudioDRM.addListener('isAudioPlaying',() => {
        console.log("Event audio is played")
      })

      AudioDRM.addListener('playerError', (error) => {
        console.error('AVPlayer Error:', error);
      });

    
  }


  async getPaused()
  {
    const result = await AudioDRM.getPaused();

    console.log("Audio Paused:"+ result.paused)
  }

  removeNotification()
  {
    AudioDRM.removeNotificationAndClearAudio()
  }

  stopAudio()
  {
    AudioDRM.stopCurrentAudio()
  }

  seekToTime()
  {
    AudioDRM.seekToTime({seekTime:60})
  }

  setPlaybackRate()
  {
    AudioDRM.setAudioPlaybackRate({speed:2.0})
  }

  onPlayPause(): void {


   AudioDRM.addListener('playerError', (error) => {
    console.error('AVPlayer Error:', error);
  });


  }

  getTime()
  {
    AudioDRM.getCurrentTime().then((time) => {
      console.log("Current time:",time);
    })
  }

  play(): void
  {
    AudioDRM.playAudio()
  }

  pause(): void {
    AudioDRM.pauseAudio()
  }



}