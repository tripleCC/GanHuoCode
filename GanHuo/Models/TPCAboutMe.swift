//
//  TPCAboutMe.swift
//  WKCC
//
//  Created by tripleCC on 15/12/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol TPCGanHuo {
    associatedtype RawType
    init (dict: RawType)
}

public struct TPCAboutMe: TPCGanHuo {
    public typealias RawType = JSON
    var detail: String?
    var links: [TPCLink]?
    
    public init (dict: JSON) {
        debugPrint(dict)
        detail = dict["detail"].stringValue
        links = dict["links"].arrayValue.map{ json in TPCLink(dict: json) }
    }
}

public struct TPCLink: TPCGanHuo {
    public typealias RawType = JSON    
    var title: String?
    var url: String?
    
    public init (dict: JSON) {
        title = dict["title"].stringValue
        url = dict["url"].stringValue
    }
}