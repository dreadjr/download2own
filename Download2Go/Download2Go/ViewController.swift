//
//  ViewController.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/7/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
//    let urlString = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
//    let urlString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
//    let urlString = "https://bitmovin-a.akamaihd.net/content/playhouse-vr/mpds/105560.mpd"
//    let urlString = "https://mdrm1.fbox.fpt.vn/live/DATA/K_PM/HLS_EZDRM/K_PM.m3u8"
    let urlString = "https://mdrm1.fbox.fpt.vn/vod/DATA/Stolen_2012/_/HLS_EZDRM/Stolen_2012.m3u8"
    lazy var downloader: HLSDownloader = {
//        let downloader = HLSDownloader(withUrl: "http://42.116.82.124/vod/DATA/Kung_Fu_League_China_2018/HLS/Kung_Fu_League_China_2018.m3u8")
        let downloader = HLSDownloader(withUrl: self.urlString)
        downloader.downloadProgressChanged = { [weak self] progress in
            self?.lblProgress.text = "\(progress * 100)%"
            self?.progressBar.progress = Float(progress)
        }
        downloader.didFinishDownloading = { url in
            print(url)
        }
        return downloader
    }()
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playerView: UIView!
    
    @IBAction func btnPlayOnline_Click() {
        guard let url = URL(string: self.urlString) else {
            return
        }
        self.play(url)
    }
    
    @IBAction func btnPlayOffline_Click() {
        self.downloader.download(self.urlString)
        self.downloader.didFinishDownloading = { [weak self] url in
            self?.play(url)
        }
    }
    
    func play(_ url: URL) {
        self.player = AVPlayer(url: url)
        self.player?.play()
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.videoGravity = .resizeAspect
        self.playerLayer?.frame = self.playerView.bounds
        self.playerView.layer.addSublayer(self.playerLayer!)
    }
    
    @IBAction func btnStart_Click() {
        self.downloader.download()
    }
    
    @IBAction func btnCancel_Click() {
        self.downloader.cancel()
    }
    
    @IBAction func btnResume_Click() {
        self.downloader.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}

