//
//  TPCLaunchConfig.swift
//  WKCC
//
//  Created by tripleCC on 15/12/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TPCLaunchConfig: TPCGanHuo {
    public typealias RawType = JSON
    var venus: Bool?
    var versionInfo: TPCVersionInfo?
    
    public init (dict: JSON) {
        debugPrint(dict)
        venus = dict["venus"].boolValue
        versionInfo = TPCVersionInfo(dict: dict["versionInfo"])
    }
}

public struct TPCVersionInfo: TPCGanHuo {
    public typealias RawType = JSON    
    var version: String?
    var updateInfo: String?
    var newFunction: String?
    public init (dict: JSON) {
        debugPrint(dict)
        version = dict["version"].stringValue
        updateInfo = dict["updateInfo"].stringValue
        newFunction = dict["newFunction"].stringValue
    }
}