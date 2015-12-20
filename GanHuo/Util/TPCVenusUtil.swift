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
    static let (Eyear, Emonth, Eday) = (2015, 12, 8)
    static let (Syear, Smonth, Sday) = (2015, 6, 5)
    static let filterTime = ["2015-12-02", "2015-11-30", "2015-11-23", "2015-11-20", "2015-11-19", "2015-11-18", "2015-11-16", "2015-11-13", "2015-11-12", "2015-11-11", "2015-11-09", "2015-11-04", "2015-10-29", "2015-10-23", "2015-10-22", "2015-10-16", "2015-10-09", "2015-09-30", "2015-09-18", "2015-09-15", "2015-09-14", "2015-09-11", "2015-09-10", "2015-09-09", "2015-09-06", "2015-09-01", "2015-08-31", "2015-08-27", "2015-08-21", "2015-08-14", "2015-08-12", "2015-08-07", "2015-07-30", "2015-07-29", "2015-07-28", "2015-07-27", "2015-07-24", "2015-07-20", "2015-07-17", "2015-07-16", "2015-07-15", "2015-07-10", "2015-07-09", "2015-07-08", "2015-07-01", "2015-06-30", "2015-06-19", "2015-06-18", "2015-06-16", "2015-06-12", "2015-06-11", "2015-06-10", "2015-06-05"]
    static var venusFlag = false
    static var startTime:(Int, Int, Int) = {
        if TPCVenusUtil.venusFlag {
            return NSDate.currentTime()
        } else {
            return (Eyear, Emonth, Eday)
        }
    }()
    static var dayInterval: NSTimeInterval = {
        if TPCVenusUtil.venusFlag {
            return 0
        } else {
            return NSDate.dayIntervalFromYear(Eyear, month: Emonth, day: Eday)
        }
    }()
    static func saveVenusFlag(flag: Bool) {
        TPCStorageUtil.setBool(flag, forKey: TPCVenusKey)
    }
    
    static func fetchVenusFlag() -> Bool {
        // 如果是true，就不从网络获取，如果是false，就从网络获取
        // 这样就能保证已经为true的用户可以浏览全部，而审核人员从网络获取已经设置为false的标志位
        return TPCStorageUtil.boolForKey(TPCVenusKey)
    }
    
    static func loadVenusFlagFromServer(completion: (launchConfig: TPCLaunchConfig) -> ()) {
//        NSDate.dayIntervalFromYear(2016, month: 1, day: 10) >= 0
        // 从网络上获取
        TPCNetworkUtil.loadLaunchConfig { (launchConfig) -> () in
            completion(launchConfig: launchConfig)
        }
    }
    
    static func setInitialize(completion: (launchConfig: TPCLaunchConfig?) -> ()) {
        guard !fetchVenusFlag() else {
            completion(launchConfig: nil)
            return
        }
        debugPrint("获取venus配置")
        loadVenusFlagFromServer() { (launchConfig) ->() in
            venusFlag = launchConfig.venus!
            saveVenusFlag(launchConfig.venus!)
            if !launchConfig.venus! {
                debugPrint("Close venus model")
                TPCConfiguration.allRules.removeAtIndex(TPCConfiguration.allRules.indexOf(TPCRuleType.One)!)
                TPCConfiguration.allCategories.removeAtIndex(TPCConfiguration.allCategories.indexOf("Android")!)
                (TPCConfiguration.SYear, TPCConfiguration.SMonth, TPCConfiguration.SDay) = (Syear, Smonth, Sday)
                TPCConfiguration.imageAlpha = 0.5
            }
            completion(launchConfig: launchConfig)
        }
    }
    
    static func compareWithYear(year: Int, month: Int, day: Int) -> Bool {
        let time = String(format: "%04d-%02d-%02d", arguments: [year, month, day])
        return filterTime.contains(time)
    }
}