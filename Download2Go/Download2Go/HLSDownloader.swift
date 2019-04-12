//
//  HLSDownloadManager.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/9/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import AVFoundation

class HLSDownloader: NSObject {
    
    private let sessionConfig = URLSessionConfiguration.background(withIdentifier: "HLSDownloadManager")
    private lazy var downloadSession: AVAssetDownloadURLSession = {
        return AVAssetDownloadURLSession(configuration: self.sessionConfig, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }()
    private var downloadTask: AVAssetDownloadTask?
    var didFinishDownloading: ((_ destinationLocation: URL) -> Void)?
    var downloadProgressChanged: ((_ progress: Double) -> Void)?
    var urlString: String = ""
    var source: HLSSource?
    var dbManager: DBManager = DBManager(withUsername: "binhnt", password: "abc")
    
    override init() {
        super.init()
    }
    
    convenience init(withUrl urlString: String) {
        self.init()
        self.urlString = urlString
        if let source = self.dbManager.get(type: HLSSource.self, predicate: NSPredicate(format: "src = %@", urlString)) {
            self.source = source
        } else {
            self.source = HLSSource()
            self.source?.src = urlString
            self.dbManager.save(self.source!)
        }
    }
    
    func download() {
        self.download(self.urlString)
    }
    
    func resume() {
        self.download(self.source?.resumeSrc)
    }
    
    func download(_ url: String?) {
        guard let url = URL(string: self.urlString) else {
            return
        }
        if let task = self.downloadTask, task.state == .running {
            self.downloadTask?.cancel()
        }
        let asset = AVURLAsset(url: url)
        let downloadTask = self.downloadSession.makeAssetDownloadTask(asset: asset, assetTitle: self.urlString, assetArtworkData: nil, options: [:])
        self.downloadTask = downloadTask
        downloadTask?.resume()
    }
    
    func cancel() {
        self.downloadTask?.cancel()
    }
    
    func delete() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension HLSDownloader: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if assetDownloadTask.state == .completed {
            self.dbManager.update(obj: self.source) { (obj) in
                obj.resumeSrc = nil
                obj.offlineSrc = location.absoluteString
            }
            self.didFinishDownloading?(location)
        } else if assetDownloadTask.state == .canceling {
            self.dbManager.update(obj: self.source) { (obj) in
                obj.resumeSrc = location.absoluteString
                obj.offlineSrc = nil
            }
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        self.downloadProgressChanged?(percentComplete)
    }
}
