//
//  TPCAboutMe.swift
//  WKCC
//
//  Created by tripleCC on 15/12/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TPCAboutMe: TPCGanHuo {
    public typealias RawType = JSON
    var detail: String?
    var links: [TPCLink]?
    
    public init (dict: JSON) {
        debugPrint(dict)
        detail = dict["detail"].stringValue
        links = TPCLink.links(linksArray: dict["links"].arrayValue)
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
    
    static func links(linksArray array: [JSON]?) -> [TPCLink] {
        var linkTemp = [TPCLink]()
        if let array = array {
            for linkJSON in array {
                let link = TPCLink(dict: linkJSON)
                linkTemp.append(link)
            }
        }
        return linkTemp
    }
}