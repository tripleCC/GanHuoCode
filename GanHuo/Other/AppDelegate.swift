//
//  AppDelegate.swift
//  WKCC
//
//  Created by tripleCC on 15/11/1.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import CoreData
import MonkeyKing

let TPCURLMemoryCacheSize = 1024 * 1024 * 512
let TPCURLDiskCacheSize = 1024 * 1024 * 1024 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func registerRemoteNotification() {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        TPCJSPatchManager.shareManager.start()
        TPCConfiguration.setInitialize()
        TPCUMManager.start()
        registerRemoteNotification()
        TPCStorageUtil.setCloudSaveObserver(self, selector: #selector(AppDelegate.storeDidChange(_:)))
        NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity:TPCURLMemoryCacheSize , diskCapacity: TPCURLDiskCacheSize, diskPath: "Cache.db"))
        print(NSBundle.mainBundle().pathForResource("all", ofType: "png"))
        return true
    }

    func storeDidChange(notification: NSNotification) {
        debugPrint(#function, notification)
        if let saveKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
            if saveKeys.contains(TPCCloudSaveKey) {
                TPCStorageUtil.fetchCloudConfiguration()
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        debugPrint( TPCVersionUtil.shouldUpdate, TPCVersionUtil.hadShowed, TPCShareManager.shareInstance.shareing)
        // 共享时，不发送更新通知
        if TPCVersionUtil.shouldUpdate && !TPCVersionUtil.hadShowed && !TPCShareManager.shareInstance.shareing {
            TPCVersionUtil.showUpdateMessage()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        TPCJSPatchManager.shareManager.handleJSPatchStatusWithURLString(TPCGanHuoType.ConfigTypeSubtype.HotfixStatus.path(), duration: oneHour)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        debugPrint("打开AppStore")
        TPCVersionUtil.openUpdateLink()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if MonkeyKing.handleOpenURL(url) {
            debugPrint(url)
            return true
        }
        
        return false
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        TPCCoreDataManager.shareInstance.saveContext()
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(#function, deviceToken)
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print(#function)
        application.registerForRemoteNotifications()
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(#function)
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print(#function)
        completionHandler()
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(#function, userInfo)
    }
}

