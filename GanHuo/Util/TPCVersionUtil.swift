//
//  TPCVersionUtil.swift
//  GanHuo
//
//  Created by tripleCC on 15/12/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

let TPCAppID = "1064034435"
let TPCVersionNotificationHadShowedKey = "TPCVersionNotificationHadShowed"
let TPCNextVersionKey = "TPCNextVersion"
class TPCVersionUtil {
    static var versionInfo: TPCVersionInfo? {
        didSet {
            let curVesion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
            shouldUpdate = versionInfo?.version != curVesion
            let nextVersion = TPCStorageUtil.objectForKey(TPCNextVersionKey) as? String
            debugPrint(curVesion, nextVersion, versionInfo?.version)
            if versionInfo?.version != curVesion {
                shouldUpdate = true
                // 每个版本更新，都通知一次
                if nextVersion != versionInfo?.version {
                    hadShowed = false
                }
                TPCStorageUtil.setObject(versionInfo?.version, forKey: TPCNextVersionKey)
            } else {
                shouldUpdate = false
            }
        }
    }
    static var shouldUpdate: Bool = false
    static var _hadShowed: Bool = TPCStorageUtil.boolForKey(TPCVersionNotificationHadShowedKey)
    static var hadShowed: Bool {
        get {
            return _hadShowed
        }
        set(new) {
            _hadShowed = new
            TPCStorageUtil.setBool(hadShowed, forKey: TPCVersionNotificationHadShowedKey)
        }
    }
    static func showUpdateMessage() {
        guard !hadShowed else { return }
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let setting = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            let n = UILocalNotification()
            n.fireDate = NSDate(timeIntervalSinceNow:3)
            n.timeZone = NSTimeZone.defaultTimeZone()
            n.alertBody = versionInfo?.updateInfo ?? "新版幹貨出炉啦！去AppStore吃了这盘新鲜的干货吧！"
            n.alertAction = "升级"
            n.soundName = ""
            hadShowed = true
            UIApplication.sharedApplication().scheduleLocalNotification(n)
            debugPrint("发送更新本地通知")
        }
    }
    
    static func openUpdateLink() {
        let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(TPCAppID)")
        UIApplication.sharedApplication().openURL(url!)
    }
}