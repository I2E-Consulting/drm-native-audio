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
    var nowPlayingInfo = [String: Any]()

    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        DispatchQueue.main.async
        {
            self.notifyListeners("soundEnded", data: [:])
        }
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
    
    @objc func getCurrentTime(_ call: CAPPluginCall)
    {
        let currentTimeSeconds = CMTimeGetSeconds(AVPlayerConfiguration.sharedInstance.player.currentTime())

        call.resolve([
            "time":currentTimeSeconds
        ])
        
    }
    
    
    
  
    @objc func loadAzureDRMSoundURL(_ call: CAPPluginCall)
    {
        let audioURL = call.getString("audioURL") ?? "error"
        let audioTitle = call.getString("title") ?? "error"
        let audioAuthor = call.getString("authorName") ?? " "
        let thumbnailUrl = call.getString("notificationThumbnail") ?? "Invalid"
        let seekTimeTo = call.getDouble("seekTime") ??  00
        
        audioDRMViewModel.audioDRMToken = call.getString("token") ?? "invalid token"
        audioDRMViewModel.getSkdWithAlamofire(url: audioURL)
        { [self]
            skd in
            if skd
            {
                audioDRMViewModel.processLicenseURI(audioDRMViewModel.licenseURI, originalUrl: audioURL)
                { [self]
                    processed in
                    if processed
                    {
                        audioDRMViewModel.getSkdFromSecondURL(url: audioDRMViewModel.secondURL){ [self]
                            sound in
                            if sound
                            {
                                playMusic(streamingURL: audioURL,title: audioTitle, thumbnailURL: thumbnailUrl,startTime: seekTimeTo, authorName: audioAuthor)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func playMusic(streamingURL:String, title:String,thumbnailURL: String,startTime:Double, authorName:String)
    {
        let escapedString = streamingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AVPlayerConfiguration.sharedInstance.setPlayerWithURL()

        let existingPlayer = AVPlayerConfiguration.sharedInstance.player
        if existingPlayer.rate != 0 {
            existingPlayer.pause()
            existingPlayer.replaceCurrentItem(with: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        
        if let url = URL(string: escapedString!) {
            
            let asset = AVURLAsset(url: url)
            let queue = DispatchQueue(label: "LicenseGetQueue")
            asset.resourceLoader.setDelegate(self, queue: queue)
            let playerItem = AVPlayerItem(asset: asset)
            AVPlayerConfiguration.sharedInstance.player = AVPlayer(playerItem: playerItem)
            AVPlayerConfiguration.sharedInstance.player.play()
            
            let seekTime = CMTime(seconds: startTime, preferredTimescale: 1_000)
            playerItem.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
                guard let self = self, finished else { return }
                AVPlayerConfiguration.sharedInstance.player.play()
                
                //self.updateNowPlayingInfo(time: startTime)
            }
            
           NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:  AVPlayerConfiguration.sharedInstance.player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            NotificationCenter.default.addObserver(self, selector: #selector(errorNotificationCall), name: .audioPlayerErrorNotification , object: nil)
            
            AVPlayerConfiguration.sharedInstance.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
                if AVPlayerConfiguration.sharedInstance.player.currentItem?.status == .readyToPlay {
                    setNotificationForAudio(title: title, thumbnailURL: thumbnailURL, authorName: authorName)

                    if (AVPlayerConfiguration.sharedInstance.player.currentItem?.duration) != nil
                    {
                        let totalSeconds = CMTimeGetSeconds((AVPlayerConfiguration.sharedInstance.player.currentItem?.asset.duration)!)
                        DispatchQueue.main.async
                        {
                            self.notifyListeners("audioLoaded", data: ["duration": totalSeconds])
                        }
                    }
                    
                    timeObserverToken = AVPlayerConfiguration.sharedInstance.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) in
                        guard let strongSelf = self else { return }
                        
                        if AVPlayerConfiguration.sharedInstance.player.currentItem?.isPlaybackLikelyToKeepUp == false {
                            DispatchQueue.main.async
                            {
                                self?.notifyListeners("isBuffering", data: [:])
                            }
                        } else {
                           
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
    }
    
    @objc public func setNotificationForAudio(title:String,thumbnailURL:String,authorName:String)
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()

        guard let item = AVPlayerConfiguration.sharedInstance.player.currentItem else {return}
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = authorName
        
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
                DispatchQueue.main.async
                {
                    self.notifyListeners("isAudioPause", data: [:])
                }
            } else if player.timeControlStatus == .playing {
                DispatchQueue.main.async
                {
                    self.notifyListeners("isAudioPlaying", data: [:])
                }
            }
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.request.url else {
            self.notifyListeners("playerError", data: ["error": "Unable to read the url/host data."])
            NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Unable to read the url/host data."])
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
                NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Unable to read the SPC data."])
                //self.notifyListeners("playerError", data: ["error": "Unable to read the SPC data."])
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
                        if responseString.contains("<ckc>") || responseString.contains("</ckc>") {
                            responseString = responseString.replacingOccurrences(of: "<ckc>", with: "").replacingOccurrences(of: "</ckc>", with: "")
                            let ckcData = Data(base64Encoded: responseString)!
                            dataRequest.respond(with: ckcData)
                            loadingRequest.finishLoading()
                        }else
                        {
                            NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Unable to read the SPC data."])
                        }
                    }else
                    {
                        NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "Unable to read the SPC data."])
                    }
                }else
                {
                    NotificationCenter.default.post(name: .audioPlayerErrorNotification, object: nil, userInfo: ["playerError": "com.error -4"])
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
        
        let request = URLRequest(url: certificateURL)
        
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
                    self.notifyListeners("playerError", data: ["error": "Seek Failed"])
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
        
        // MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
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
    
    @objc func errorNotificationCall(_ notification: Notification) {
        
        UIApplication.shared.endReceivingRemoteControlEvents()
        
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let notificationText = userInfo["playerError"] as? String {
                print("Received notification text: \(notificationText)")
                self.notifyListeners("playerError", data: ["error": notificationText])
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
}
