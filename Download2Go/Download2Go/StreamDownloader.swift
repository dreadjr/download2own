//
//  Downloadable.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/23/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import Foundation

protocol StreamDownloader {
    func download()
    func cancel()
    func resume()
    func pause()
    func delete()
}
