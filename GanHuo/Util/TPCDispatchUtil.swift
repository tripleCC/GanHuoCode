//
//  TPCDispatchUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/12/14.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

func dispatchSeconds(second: NSTimeInterval, action: () -> ()) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(second * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        action()
    }
}

func dispatchGlobal(action: () -> ()) {
    dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
        action()
    })
}

func dispatchSMain(action: () -> ()) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_sync(dispatch_get_main_queue()) { () -> Void in
            action()
        }        
    }
}

func dispatchAMain(action: () -> ()) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            action()
        }
    }
}

func doOnceInAppLifeWithKey(key: String, action:(() -> Void)) {
    guard !NSUserDefaults.standardUserDefaults().boolForKey(key) else { return }
    action()
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: key)
}

func doOnceADayWithKey(key: String, action:(() -> Void)) {
    if let todayString = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String {
        if todayString != NSDate().todayString {
            action()
            NSUserDefaults.standardUserDefaults().setObject(NSDate().todayString, forKey: key)
        }
    }
}