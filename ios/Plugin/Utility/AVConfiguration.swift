//
//  AVConfiguration.swift
//  Plugin
//
//  Created by Parth Sheth on 06/02/24.
//  Copyright © 2024 Max Lynch. All rights reserved.
//

import Foundation
import AVKit

class AVPlayerConfiguration
{
    static let sharedInstance = AVPlayerConfiguration()
    let controller = AVPlayerViewController()
    var player: AVPlayer = AVPlayer()
    
    func setPlayerWithURL()
    {
        player.actionAtItemEnd = .none
        controller.player = player
        
    }
}
