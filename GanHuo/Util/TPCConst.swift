//
//  TPCConst.swift
//  WKCC
//
//  Created by tripleCC on 15/11/21.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

let TPCStatusBarHeight: CGFloat = 20.0
let TPCNavigationBarHeight: CGFloat = 44.0
let TPCTabBarHeight: CGFloat = 49.0 - 1.0
let TPCScreenWidth = UIScreen.mainScreen().bounds.width
let TPCScreenHeight = UIScreen.mainScreen().bounds.height
let TPCRefreshControlOriginHeight: CGFloat = 60.0

let TPCGankIOURLString = "http://gank.io/"

let TPCTechnicalReloadDataNotification = "TPCTechnicalReloadDataNotification"

let TPCCurrentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String


let TPCLoadGanHuoDataOnce: Int = 10