//
//  BitmovinDownloader.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/23/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import BitmovinPlayer

typealias DownloadState = BMPOfflineState

class BitmovinHLSDownloader: NSObject, StreamDownloader {
    private let offlineManager = OfflineManager.sharedInstance()
    var sourceItem: SourceItem! {
        willSet {
//            offlineManager.remove(listener: self, for: self.sourceItem)
        }
    }
    var didFinishDownloading: ((_ destinationLocation: SourceItem) -> Void)?
    var downloadProgressChanged: ((_ progress: Double) -> Void)?
    var downloadStateChanged:((_ state: DownloadState, _ progress: Double) -> Void)?
    var state: DownloadState {
        return offlineManager.offlineState(for: self.sourceItem)
    }
    
    func download() {
        offlineManager.download(sourceItem: sourceItem)
    }
    
    func cancel() {
        offlineManager.cancelDownload(for: sourceItem)
    }
    
    func pause() {
        offlineManager.suspendDownload(for: sourceItem)
    }
    
    func resume() {
        offlineManager.resumeDownload(for: sourceItem)
    }
    
    func delete() {
        offlineManager.deleteOfflineData(for: sourceItem)
    }
    
    func destroy() {
        offlineManager.remove(listener: self, for: sourceItem)
    }
    
    init(withUrl urlString: String, licenseUrl: String?, certificateUrl: String?) {
        super.init()
        guard let url = URL(string: urlString) else {
            return
        }
        let hlsSource = HLSSource(url: url)
        let sourceItem = SourceItem(hlsSource: hlsSource)
        sourceItem.itemTitle = urlString
        sourceItem.itemDescription = urlString
        if let licenseUrl = licenseUrl, let certificateUrl = certificateUrl, let cerURL = URL(string: certificateUrl) {
            let fpsConfig = FairplayConfiguration(license: URL(string: licenseUrl), certificateURL: cerURL)
            fpsConfig.prepareMessage = { spcData, assetId in
                return spcData
            }
            fpsConfig.prepareContentId = { contentId in
                guard let url = URL(string: contentId),
                    let host = url.host else {
                        return ""
                }
                return host
            }
            fpsConfig.prepareLicense = { license in
                return license
            }
            fpsConfig.licenseRequestHeaders = [
                "content-type": "application/octet-stream",
                "utoken-drm": "fp"
            ]
            sourceItem.add(drmConfiguration: fpsConfig)
        }
        guard let reach = Reachability.forInternetConnection() else {
            return
        }
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
        default:
            self.sourceItem = sourceItem
            offlineManager.add(listener: self, for: self.sourceItem)
        }
    }
    
    deinit {
        offlineManager.remove(listener: self, for: self.sourceItem)
    }
}

extension BitmovinHLSDownloader: OfflineManagerListener {
    func offlineManager(_ offlineManager: OfflineManager, didFailWithError error: Error?) {
        self.downloadStateChanged?(.canceling, 0.0)
    }
    
    func offlineManagerDidFinishDownload(_ offlineManager: OfflineManager) {
        guard offlineManager.isPlayableOffline(sourceItem: sourceItem),
            let offlineSourceItem = offlineManager.createOfflineSourceItem(for: sourceItem, restrictedToAssetCache: true) else {
                return
        }
        self.sourceItem = offlineSourceItem
        self.didFinishDownloading?(offlineSourceItem)
        self.downloadStateChanged?(.downloaded, 1.0)
    }
    
    func offlineManager(_ offlineManager: OfflineManager, didProgressTo progress: Double) {
        self.downloadProgressChanged?(progress)
        self.downloadStateChanged?(.downloading, progress)
    }
    
    func offlineManagerDidSuspendDownload(_ offlineManager: OfflineManager) {
        self.downloadStateChanged?(.suspended, 0.0)
    }
    
    func offlineManager(_ offlineManager: OfflineManager, didResumeDownloadWithProgress progress: Double) {
        self.downloadProgressChanged?(progress)
        self.downloadStateChanged?(.downloading, progress)
    }
    
    func offlineManagerDidCancelDownload(_ offlineManager: OfflineManager) {
        self.downloadStateChanged?(.canceling, 0.0)
    }
    
    func offlineManagerDidRenewOfflineLicense(_ offlineManager: OfflineManager) {
        
    }
}
