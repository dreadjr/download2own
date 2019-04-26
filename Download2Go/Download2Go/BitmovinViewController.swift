//
//  PlayOnlineViewController.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/22/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import BitmovinPlayer

class BitmovinViewController: UIViewController {
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var progressDownload: UIProgressView!
    @IBOutlet weak var btnDownload: UIButton!
    
    var sourceItem: OfflineSourceItem!
    
    var downloader: BitmovinHLSDownloader!
    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?
    var link: [String: String] = [:] {
        didSet {
            let l = self.link["link"]
            self.lblLink.text = l
            
            guard let reach = Reachability.forInternetConnection() else {
                return
            }
            let offlineManager = OfflineManager.sharedInstance()
            let hlsS = HLSSource(url: URL(string: l ?? "")!)
            let sourceItem = SourceItem(hlsSource: hlsS)
            switch offlineManager.offlineState(for: sourceItem) {
            case .downloaded, .downloading, .suspended:
                if reach.currentReachabilityStatus() == .NotReachable {
                    guard offlineManager.isPlayableOffline(sourceItem: sourceItem),
                        let offlineSourceItem = offlineManager.createOfflineSourceItem(for: sourceItem, restrictedToAssetCache: true) else {
                            return
                    }
                    self.sourceItem = offlineSourceItem
                } else {
                    guard let offlineSourceItem = offlineManager.createOfflineSourceItem(for: sourceItem, restrictedToAssetCache: false) else {
                        return
                    }
                    self.sourceItem = offlineSourceItem
                }
                self.playSourceItem()
            default:
                ()
//                self.sourceItem = sourceItem
//                offlineManager.add(listener: self, for: self.sourceItem)
            }
//            if downloader != nil {
//                downloader.destroy()
//                downloader = nil
//            }
//            self.downloader = BitmovinHLSDownloader(withUrl: l ?? "", licenseUrl: self.link["key"], certificateUrl: self.link["certificate"])
//            self.setViewState(downloader.state, downloader.state == .downloaded ? 1.0 : 0.0)
//            downloader.didFinishDownloading = { [weak self] sourceItem in
//                guard let weakSelf = self else {
//                    return
//                }
//                weakSelf.progressDownload.progress = 1.0
//                weakSelf.lblProgress.text = "100%"
//                self?.playSourceItem()
//            }
//            downloader.downloadProgressChanged = { [weak self] progress in
//                self?.progressDownload.progress = Float(progress) / 100
//                self?.lblProgress.text = "\(Int(progress))%"
//            }
//            downloader.downloadStateChanged = { [weak self] (state, progress) in
//                self?.setViewState(state, progress)
//            }
//            self.playSourceItem()
        }
    }
    var linkType: Int = 0 {
        didSet {
            self.link = self.links[self.linkType][self.isDRM]
        }
    }
    var isDRM: Int = 0 {
        didSet {
            self.link = self.links[self.linkType][self.isDRM]
        }
    }
    let links: [[[String: String]]] = [
        [["link": "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"],
         [
            "link": "https://mdrm1.fbox.fpt.vn/vod/DATA/Big_Buck_Bunny_2/_/HLS_EZDRM/Big_Buck_Bunny_2.m3u8",
//            "link": "https://mdrm1.fbox.fpt.vn/vod/DATA/Stolen_2012/_/HLS_EZDRM/Stolen_2012.m3u8",
//            "link": "https://mdrm1.fbox.fpt.vn/live/DATA/K_PM/HLS_EZDRM/K_PM.m3u8",
          "key": "https://fps.ezdrm.com/api/licenses/3b4d4117-9514-4155-b55e-343616d8fac5?user=43bce6e7-1465-419a-a2dd-8a028228b3a2",
          "certificate": "https://drmvn.ga/static/FPS/fairplay.cer"]],
        [["link": "https://bitmovin-a.akamaihd.net/content/playhouse-vr/mpds/105560.mpd"],
         [
//            "link": "https://mdrm1.fbox.fpt.vn/vod/DATA/Stolen_2012/_/DASH_EZDRM/Stolen_2012.mpd",
            "link": "https://mdrm1.fbox.fpt.vn/vod/DATA/Big_Buck_Bunny_2/_/DASH_EZDRM/Big_Buck_Bunny_2.mpd",
          "key": "https://widevine-dash.ezdrm.com/widevine-php/widevine-foreignkey.php?pX=3C7705&user=43bce6e7-1465-419a-a2dd-8a028228b3a2"]]
    ]
    
    @IBAction func segmentDRM_Changed(_ sender: UISegmentedControl) {
        self.isDRM = sender.selectedSegmentIndex
    }
    
    @IBAction func segmentLink_Changed(_ sender: UISegmentedControl) {
        self.linkType = sender.selectedSegmentIndex
    }
    
    @IBAction func btnDownload_Click(_ sender: UIButton) {
        switch downloader.state {
        case .suspended:
            downloader.resume()
        case .notDownloaded, .canceling:
            downloader.download()
        case .downloading:
            downloader.pause()
        case .downloaded:
            self.playSourceItem()
        default:
            ()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.link = self.links[0][0]
    }
    
    func playSourceItem() {
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PlaybackViewController.self)") as! PlaybackViewController
//        vc.sourceItem = downloader.sourceItem
//        self.navigationController?.show(vc, sender: nil)
        let config = PlayerConfiguration()
//        config.sourceItem = self.downloader.sourceItem
        config.sourceItem = self.sourceItem

        let player = BitmovinPlayer(configuration: config)
        let playerView = BMPBitmovinPlayerView(player: player, frame: CGRect.zero)

        player.add(listener: self)
//        playerView.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = self.playerContainerView.bounds

        self.playerView?.removeFromSuperview()

        self.playerContainerView.addSubview(playerView)
        self.playerContainerView.bringSubviewToFront(playerView)

        self.player?.remove(listener: self)
        self.player?.destroy()
        self.player = nil
        self.playerView = playerView
        self.player = player
    }
    
    func setViewState(_ state: DownloadState, _ progress: Double) {
        self.progressDownload.progress = Float(progress) / 100.0
        switch state {
        case .notDownloaded, .canceling:
            self.btnDownload.isHidden = false
            self.btnDownload.isEnabled = true
            self.btnDownload.setTitle("Download", for: .normal)
        case .downloaded:
            self.btnDownload.isHidden = true
//            self.btnDownload.isEnabled = true
//            self.btnDownload.setTitle("View offline", for: .normal)
        case .suspended:
            self.btnDownload.isHidden = false
            self.btnDownload.isEnabled = true
            self.btnDownload.setTitle("Resume", for: .normal)
        case .downloading:
            self.btnDownload.isHidden = false
            self.btnDownload.isEnabled = true
            self.btnDownload.setTitle("Pause", for: .normal)
        default:
            ()
        }
    }

}

extension BitmovinViewController: PlayerListener {
    func onError(_ event: ErrorEvent) {
        print(event.message)
    }
}
