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

public protocol TPCGanHuoAPI {
    func path() -> String
}

public enum TPCGanHuoType {
    static let TPCGanHuoBaseURLString = "https://raw.githubusercontent.com/tripleCC/GanHuo/master/"
    
    public enum ImageTypeSubtype: TPCGanHuoAPI {
        static let ImageTypeSubtypeURLString = "images/"
        case VenusImage(Int)
        case SelfImage(Int, Int, Int)
        
        public func path() -> String {
            var pathComponent = String()
            switch self {
            case let .VenusImage(dayInterval):
                pathComponent = "VenusImages/\(dayInterval).png"
            case let .SelfImage(year, month, day):
                pathComponent = "SelfImages/\(year)\(month)\(day).png"
            }
            return TPCGanHuoType.TPCGanHuoBaseURLString + ImageTypeSubtype.ImageTypeSubtypeURLString + pathComponent
        }
    }
    case ImageType(ImageTypeSubtype)
    
    public enum ConfigTypeSubtype: String, TPCGanHuoAPI {
        static let ConfigTypeSubtypeURLString = "configuration/"
        case AboutMe = "AboutMe"
        case LaunchConfig = "LaunchConfig"
        
        public func path() -> String {
            var pathComponent = String()
            switch self {
            case .AboutMe:
                pathComponent = "AboutMe.json"
            case .LaunchConfig:
                pathComponent = "LaunchConfig.json"
            }
            return TPCGanHuoType.TPCGanHuoBaseURLString + ConfigTypeSubtype.ConfigTypeSubtypeURLString + pathComponent
        }
    }
    case ConfigType(ConfigTypeSubtype)
}



public enum TPCTechnicalType: TPCGanHuoAPI {
    static let TPCGankBaseURLString = "http://gank.avosapps.com/api"
    case Data(String, Int, Int)
    case Day(Int, Int, Int)
    case Random(String, Int)
    
