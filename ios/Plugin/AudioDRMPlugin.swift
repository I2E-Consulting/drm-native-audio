import Foundation
import Capacitor
import AVFoundation
import MediaPlayer
import PallyConFPSSDK

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AudioDRMPlugin)
public class AudioDRMPlugin: CAPPlugin {
    
    private let implementation = AudioDRM()
    private var timeObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var audioDRMViewModel = AudioDRMViewModel()
    var nowPlayingInfo = [String: Any]()
    var sampleAudio:Bool = false
    var fpsSDK: PallyConFPSSDK?
    
    let CERTIFICATE_URL = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=USE5"
    
    @objc func loadPallyconSound(_ call: CAPPluginCall)
    {
        let audioURL = call.getString("audioURL") ?? "error"
        let audioTitle = call.getString("title") ?? "error"
        let thumbnailUrl = call.getString("notificationThumbnail") ?? "Invalid"
        let seekTimeTo = call.getDouble("seekTime") ??  00
        let contentId = call.getString("contentId") ?? "error"
        let author = call.getString("author") ?? ""
        let userEncryptedEmail = call.getString("email") ?? ""
        
        sampleAudio = call.getBool("isSampleAudio") ?? false
        
        audioDRMViewModel.audioDRMToken = call.getString("token") ?? "invalid token"
        playMusic(streamingURL: audioURL, title: audioTitle, thumbnailURL: thumbnailUrl, startTime: seekTimeTo,contentId: contentId, author:author, email:userEncryptedEmail)
        
    }
    
    func playMusic(streamingURL:String, title:String,thumbnailURL: String,startTime:Double, contentId: String, author:String,email: String)
    {
        do
        {
            let escapedString = streamingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            fpsSDK = PallyConFPSSDK()
            //try fpsSDK = PallyConFPSSDK(siteId: "USE5", siteKey: "LlS8F5b5rOmdM9leG0tYJH1kcLMO0jxz", fpsLicenseDelegate: nil)
            let existingPlayer = AVPlayerConfiguration.sharedInstance.player
            if existingPlayer.rate != 0 {
                existingPlayer.pause()
                existingPlayer.replaceCurrentItem(with: nil)
            }
            
            AVPlayerConfiguration.sharedInstance.setPlayerWithURL()
            if let url = URL(string: escapedString!) 
            {
                
                let asset = AVURLAsset(url: url)
                let config = PallyConDrmConfiguration(avURLAsset: asset, contentId: contentId, certificateUrl: CERTIFICATE_URL,authData: audioDRMViewModel.audioDRMToken)

                
               fpsSDK?.prepare(Content: config)
                
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
                nowPlayingInfo[MPMediaItemPropertyArtist] = author
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

                
                let playerItem = AVPlayerItem(asset: asset)
                AVPlayerConfiguration.sharedInstance.player = AVPlayer(playerItem: playerItem)
                AVPlayerConfiguration.sharedInstance.player.play()
                
                let seekTime = CMTime(seconds: startTime, preferredTimescale: 1_000)
                playerItem.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
                    guard let self = self, finished else { return }
                    AVPlayerConfiguration.sharedInstance.player.play()
                    self.updateNowPlayingInfo(time: startTime)

                }
                
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)

                
                NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:  AVPlayerConfiguration.sharedInstance.player.currentItem)
                NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
                NotificationCenter.default.addObserver(self, selector: #selector(errorNotificationCall), name: .audioPlayerErrorNotification , object: nil)
                
                AVPlayerConfiguration.sharedInstance.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                
                AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
                    if AVPlayerConfiguration.sharedInstance.player.currentItem?.status == .readyToPlay {
                        setNotificationForAudio(title: title, thumbnailURL: thumbnailURL, author: author)

                        if (AVPlayerConfiguration.sharedInstance.player.currentItem?.duration) != nil
                        {
                            
                            let totalSeconds = CMTimeGetSeconds((AVPlayerConfiguration.sharedInstance.player.currentItem?.asset.duration)!)
                            self.notifyListeners("audioLoaded", data: ["duration": totalSeconds])
                            
                        }
                        
                        timeObserverToken = AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) in
                            guard let strongSelf = self else { return }
                            
                            if AVPlayerConfiguration.sharedInstance.player.currentItem?.isPlaybackLikelyToKeepUp == false {
                                self?.notifyListeners("isBuffering", data: [:])
                            }
                        }

