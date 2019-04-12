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
    
    lazy var downloader: HLSDownloader = {
//        let downloader = HLSDownloader(withUrl: "http://42.116.82.124/vod/DATA/Kung_Fu_League_China_2018/HLS/Kung_Fu_League_China_2018.m3u8")
        let downloader = HLSDownloader(withUrl: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
        downloader.downloadProgressChanged = { [weak self] progress in
            self?.lblProgress.text = "\(progress * 100)%"
            self?.progressBar.progress = Float(progress)
        }
        downloader.didFinishDownloading = { url in
            print(url)
        }
        return downloader
    }()
    
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBAction func btnStart_Click() {
        self.downloader.download()
    }
    
    @IBAction func btnCancel_Click() {
        self.downloader.cancel()
    }
    
    @IBAction func btnResume_Click() {
        self.downloader.resume()
    }
    
    var resumeUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}

