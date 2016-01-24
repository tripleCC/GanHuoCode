//
//  TPCVenusUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/12/13.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

let TPCVenusKey = "TPCVenus"
let venusURL = ""
class TPCVenusUtil {
    static var venusFlag = false
    static let filterCategories = ["Android", "App"]
    static let filterSetItems: [String] = [TPCSetItemType.FavorableReception.rawValue,
        TPCSetItemType.ContentRules.rawValue,
        TPCSetItemType.LoadDataEachTime.rawValue,
        TPCSetItemType.NewVersion.rawValue,
        TPCSetItemType.PictureAlpha.rawValue]
    static func saveVenusFlag(flag: Bool) {
        TPCStorageUtil.setBool(flag, forKey: TPCVenusKey)
    }
    
    static func fetchVenusFlag() -> Bool {
        // Get it from disk if it is true. Otherwise get it from network
        return TPCStorageUtil.boolForKey(TPCVenusKey)
    }
    
    static func loadVenusFlagFromServer(completion: (launchConfig: TPCLaunchConfig) -> ()) {
        // Get from network
        TPCNetworkUtil.shareInstance.loadLaunchConfig { (launchConfig) -> () in
            completion(launchConfig: launchConfig)
        }
    }
    
    static func setInitialize(completion: (launchConfig: TPCLaunchConfig?) -> ()) {
        venusFlag = fetchVenusFlag()
        guard !venusFlag else { return completion(launchConfig: nil) }
        debugPrint("获取venus配置")
        loadVenusFlagFromServer() { (launchConfig) ->() in
            if let venusFlag = launchConfig.venus {
                saveVenusFlag(venusFlag)
                if !venusFlag {
                    debugPrint("Close venus model")
                    TPCConfiguration.allRules.removeAtIndex(TPCConfiguration.allRules.indexOf(TPCRuleType.One)!)
                    TPCConfiguration.allCategories = TPCConfiguration.allCategories.filter{ !filterCategories.contains($0) }
                    TPCConfiguration.loadDataCountOnce = 5
                } else {
                    // Clear github image url cache when get true venusFlag at first time
                    TPCStorageUtil.shareInstance.clearFileCache()
                }
            }
            completion(launchConfig: launchConfig)
        }
    }
}