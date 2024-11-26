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
    // AudioDRM.addListener('soundEnded', () => {
    //   console.log('Sound playback ended');
    // });


  }

  ngOnInit(): void {
  }

  playDRMAudio():void
  {
    AudioDRM.loadPallyconSound(
      {
        audioURL:"https://bbtassets.blob.core.windows.net/pallycon-audio-test/99/dash/stream.mpd",
        token:"eyJkcm1fdHlwZSI6IldpZGV2aW5lIiwic2l0ZV9pZCI6IlVTRTUiLCJ1c2VyX2lkIjoiMiIsImNpZCI6IjEiLCJwb2xpY3kiOiJHZk5mSlBsTWVnUWg5NHgyVXpJQkRSTHhyNGEySUM5QmhYMVBEQ0dVTVBIeVduZEYrMnRVK0psbUdRXC9Fc0F6N25tSFdLZjdTVXQxRGl5MU43aG45eHc9PSIsInRpbWVzdGFtcCI6IjIwMjQtMTEtMjVUMDM6MDE6MThaIiwiaGFzaCI6Ik5mXC9TNzlhQlwvNFJJMnRSV2lBbFBZZ3gybnkxOUN6aW02T0RJK1VPamlsdz0iLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsImtleV9yb3RhdGlvbiI6ZmFsc2V9",
        notificationThumbnail: "https://picsum.photos/200/300",
        title:"Bhagvad Gita",
        seekTime:60,
        contentId:"1",
        author:"Transcend",
        isSampleAudio:true,
        email:"parth.sheth58@gmail.com"
      })

    AudioDRM.addListener('soundEnded', () => {
      AudioDRM.loadPallyconSound(
        {
          audioURL:"https://bbtassets.blob.core.windows.net/pallycon-audio-test/100/dash/stream.mpd",
          token:"eyJkcm1fdHlwZSI6IldpZGV2aW5lIiwic2l0ZV9pZCI6IlVTRTUiLCJ1c2VyX2lkIjoiMiIsImNpZCI6IjEiLCJwb2xpY3kiOiJHZk5mSlBsTWVnUWg5NHgyVXpJQkRSTHhyNGEySUM5QmhYMVBEQ0dVTVBIeVduZEYrMnRVK0psbUdRXC9Fc0F6N25tSFdLZjdTVXQxRGl5MU43aG45eHc9PSIsInRpbWVzdGFtcCI6IjIwMjQtMTEtMjZUMDM6MzA6NThaIiwiaGFzaCI6InBSdVJ3VktEWmNWSEVzSENobTBGM1MydHVBQUpHVlwvM1FYdVwvbjBPZUIzTT0iLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsImtleV9yb3RhdGlvbiI6ZmFsc2V9",
          notificationThumbnail: "https://picsum.photos/200/300",
          title:"Bhagvad Gita",
          seekTime:60,
          contentId:"1",
          author:"Transcend",
          isSampleAudio:true,
          email:"parth.sheth58@gmail.com"
        })
    });



    //   AudioDRM.addListener('notificationPreviousCalled', () => {
    //     console.log('NotificationPreviousCalled called ');
    //   });

    //   AudioDRM.addListener('notificationNextCalled', () => {
    //     console.log('NotificationNextCalled called ');
    //   });



      AudioDRM.addListener('audioLoaded', (info: any) => {
        console.log('Duration:', info.soundDuration);
    });

      AudioDRM.addListener('isAudioPause',() => {
        console.log("Event audio is paused")
      })

      AudioDRM.addListener('isAudioPlaying',() => {
        console.log("Event audio is played")
      })

      AudioDRM.addListener('playerError', (message) => {
        console.error('AVPlayer Error:', message);
      });


  }


  async getPaused()
  {
    const result = await AudioDRM.getPaused();

    console.log("Audio Paused:"+ result.paused)
  }

  stopAudio()
  {
   // AudioDRM.stopCurrentAudio()
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


  //  AudioDRM.addListener('playerError', (error) => {
  //   console.error('AVPlayer Error:', error);
  // });



  }

  play(): void
  {
    AudioDRM.playAudio()
  }

  pause(): void {
     AudioDRM.pauseAudio()
  }


  getCurrentTime(): void {
    AudioDRM.getCurrentTime()
 }





}
