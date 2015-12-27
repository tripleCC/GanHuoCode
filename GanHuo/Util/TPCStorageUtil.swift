//
//  TPCStorageUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

class TPCStorageUtil {
    static func setObject(value: AnyObject?, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: defaultName)
    }
    
    static func objectForKey(defaultName: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(defaultName)
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

let TPCCloudSaveKey = "TPCCloudSave"
extension TPCStorageUtil {
    static func saveCloudConfiguration() {
        setDictionary(TPCConfiguration.dictionaryWithConfiguration(), forKey: TPCCloudSaveKey)
    }
    
    static func fetchCloudConfiguration() {
        if let configuration = dictionaryForKey(TPCCloudSaveKey) {
            TPCConfiguration.setConfigurationWithCloudDictionary(configuration)
        }
    }
    
    static func setCloudSaveObserver(observer: AnyObject, selector aSelector: Selector) {
        let s = NSUbiquitousKeyValueStore.defaultStore()
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: s)
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    static func setDictionary(aDictionary: [String : AnyObject]?, forKey key: String) {
        NSUbiquitousKeyValueStore.defaultStore().setDictionary(aDictionary, forKey: key)
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    static func dictionaryForKey(aKey: String) -> [String : AnyObject]? {
        return NSUbiquitousKeyValueStore.defaultStore().dictionaryForKey(aKey)
    }
}
