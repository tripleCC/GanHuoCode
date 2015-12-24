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
        // 如果是true，就不从网络获取，如果是false，就从网络获取
        // 这样就能保证已经为true的用户可以浏览全部，而审核人员从网络获取已经设置为false的标志位
        return TPCStorageUtil.boolForKey(TPCVenusKey)
    }
    
    static func loadVenusFlagFromServer(completion: (launchConfig: TPCLaunchConfig) -> ()) {
        // 从网络上获取
        TPCNetworkUtil.shareInstance.loadLaunchConfig { (launchConfig) -> () in
            completion(launchConfig: launchConfig)
        }
    }
    
    static func setInitialize(completion: (launchConfig: TPCLaunchConfig?) -> ()) {
        venusFlag = fetchVenusFlag()
        guard !venusFlag else { return completion(launchConfig: nil) }
        debugPrint("获取venus配置")
        loadVenusFlagFromServer() { (launchConfig) ->() in
            venusFlag = launchConfig.venus!
            saveVenusFlag(launchConfig.venus!)
            if !launchConfig.venus! {
                debugPrint("Close venus model")
                TPCConfiguration.allRules.removeAtIndex(TPCConfiguration.allRules.indexOf(TPCRuleType.One)!)
                TPCConfiguration.allCategories = TPCConfiguration.allCategories.filter{ !filterCategories.contains($0) }
                TPCConfiguration.loadDataCountOnce = 5
            }
            completion(launchConfig: launchConfig)
        }
    }
}