//
//  TPCStorageUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

class TPCStorageUtil {
    let fileManager = NSFileManager.defaultManager()
    static let shareInstance = TPCStorageUtil()
    
    func removeFileAtPath(path: String ,predicateClosure predicate: ((fileName: String) -> Bool)? = nil) {
        let fileEnumerator = fileManager.enumeratorAtPath(path)
        if let fileEnumerator = fileEnumerator {
            for fileName in fileEnumerator {
                if predicate == nil || predicate!(fileName: fileName as! String) {
                    let filePath = path + "/\(fileName)"
                    do {
                        try fileManager.removeItemAtPath(filePath)
                    } catch { }
                }
            }
        }
    }
    
    func clearFileCache(completion: (() -> ())? = nil) {
        func clearFile() {
            removeFileAtPath(TPCStorageUtil.shareInstance.directoryForTechnicalDictionary)
        }
        if completion == nil {
            clearFile()
        } else {
            dispatchGlobal({ () -> () in
                clearFile()
                dispatchSMain({ () -> () in
                    completion!()
                })
            })
        }
    }
    
    func sizeOfFileAtPath(path: String, predicateClosure predicate: ((fileName: String) -> Bool)? = nil) -> UInt64 {
        var fileSize : UInt64 = 0
        let fileEnumerator = fileManager.enumeratorAtPath(path)
        if let fileEnumerator = fileEnumerator {
            for fileName in fileEnumerator {
                if predicate == nil || predicate!(fileName: fileName as! String) {
                    let filePath = path + "/\(fileName)"
                    if let attr = try? NSFileManager.defaultManager().attributesOfItemAtPath(filePath) as NSDictionary {
                        fileSize += attr.fileSize();
                    }
                }
            }
        }
        return fileSize
    }
    
    static func setObject(value: AnyObject?, forKey defaultName: String, suiteName name: String? = nil) {
        if name != nil {
            NSUserDefaults(suiteName: name)?.setObject(value, forKey: defaultName)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: defaultName)
        }
    }
    
    static func objectForKey(defaultName: String, suiteName name: String? = nil) -> AnyObject? {
        guard name != nil else {
            return NSUserDefaults.standardUserDefaults().objectForKey(defaultName)
        }
        return NSUserDefaults(suiteName: name)?.objectForKey(defaultName)
    }
    
    static func setFloat(value: Float, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setFloat(value, forKey: defaultName)
    }
    
    static func floatForKey(defaultName: String) -> Float {
        return  NSUserDefaults.standardUserDefaults().floatForKey(defaultName)
    }
    
    static func setBool(value: Bool, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: defaultName)
    }
    
    static func boolForKey(defaultName: String) -> Bool {
        return  NSUserDefaults.standardUserDefaults().boolForKey(defaultName)
    }
}

