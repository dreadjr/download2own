//
//  DBManager.swift
//  Download2Go
//
//  Created by Nguyen Thanh Bình on 4/11/19.
//  Copyright © 2019 Nguyen Thanh Bình. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class DBManager: NSObject {
    
    let realm: Realm?

    override init() {
        self.realm = try? Realm()
    }
    
    init(withUsername username: String, password: String) {
        let fileUrl = URL(fileURLWithPath:
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0],
                                 isDirectory: true)
            .appendingPathComponent("\(username).realm")
        let encryptionKey = Data(base64Encoded: "\(username)-\(password)")
        let config = Realm.Configuration(fileURL: fileUrl, inMemoryIdentifier: nil, syncConfiguration: nil, encryptionKey: encryptionKey, readOnly: false, schemaVersion: 1, migrationBlock: { (migrationn, oldVersion) in
            
        }, deleteRealmIfMigrationNeeded: true, shouldCompactOnLaunch: { (totalBytes, usedBytes) -> Bool in
            return true
        }, objectTypes: nil)
        self.realm = try? Realm(configuration: config)
    }
    
    func save<T: Object>(_ obj: T) {
        try? self.realm?.write { [weak self] in
            self?.realm?.add(obj)
        }
    }
    
    func save<T: Object>(_ objs: [T]) {
        try? self.realm?.write { [weak self] in
            self?.realm?.add(objs)
        }
    }
    
    func get<T: Object>(type: T.Type, predicate: NSPredicate) -> T? {
        let obj = self.realm?.objects(type).filter(predicate)
        return obj?.first
    }
    
    func get<T: Object>(type: T.Type, predicate: NSPredicate? = nil) -> Results<T>? {
        let obj = self.realm?.objects(type)
        if let predicate = predicate {
            return obj?.filter(predicate)
        }
        return obj
    }
    
    func get<T: Object>(type: T.Type, block: ((T) -> Bool)?) -> T? {
        let pred = NSPredicate (block: { (obj, bindings) -> Bool in
            if let obj = obj as? T {
                return block?(obj) ?? false
            }
            return false
        })
        let obj = self.realm?.objects(type).filter(pred)
        return obj?.first
    }
    
    func update<T: Object>(obj: T?, block: ((T) -> Void)?) {
        guard let obj = obj else {
            return
        }
        try? self.realm?.write {
            block?(obj)
        }
    }
    
}