    public func path() -> String {
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

public enum TPCFailureType: String {
    case BelowStartTime = "低于起始时间"
    case BeyondMaxFailTime = "下载为空超过最大次数"
}

public typealias TPCTechnicalDictionary = [String : [TPCTechnicalObject]]

public class TPCNetworkUtil {
    static let shareInstance = TPCNetworkUtil()
    private var requests = [Request]()
    private var loadEmptyCount = 0
    private var loadDataCount = 0
    private var (year, month, day) = NSDate.currentTime()
    private var technocalsTemp = [TPCTechnicalDictionary]()
    private var categoriesArrayTemp = [[String]]()
    private var technocals = [TPCTechnicalDictionary]()
    private var categoriesArray = [[String]]()
    lazy private var dayInterval: NSTimeInterval = {
        return TPCVenusUtil.dayInterval
    }()
    
    public func loadData(allLoadedAppend: Bool = false, success: (() -> ())?, failure: ((TPCFailureType) -> ())?) {
        guard !TPCConfiguration.checkBelowStartTime(year, month: month, day: day) else {
            self.resetCounter()
            failure?(.BelowStartTime)
            return
        }
        TPCNetworkUtil.shareInstance.loadTechnicalByYear(year, month: month, day: day) { (technicalDict, categories) -> () in
            if TPCVenusUtil.venusFlag || !TPCVenusUtil.compareWithYear(self.year, month: self.month, day: self.day) {
                if categories.count > 0 {
                    debugPrint(__FUNCTION__, self.year, self.month, self.day)
                    if !allLoadedAppend {
                        self.technocals.append(technicalDict)
                        self.categoriesArray.append(categories)
                    } else {
                        self.technocalsTemp.append(technicalDict)
                        self.categoriesArrayTemp.append(categories)
                    }
                    guard ++self.loadDataCount != TPCConfiguration.loadDataCountOnce else {
                        self.resetCounter()
                        success?()
                        return
                    }
                } else {
                    guard ++self.loadEmptyCount < TPCConfiguration.loadDataCountOnce * 2 else {
                        self.resetCounter()
                        failure?(.BeyondMaxFailTime)
                        return
                    }
                }
            }
            (self.year, self.month, self.day) = NSDate.timeSinceNowByDayInterval(-(++self.dayInterval))
            self.loadData(allLoadedAppend, success: success, failure: failure)
        }
    }

    private func resetCounter() {
        loadEmptyCount = 0
        loadDataCount = 0
    }
    
    public typealias LoadDataParameter = ([TPCTechnicalDictionary], [[String]])
    public func loadNewData(success: (([TPCTechnicalDictionary], [[String]]) -> ())?, failure: ((TPCFailureType) -> ())?) {
        (year, month, day) = TPCVenusUtil.startTime
        dayInterval = TPCVenusUtil.dayInterval
        resetCounter()
        debugPrint("开始加载")
        func loadNewAction() {
            self.technocals.removeAll()
            self.categoriesArray.removeAll()
            self.technocals.appendContentsOf(self.technocalsTemp)
            self.categoriesArray.appendContentsOf(self.categoriesArrayTemp)
            self.technocalsTemp.removeAll()
            self.categoriesArrayTemp.removeAll()
        }
        loadData(true, success: { () -> () in
            loadNewAction()
            success?(self.technocals, self.categoriesArray)
            }) { (type) -> () in
                loadNewAction()
                failure?(type)
        }
    }
    
    public func loadMoreData(success: (([TPCTechnicalDictionary], [[String]]) -> ())?, failure: ((TPCFailureType, [TPCTechnicalDictionary], [[String]]) -> ())?) {
        (year, month, day) = NSDate.timeSinceNowByDayInterval(-(++self.dayInterval))
        loadData(success: { () -> () in
            success?(self.technocals, self.categoriesArray)
            }) { (type) -> () in
                failure?(type, self.technocals, self.categoriesArray)
        }
    }
}

extension TPCNetworkUtil {
    public func loadTechnicalByYear(year: Int, month: Int, day: Int, completion:((TPCTechnicalDictionary, [String]) -> ())?) {
        TPCNetworkUtil.shareInstance
        Alamofire.request(.GET, TPCTechnicalType.Day(year, month, day).path())
            .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                // 移除已经下载好的请求
                //                    dispatchGlobal() { self.removeRequest(request) }
                dispatchGlobal({ () -> () in
                    // 这里有时候会出现顺序错位情况，但是如果定死单个子线程，解析速度会变慢, 后面再优化
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
                                // 这里对item进行判断，安卓过滤
                                guard TPCVenusUtil.venusFlag || item.stringValue != "Android" else { continue }
                                if let itemArray = results[item.stringValue]?.arrayValue {
                                    var technicalArray = [TPCTechnicalObject]()
                                    for json in itemArray {
                                        if let dict = json.dictionary {
                                            var technical = TPCTechnicalObject(dict: dict)
                                            technical.desc = TPCTextParser.shareTextParser.parseOriginString(technical.desc!)
                                            if !TPCVenusUtil.venusFlag {
                                                // 这里到时候GitHub上面接口修改了之后，要获取图片最大张数，然后用最大张数减去时间差
                                                technical.url = TPCGanHuoType.ImageTypeSubtype.VenusImage(Int(self.dayInterval)).path()
                                            }
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
    
    private func removeRequest(request: NSURLRequest?) {
        if let request = request {
            for i in 0..<requests.count {
                if requests[i].request == request {
                    requests.removeAtIndex(i)
                    break
                }
            }
        }
    }
    
    public func cancelAllRequests() {
        for request in requests {
            debugPrint(request.request?.URL?.absoluteString)
            request.cancel()
        }
        requests.removeAll()
    }
    
    public func loadAbountMe(completion: (aboutMe: TPCAboutMe) -> ()) {
        loadGanHuoByPath(TPCGanHuoType.ConfigTypeSubtype.AboutMe) { (response) -> () in
            completion(aboutMe: TPCAboutMe(dict: response))
        }
    }
    
    public func loadLaunchConfig(completion: (launchConfig: TPCLaunchConfig) -> ()) {
        loadGanHuoByPath(TPCGanHuoType.ConfigTypeSubtype.LaunchConfig) { (response) -> () in
            completion(launchConfig: TPCLaunchConfig(dict: response))
        }
    }
    
    public func loadGanHuoByPath<T: TPCGanHuoAPI>(path: T, completion: (response: JSON) -> ()) {
        debugPrint(path)
        Alamofire.request(.GET, path.path())
            .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                if let data = data {
                    completion(response: JSON(data: data))
                }
            })
    }

}
