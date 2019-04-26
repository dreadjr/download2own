//
//  PlaybackViewController.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/25/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import BitmovinPlayer

class PlaybackViewController: UIViewController {
    
     @IBOutlet weak var playerContainerView: UIView!
    var sourceItem: SourceItem!
    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.playSourceItem()
    }
    
    func playSourceItem() {
        let config = PlayerConfiguration()
        config.sourceItem = self.sourceItem
        
        let player = BitmovinPlayer(configuration: config)
        let playerView = BMPBitmovinPlayerView(player: player, frame: CGRect.zero)
        
//        player.add(listener: self)
        //        playerView.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = self.playerContainerView.bounds
        
        self.playerView?.removeFromSuperview()
        
        self.playerContainerView.addSubview(playerView)
        self.playerContainerView.bringSubviewToFront(playerView)
        
//        self.player?.remove(listener: self)
        self.player?.destroy()
        self.player = nil
        self.playerView = playerView
        self.player = player
    }

    deinit {
        self.player?.destroy()
    }

}
