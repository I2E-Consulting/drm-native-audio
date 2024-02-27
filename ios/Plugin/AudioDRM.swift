import Foundation
import UIKit
import AVFoundation
import MediaPlayer

@objc public class AudioDRM: NSObject {
    
    let avplayer = AVPlayerConfiguration.sharedInstance.player

    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    @objc public func playAudioThroughUrl(_ value: String, thumbnail:String) -> String {
        print("Test")
        if let url = URL(string: value) {
            let playerItem = AVPlayerItem(url: url)
            avplayer.replaceCurrentItem(with: playerItem)
            avplayer.play()
        }

        setNotificationForAudio(thumbnailURL: thumbnail)
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:  AVPlayerConfiguration.sharedInstance.player.currentItem)
        
       return value
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        //self.notifyListeners("soundEnded", data: [:])
        print("Native Console:Sound ended")
      //  loadNextAudio()
    }
    
    @objc public func pauseAudio() -> String
    {
        avplayer.pause()
        return "Audio Paused"
    }
    
    @objc public func getCurrentTime() -> String
    {
        return "Time:"
    }
    
    @objc public func setNotificationForAudio(thumbnailURL:String)
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        guard let item = AVPlayerConfiguration.sharedInstance.player.currentItem else {return}
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Title 1"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Artist Name"

        if let albumArtURL = URL(string: thumbnailURL) {
            URLSession.shared.dataTask(with: albumArtURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                            return image
                        }
                        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AVPlayerConfiguration.sharedInstance.player.rate
                        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }.resume()
        } else {
            
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AVPlayerConfiguration.sharedInstance.player.rate
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }

    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }


    
}
