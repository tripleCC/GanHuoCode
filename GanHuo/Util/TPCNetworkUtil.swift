//
//  TPCNetworkUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


public enum TPCConfigType: String {
    static let TPCWKCCNBaseURLString = "https://raw.githubusercontent.com/tripleCC/WKCC/master/configuration/"
    case AboutMe = "AboutMe"
    case LaunchConfig = "LaunchConfig"
    
    func path() -> String {
        var pathComponent = String()
        switch self {
        case .AboutMe:
            pathComponent = "AboutMe.json"
        case .LaunchConfig:
            pathComponent = "LaunchConfig.json"
        }
        return TPCConfigType.TPCWKCCNBaseURLString + pathComponent
    }
}

public enum TPCTechnicalType {
    static let TPCGankBaseURLString = "http://gank.avosapps.com/api"
    case Data(String, Int, Int)
    case Day(Int, Int, Int)
    case Random(String, Int)
    
    func path() -> String {
        var pathComponent = String()
        switch self {
        case let .Data(type, count, page):
            pathComponent = "/data/\(type)/\(count)/\(page)"
        case let .Day(year, month, day):
            pathComponent = "/day/\(year)/\(month)/\(day)"
        case let .Random(type, count):
            pathComponent = "/data/\(type)/\(count)"
        }
        return TPCTechnicalType.TPCGankBaseURLString + pathComponent
    }
}

typealias TPCTechnicalDictionary = [String : [TPCTechnicalObject]]
class TPCNetworkUtil {
    class func loadTechnicalByYear(year: Int, month: Int, day: Int, completion:((TPCTechnicalDictionary, [String]) -> ())?) {
        Alamofire.request(Method.GET, TPCTechnicalType.Day(year, month, day).path())
                 .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                    dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                        // 这里有时候会出现顺序错位情况，但是如果定死单个子线程，解析速度会变慢
                        // 后面再优化
                        if let data = data {
                            let categories = JSON(data: data)["category"].arrayValue
                            var categoryArray = [String]()
                            var technicalDict = [String : [TPCTechnicalObject]]()
                            if categories.count > 0 {
                                for category in categories {
                                    categoryArray.append(category.stringValue)
                                }
                                
                                let results = JSON(data: data)["results"].dictionaryValue
                                for item in categories {
                                    if let itemArray = results[item.stringValue]?.arrayValue {
                                        var technicalArray = [TPCTechnicalObject]()
                                        for json in itemArray {
                                            if let dict = json.dictionary {
                                                var technical = TPCTechnicalObject(dict: dict)
                                                technical.desc = TPCTextParser.shareTextParser.parseOriginString(technical.desc!)
                                                technicalArray.append(technical)
                                            }
                                        }
                                        technicalDict[item.stringValue] = technicalArray
                                    }
                                }
                            }
                            if categoryArray.count > TPCConfiguration.allCategories.count && TPCVenusUtil.venusFlag {
                                if categoryArray.count > TPCStorageUtil.fetchAllCategories().count {
                                    TPCStorageUtil.saveAllCategories(categoryArray)
                                    TPCConfiguration.allCategories = categoryArray
                                }
                            }
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                completion?(technicalDict, categoryArray)
                            })
                        }
                    })
        })
    }
    
    class func loadAbountMe(completion: (aboutMe: TPCAboutMe) -> ()) {
        loadConfigByType(.AboutMe) { JSON in
            completion(aboutMe: TPCAboutMe(dict: JSON))
        }
    }
    
    class func loadLaunchConfig(completion: (launchConfig: TPCLaunchConfig) -> ()) {
        loadConfigByType(.LaunchConfig) { JSON in
            completion(launchConfig: TPCLaunchConfig(dict: JSON))
        }
    }
    
    class func loadConfigByType(type: TPCConfigType, completion: (response: JSON) -> ()) {
        Alamofire.request(.GET, type.path())
                 .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                    if let data = data {
                        completion(response: JSON(data: data))
                    }
                 })
    }
}