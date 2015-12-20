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
    static let TPCWKCCNBaseURLString = "https://raw.githubusercontent.com/tripleCC/GanHuo/master/configuration/"
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
    static let shareInstance = TPCNetworkUtil()
    var requests = [Request]()
    func loadTechnicalByYear(year: Int, month: Int, day: Int, completion:((TPCTechnicalDictionary, [String]) -> ())?) {
        TPCNetworkUtil.shareInstance
        Alamofire.request(.GET, TPCTechnicalType.Day(year, month, day).path())
                 .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                    // 移除已经下载好的请求
//                    dispatchGlobal() { self.removeRequest(request) }
                    dispatchGlobal({ () -> () in
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
                            dispatchMain() { completion?(technicalDict, categoryArray) }
                        }
                        
                    })
        })
    }
    
    func cancelAllRequests() {
        for request in requests {
            debugPrint(request.request?.URL?.absoluteString)
            request.cancel()
        }
        requests.removeAll()
    }
    
    func removeRequest(request: NSURLRequest?) {
        if let request = request {
            for i in 0..<requests.count {
                if requests[i].request == request {
                    requests.removeAtIndex(i)
                    break
                }
            }
        }
    }
    
    func loadAbountMe(completion: (aboutMe: TPCAboutMe) -> ()) {
        loadConfigByType(.AboutMe) { JSON in
            completion(aboutMe: TPCAboutMe(dict: JSON))
        }
    }
    
    func loadLaunchConfig(completion: (launchConfig: TPCLaunchConfig) -> ()) {
        loadConfigByType(.LaunchConfig) { JSON in
            completion(launchConfig: TPCLaunchConfig(dict: JSON))
        }
    }
    
    func loadConfigByType(type: TPCConfigType, completion: (response: JSON) -> ()) {
        debugPrint(type.path())
        Alamofire.request(.GET, type.path())
                 .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                    if let data = data {
                        completion(response: JSON(data: data))
                    }
                 })
    }
}