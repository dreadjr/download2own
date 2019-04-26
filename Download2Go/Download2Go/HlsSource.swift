//
//  HLSSource.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/11/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class HlsSource: Object {

    @objc dynamic var src: String = ""
    @objc dynamic var offlineSrc: String?
    @objc dynamic var resumeSrc: String?
    @objc dynamic var title: String = ""
    @objc dynamic var vtt: String = ""
    
}
