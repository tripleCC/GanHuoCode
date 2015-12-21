//
//  TPCTechnicalObject.swift
//  WKCC
//
//  Created by tripleCC on 15/11/17.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TPCTechnicalObject {
    var who: String?
    var publishedAt: String?
    var desc: String?
    var type: String?
    var url: String?
    var used: NSNumber?
    var objectId: String?
    var createdAt: String?
    var updatedAt: String?
    
    init (dict: [String : JSON]) {
        updatedAt = dict["updatedAt"]?.string
        who = dict["who"]?.string
        publishedAt = dict["publishedAt"]?.string
        objectId = dict["objectId"]?.string
        used = dict["used"]?.number
        type = dict["type"]?.string
        createdAt = dict["createdAt"]?.string
        desc = dict["desc"]?.string
        url = dict["url"]?.string
    }
}