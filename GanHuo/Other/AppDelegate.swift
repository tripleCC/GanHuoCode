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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        TPCConfiguration.setInitialize()
        TPCUMManager.start()
        TPCVersionUtil.registerLocalNotification()
        return true
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
        CoreDataManager.shareCoreDataManager.saveContext()
    }

}

