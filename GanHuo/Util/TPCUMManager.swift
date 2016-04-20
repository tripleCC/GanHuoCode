//
//  TPCUMManager.swift
//  WKCC
//
//  Created by tripleCC on 15/12/2.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

let UMAPPKEY = "565c060c67e58e9a00003d3c"

enum TPCUMEvent: String {
    case TechinicalNoMoreData = "techinical_nomoredata"
    case TechnicalSet = "technical_set"
    case AboutMeJianShu = "aboutme_jianshu"
    case LoadDataCountCount = "loaddatacount_count"
    case ShowCategoryCategory = "showcategory_category"
    case ContentRuleRule = "contentrule_rule"
    case ShareCountCount = "sharecount_count"
    case ImageAlphaAlpha = "imagealpha_alpha"
}

class TPCUMManager {
    class func start() {
        #if GanHuoDev
            let v = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String + "_dev"
        #else
            let v = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        #endif
        MobClick.setAppVersion(v)
        MobClick.setLogEnabled(true)
        MobClick.startWithAppkey(UMAPPKEY, reportPolicy: BATCH, channelId: nil)
    }
    
    class func beginLogPageView(name: String) {
        MobClick.beginLogPageView(name)
    }
    
    class func endLogPageView(name: String) {
        MobClick.endLogPageView(name)
    }
    
    class func event(event: TPCUMEvent, attributes: [String : String]? = nil, counter: Int? = nil) {
        if counter == nil && attributes != nil {
            MobClick.event(event.rawValue, attributes: attributes)
        } else if counter == nil && attributes == nil {
            MobClick.event(event.rawValue)
        } else if counter != nil && attributes != nil {
            MobClick.event(event.rawValue, attributes: attributes!, counter: Int32(counter!))
        }
    }
}