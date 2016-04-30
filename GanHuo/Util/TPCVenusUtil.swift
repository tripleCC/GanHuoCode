//
//  TPCVenusUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/12/13.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import Kingfisher

let TPCVenusKey = "TPCVenus"
let venusURL = ""
class TPCVenusUtil {
    static var venusFlag = false
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
        debugPrint("Get venus configuration")
        loadVenusFlagFromServer() { (launchConfig) ->() in
            if let venusFlag = launchConfig.venus {
                self.venusFlag = venusFlag
                saveVenusFlag(venusFlag)
                if !venusFlag {
                    debugPrint("Close venus model")
                    TPCConfiguration.allRules.removeAtIndex(TPCConfiguration.allRules.indexOf(TPCRuleType.One)!)
                    TPCConfiguration.allCategories = TPCConfiguration.allCategories.filter{ !TPCFilterCategories.contains($0) }
                    TPCConfiguration.loadDataCountOnce = 5
                    TPCStorageUtil.setObject(nil, forKey: TPCCategoryStoreKey)
                    TPCStorageUtil.setObject(nil, forKey: TPCAllCategoriesKey, suiteName: TPCAppGroupKey)
                } else {
                    debugPrint("Open venus model")
                    // Clear github image url cache when get true venusFlag at first time
                    TPCStorageUtil.shareInstance.clearFileCache()
                    KingfisherManager.sharedManager.cache.clearDiskCache()
                    KingfisherManager.sharedManager.cache.clearMemoryCache()
                    // 给SE用，这里代码不是很好
                    TPCStorageUtil.setObject(TPCConfiguration.allCategories, forKey: TPCAllCategoriesKey, suiteName: TPCAppGroupKey)
                    TPCStorageUtil.setObject(TPCConfiguration.allCategories, forKey: TPCCategoryStoreKey)
                }
            }
            completion(launchConfig: launchConfig)
        }
    }
}