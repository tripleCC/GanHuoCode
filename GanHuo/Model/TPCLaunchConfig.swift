//
//  TPCLaunchConfig.swift
//  WKCC
//
//  Created by tripleCC on 15/12/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TPCLaunchConfig {
    var venus: Bool?
    var version: String?
    
    init (dict: JSON) {
        debugPrint(dict)
        venus = dict["venus"].boolValue
        version = dict["version"].stringValue
    }
}