                        playerItemStatusObserver = AVPlayerConfiguration.sharedInstance.player.currentItem?.observe(\.status, options: [.new, .old], changeHandler: { (playerItem, change) in
                            if playerItem.status == .failed {
                                guard let error = playerItem.error else { return }
                                NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": error.localizedDescription])
                            }
                        })
                    }
                   
                    
                }
            }else
            {
                NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "error.localizedDescription"])
            }
        } catch  PallyConSDKException.DatabaseProcessError(let message)
        {
            print(message)
        } catch
        {
            print("Unknown Error occured")
        }
        
      
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        self.notifyListeners("soundEnded", data: [:])
    }
    
    @objc public func setNotificationForAudio(title:String,thumbnailURL:String,author:String)
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        guard let item = AVPlayerConfiguration.sharedInstance.player.currentItem else {return}
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = author
        
        if let albumArtURL = URL(string: thumbnailURL) {
            URLSession.shared.dataTask(with: albumArtURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { [self] in
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
        
        
        addActionsToControlCenter()
    }
    
    @objc func pauseAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
        call.resolve()
    }
    
    @objc func playAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.play()
        call.resolve([
            "value":"Play Event Called"
        ])
        
    }
    
    func removeTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            AVPlayerConfiguration.sharedInstance.player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func seekToTimeWhileLoading(playerItem: AVPlayerItem, startTime: Double) {
        let time = CMTime(seconds: startTime, preferredTimescale: 1_000)
        playerItem.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            guard let self = self, finished else { return }
            AVPlayerConfiguration.sharedInstance.player.play()
            
            self.updateNowPlayingInfo(time: startTime)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let player = object as? AVPlayer {
            
            if player.timeControlStatus == .paused {
                self.notifyListeners("isAudioPause", data: [:])
            } else if player.timeControlStatus == .playing {
                self.notifyListeners("isAudioPlaying", data: [:])

            }
            
        }
        
        if keyPath == #keyPath(AVPlayerItem.status)
        {
            guard let playerItem = object as? AVPlayerItem else
            {
                return
            }
            switch playerItem.status
            {
            case .failed:
                self.notifyListeners("playerError", data: ["message": "audio failed to play"])
            case .unknown:
                self.notifyListeners("playerError", data: ["message": "Audio Failed due to unknown error"])
            case .readyToPlay:
                print("Failed to unknown audio")
            @unknown default:
                //self.notifyListeners("playerError", data: ["message": "audio failed to play"])
                print("Failed to unknown audio")
            }
        }
        
    }

    @objc func removeNotificationAndClearAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
        AVPlayerConfiguration.sharedInstance.player.rate = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        DispatchQueue.main.async {
            UIApplication.shared.endReceivingRemoteControlEvents()
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            AVPlayerConfiguration.sharedInstance.player.pause()
            AVPlayerConfiguration.sharedInstance.player.rate = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            
            DispatchQueue.main.async {
                UIApplication.shared.endReceivingRemoteControlEvents()
            }
            
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        }
        
        call.resolve()
    }
    
    @objc func getCurrentTime(_ call: CAPPluginCall)
    {
        let currentTimeSeconds = CMTimeGetSeconds(AVPlayerConfiguration.sharedInstance.player.currentTime())
        
        call.resolve([
            "time":currentTimeSeconds
        ])
        
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
            return
        }
        
        switch interruptionType {
        case .began:
            AVPlayerConfiguration.sharedInstance.player.pause()
        case .ended:
            if let optionsRawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsRawValue)
                if options.contains(.shouldResume) {
                    AVPlayerConfiguration.sharedInstance.player.play()
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc func setAudioPlaybackRate(_ call: CAPPluginCall)
    {
        let playbackRate = call.getFloat("speed") ?? 1.0
        AVPlayerConfiguration.sharedInstance.player.rate = playbackRate
        
    }
    
    @objc func seekToTime(_ call: CAPPluginCall) {
        let seconds = call.getDouble("seekTime") ?? 0.0
        let preferredTimeScale: CMTimeScale = 1_000
        let time = CMTime(seconds: seconds, preferredTimescale: preferredTimeScale)

        DispatchQueue.main.async {
            AVPlayerConfiguration.sharedInstance.player.seek(to: time, completionHandler: { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    print("Successfully moved to the specified time.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.updateNowPlayingInfo(time: seconds)
                    }
                    self.notifyListeners("seekSuccess", data: ["time": seconds])
                } else {
                    NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Seek Failed"])
                    self.notifyListeners("playerError", data: ["message": "Seek Failed"])
                }
            })
        }
    }
    
    func updateNowPlayingInfo(time: Double) {
        guard let currentItem = AVPlayerConfiguration.sharedInstance.player.currentItem else { return }
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AVPlayerConfiguration.sharedInstance.player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }

    @objc func stopCurrentAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
        AVPlayerConfiguration.sharedInstance.player.rate = 0
        AVPlayerConfiguration.sharedInstance.player.replaceCurrentItem(with: nil)
        
        DispatchQueue.main.async {
            UIApplication.shared.endReceivingRemoteControlEvents()
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Failed to deactivate audio session: \(error)"])
        }
        
        call.resolve()
    }
    
    func addActionsToControlCenter(){
        addActionToPlayCommand()
        addActionToPauseCommnd()
        addActionToPreviousCommand()
        addActionToNextCommand()
        addActionToChangePlayBackPosition()
        addActionToseekForwardCommand()
        addActionToseekBackwordCommand()
    }
    
    func addActionToPlayCommand(){
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(notificationPlay))
    }
    
    func addActionToPauseCommnd(){
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(notificationPause))
    }
    
    func addActionToPreviousCommand(){
        if sampleAudio
        {
            MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = false
        }else
        {
            MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        }
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previousButtonTapped))
    }
    
    func addActionToNextCommand(){
        
        if sampleAudio
        {
            MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = false
        }else
        {
            MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        }        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonTapped))
    }
    
    func addActionToChangePlayBackPosition(){
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition))
    }
    
    func addActionToseekForwardCommand(){
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = false
        //  MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekForward))
    }
    
    func addActionToseekBackwordCommand(){
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = false
        //  MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekBackword))
    }
    
    @objc func errorNotificationCall(_ notification: Notification) {
        
        UIApplication.shared.endReceivingRemoteControlEvents()
        
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let notificationText = userInfo["playerError"] as? String {
                print("Received notification text: \(notificationText)")
                self.notifyListeners("playerError", data: ["message": notificationText])
            }
        }
    }
    
    @objc func notificationPlay() -> MPRemoteCommandHandlerStatus
    {
        AVPlayerConfiguration.sharedInstance.player.play()
        return .success
    }
    
    @objc func notificationPause() -> MPRemoteCommandHandlerStatus
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
        return .success
    }
    
    @objc func previousButtonTapped() -> MPRemoteCommandHandlerStatus
    {
        self.notifyListeners("notificationPreviousCalled", data: [:])
        return .success
    }
    
    @objc func nextButtonTapped() -> MPRemoteCommandHandlerStatus
    {
        self.notifyListeners("notificationNextCalled", data: [:])
        return .success
    }
    
    @objc func getPaused(_ call: CAPPluginCall)
    {
        let isPlaying = AVPlayerConfiguration.sharedInstance.player.rate > 0
        call.resolve([
            "paused": !isPlaying
        ])
    }
    
    @objc func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        let newTime = CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        AVPlayerConfiguration.sharedInstance.player.seek(to: newTime) { completed in
            // Optionally handle completion
        }
        return .success
    }
}
