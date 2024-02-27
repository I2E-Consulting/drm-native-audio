import Foundation
import Capacitor
import AVFoundation
import MediaPlayer
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AudioDRMPlugin)
public class AudioDRMPlugin: CAPPlugin, AVAssetResourceLoaderDelegate {
    
    private let implementation = AudioDRM()
        
    private var timeObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var audioDRMViewModel = AudioDRMViewModel()
    
    let contentID: String! = "transcendmediaservices.keydelivery.eastus.media.azure.net"
    
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        self.notifyListeners("soundEnded", data: [:])
    }
    
    @objc public func setNotificationForAudio(title:String,thumbnailURL:String)
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        guard let item = AVPlayerConfiguration.sharedInstance.player.currentItem else {return}
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "BBT"
        
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
        
        
        addActionsToControlCenter()
    }
    
    @objc func pauseAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
       // print("Pause")
        call.resolve()
    }
    
    @objc func playAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.play()
        call.resolve([
            "value":"Play Event Called"
        ])
        
    }
    
    @objc func loadAzureDRMSoundURL(_ call: CAPPluginCall)
    {
        let audioURL = call.getString("audioURL") ?? "Denied"
        let audioTitle = call.getString("title") ?? "Denied"
        let thumbnailUrl = call.getString("notificationThumbnail") ?? "Invalid"
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        
        audioDRMViewModel.audioDRMToken = call.getString("token") ?? "invalid token"
        audioDRMViewModel.getSkdWithAlamofire(url: audioURL)
        { [self]
            skd in
            
            if skd
            {
                print(audioDRMViewModel.licenseURI)
                audioDRMViewModel.processLicenseURI(audioDRMViewModel.licenseURI, originalUrl: audioURL)
                { [self]
                    processed in
                    if processed
                    {
                        audioDRMViewModel.getSkdFromSecondURL(url: audioDRMViewModel.secondURL){ [self]
                            sound in
                            if sound
                            {
                                playMusic(streamingURL: audioURL,title: audioTitle, thumbnailURL: thumbnailUrl)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            AVPlayerConfiguration.sharedInstance.player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func playMusic(streamingURL:String, title:String,thumbnailURL: String)
    {
        let escapedString = streamingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AVPlayerConfiguration.sharedInstance.setPlayerWithURL()
        if let url = URL(string: escapedString!) {
            
            let asset = AVURLAsset(url: url)
            let queue = DispatchQueue(label: "LicenseGetQueue")
            asset.resourceLoader.setDelegate(self, queue: queue)
            let playerItem = AVPlayerItem(asset: asset)
            AVPlayerConfiguration.sharedInstance.player = AVPlayer(playerItem: playerItem)
            AVPlayerConfiguration.sharedInstance.player.play()
            setNotificationForAudio(title: title, thumbnailURL: thumbnailURL)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:  AVPlayerConfiguration.sharedInstance.player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            
            AVPlayerConfiguration.sharedInstance.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
                if AVPlayerConfiguration.sharedInstance.player.currentItem?.status == .readyToPlay {
                    
                    if (AVPlayerConfiguration.sharedInstance.player.currentItem?.duration) != nil
                    {
                        let totalSeconds = CMTimeGetSeconds((AVPlayerConfiguration.sharedInstance.player.currentItem?.asset.duration)!)
                        self.notifyListeners("audioLoaded", data: ["duration": totalSeconds])
                      //  print("Total Seconds \(totalSeconds)")
                        
                    }
                    
                    timeObserverToken = AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) in
                        guard let strongSelf = self else { return }
                        
                        if AVPlayerConfiguration.sharedInstance.player.currentItem?.isPlaybackLikelyToKeepUp == false {
                            self?.notifyListeners("isBuffering", data: [:])
                        } else {
                            let currentTimeSeconds = CMTimeGetSeconds(AVPlayerConfiguration.sharedInstance.player.currentTime())
                            strongSelf.notifyListeners("timeUpdate", data: ["time": currentTimeSeconds])
                            
                            
                        }
                    }
                    
                    playerItemStatusObserver = AVPlayerConfiguration.sharedInstance.player.currentItem?.observe(\.status, options: [.new, .old], changeHandler: { [weak self] (playerItem, change) in
                        if playerItem.status == .failed {
                            guard let error = playerItem.error else { return }
                            self?.notifyListeners("playerError", data: ["error": error.localizedDescription])
                        }
                    })
                }
               
                
            }
        }else
        {
            self.notifyListeners("playerError", data: ["error": "Error Loading URL."])
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let player = object as? AVPlayer {
            if player.timeControlStatus == .paused {
               // print("isAudioPause")
                self.notifyListeners("isAudioPause", data: [:])
            } else if player.timeControlStatus == .playing {
                //print("isAudioPlaying")
                self.notifyListeners("isAudioPlaying", data: [:])

            }
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.request.url else {
            self.notifyListeners("playerError", data: ["error": "Unable to read the url/host data."])
            //print("🔑", #function, "Unable to read the url/host data.")
            loadingRequest.finishLoading(with: NSError(domain: "com.error", code: -1, userInfo: nil))
            return false
        }
        
        
        fetchCertificate { [weak self] certificateData in
            guard let self = self, let certificateData = certificateData else {
                loadingRequest.finishLoading(with: NSError(domain: "com.error", code: -2, userInfo: nil))
                return
            }
            
            guard
                let contentIdData = contentID.data(using: String.Encoding.utf8),
                let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: nil),
                let dataRequest = loadingRequest.dataRequest else {
                loadingRequest.finishLoading(with: NSError(domain: "com.error", code: -3, userInfo: nil))
                self.notifyListeners("playerError", data: ["error": "Unable to read the SPC data."])
               // print(#function, "Unable to read the SPC data.")
                return
            }
            
            let ckcURL = URL(string: audioDRMViewModel.currentSkd.replacingOccurrences(of: "skd://", with: "https://")  )!
            var request = URLRequest(url: ckcURL)
            request.httpMethod = "POST"
            let assetIDString = self.contentID
            let postString = "spc=\(spcData.base64EncodedString())&assetId=\(String(describing: assetIDString))"
            request.setValue(String(postString.count), forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(audioDRMViewModel.audioDRMToken , forHTTPHeaderField: "authorization")
            request.httpBody = postString.data(using: .ascii, allowLossyConversion: true)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request) { data, response, error in
                if let data = data {
                    if var responseString = String(data:data,encoding:.utf8)
                    {
                        print(responseString)
                        responseString = responseString.replacingOccurrences(of: "<ckc>", with: "").replacingOccurrences(of: "</ckc>", with: "")
                        let ckcData = Data(base64Encoded: responseString)!
                        dataRequest.respond(with: ckcData)
                        loadingRequest.finishLoading()
                    }else
                    {
                        print(#function,"Unable to fetch the CKC")
                    }
                }else
                {
                    print(#function, "Unable to fetch the CKC.")
                    loadingRequest.finishLoading(with: NSError(domain: "com.error", code: -4, userInfo: nil))
                }
                
            }
            task.resume()
            
        }
        
        return true
        
    }
    
    private func fetchCertificate(completion: @escaping (Data?) -> Void) {
        let certificateURLString = "https://transcendapi.azurewebsites.net/fairplay.cer"
        guard let certificateURL = URL(string: certificateURLString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: certificateURL)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching certificate: \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let mimeType = httpResponse.mimeType, mimeType == "application/octet-stream",
                  let certificateData = data else {
                print("No data received or wrong response")
                completion(nil)
                return
            }
            
            completion(certificateData)
        }
        
        task.resume()
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
    
    @objc func seekToTime(_ call: CAPPluginCall)
    {
        let seconds = call.getDouble("seekTime") ?? 1.0
        let preferredTimeScale: CMTimeScale = 1_000 // Represents the scale of a second. 1000 means milliseconds.
        let time = CMTime(seconds: seconds, preferredTimescale: preferredTimeScale)
        
        AVPlayerConfiguration.sharedInstance.player.seek(to: time, completionHandler: { success in
            if success {
                print("Successfully moved to the specified time.")
            } else {
                self.notifyListeners("playerError", data: ["error": "Seek Failed"])
            }
        })
    }
    
    @objc func stopCurrentAudio(_ call: CAPPluginCall)
    {
        AVPlayerConfiguration.sharedInstance.player.pause()
        AVPlayerConfiguration.sharedInstance.player.rate = 0
        AVPlayerConfiguration.sharedInstance.player.replaceCurrentItem(with: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            self.notifyListeners("playerError", data: ["error": "Failed to deactivate audio session: \(error)"])

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
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previousButtonTapped))
    }
    func addActionToNextCommand(){
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonTapped))
    }
    func addActionToChangePlayBackPosition(){
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = false
        // MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition))
    }
    func addActionToseekForwardCommand(){
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = false
        //  MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekForward))
    }
    func addActionToseekBackwordCommand(){
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = false
        //  MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekBackword))
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
}
