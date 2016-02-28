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

func dispatchMain(action: () -> ()) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_sync(dispatch_get_main_queue()) { () -> Void in
            action()
        }        
    }
}