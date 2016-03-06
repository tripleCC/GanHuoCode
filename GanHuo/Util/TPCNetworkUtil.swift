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
                pathComponent = "venusImages/\(dayInterval).png"
            case let .SelfImage(year, month, day):
                pathComponent = "selfImages/\(year)\(month)\(day).png"
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
    static let TPCGankBaseURLString = "http://gank.io/api"
    case Data(String, Int, Int)
    case Day(Int, Int, Int)
    case Random(String, Int)
    case AvailableDay
    case Add2Gank
    
    public func path() -> String {
        var pathComponent = String()
        switch self {
        case let .Data(type, count, page):
            pathComponent = "/data/\(type)/\(count)/\(page)"
        case let .Day(year, month, day):
            pathComponent = "/day/\(year)/\(month)/\(day)"
        case let .Random(type, count):
            pathComponent = "/data/\(type)/\(count)"
        case .AvailableDay:
            pathComponent = "/day/history"
        case .Add2Gank:
            pathComponent = "/add2gank"
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
    public var belowStartTime = false
    private var alamofire: Alamofire.Manager!
    private var requests = [Request]()
    private var loadEmptyCount = 0
    private var loadDataCount = 0
    private var (year, month, day) = NSDate.currentTime()
    private var technocalsTemp = [TPCTechnicalDictionary]()
    private var categoriesArrayTemp = [[String]]()
    private var technocals = [TPCTechnicalDictionary]()
    private var categoriesArray = [[String]]()
    private var dayInterval: NSTimeInterval = 0
    private var venusInterval = 0
    // 还是不能这样搞，还是得先从网络上获取，等没网的时候再从cache获取，不能只对当天抓取的数据大于0就断定有缓存（可能是分类界面给缓存的，实际上并没有给全）
    private var loadCacheKey: Int = 0
//    var noDataDays = TPCStorageUtil.shareInstance.fetchNoDataDays()
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 3
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        alamofire = Alamofire.Manager(configuration: configuration)
    }
    
    public func loadData(allLoadedAppend: Bool = false, success: (() -> ())?, failure: ((TPCFailureType) -> ())?) {
        guard !TPCConfiguration.checkBelowStartTime(year, month: month, day: day) else {
            self.resetCounter()
            self.belowStartTime = true
            failure?(.BelowStartTime)
            return
        }
        
        TPCNetworkUtil.shareInstance.loadTechnicalByYear(year, month: month, day: day) { (technicalDict, categories) -> () in
            if categories.count > 0 {
                debugPrint("load successfully", self.year, self.month, self.day)
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
                debugPrint("load unsuccessfully", self.year, self.month, self.day)
                guard ++self.loadEmptyCount < TPCConfiguration.loadDataMaxFailCount else {
                    self.resetCounter()
                    failure?(.BeyondMaxFailTime)
                    return
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
        venusInterval = 0
        dayInterval = 0
        (year, month, day) = NSDate.currentTime()
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
        requests.forEach{ $0.cancel() }
        requests.removeAll()
    }
}

typealias TPCNetworkUtilLoadCategory = TPCNetworkUtil
extension TPCNetworkUtilLoadCategory {
    public func loadTechnicalByType(type: String, count: Int = 15, page: Int, completion:(() -> ())) {
        alamofire.request(.GET, TPCTechnicalType.Data(type, count, page).path())
                 .response { (request, response, data, errorType) -> Void in
                    if let data = data {
                        if let results = JSON(data: data).dictionaryValue["results"] {
                            if case let technocalsArray = results.arrayValue where technocalsArray.count > 0 {
                                TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
                                    technocalsArray.forEach {
                                        GanHuoObject.insertObjectToContext(TPCCoreDataManager.shareInstance.backgroundManagedObjectContext, dict: $0.dictionaryValue)
                                    }
                                    TPCCoreDataManager.shareInstance.saveContext()
                                })
                            }
                        }
                    }
                    completion()
        }
    }
}

typealias TPCNetworkUtilLoadHomePage = TPCNetworkUtil
extension TPCNetworkUtilLoadHomePage {
    public func loadTechnicalByYear(year: Int, month: Int, day: Int, completion:((TPCTechnicalDictionary, [String]) -> ())?) {
        // 过滤时间
        if !filterTime((year, month, day), completion: completion) { return }
        
        if !loadFromCacheByTime((year, month, day), completion: completion) {
            loadTechnicalFromNetWorkByYear(year, month: month, day: day, completion: completion)
        }
    }
    
    private func loadFromCacheByTime(time: (year: Int, month: Int, day: Int), completion:((TPCTechnicalDictionary, [String]) -> ())?) -> Bool {
        let path = TPCStorageUtil.shareInstance.pathForTechnicalDictionaryByTime((time.year, time.month, time.day))
        if TPCStorageUtil.shareInstance.fileManager.fileExistsAtPath(path) {
            dispatchGlobal {
                let technicalDict:[String : [TPCTechnicalObject]] =  unarchiveTechnicalDictionaryWithFile(path)!
                let categories = Array(technicalDict).map{ $0.0 }
                dispatchAMain() { completion?(technicalDict, categories) }
            }
        }
        return TPCStorageUtil.shareInstance.fileManager.fileExistsAtPath(path)
    }
    
    private func filterTime(time: (year: Int, month: Int, day: Int), completion:((TPCTechnicalDictionary, [String]) -> ())?) -> Bool {
        if let availableDays = TPCConfiguration.availableDays {
            let timeString = String(format: "%04d-%02d-%02d", time.year, time.month, time.day)
            if !availableDays.contains(timeString) {
                debugPrint(timeString)
                completion?(TPCTechnicalDictionary(), [String]())
                return false
            }
        } else {
            if let date = NSCalendar.currentCalendar().dateWithTime((time.year, time.month, time.day)) {
                guard !date.isWeekend /*|| !noDataDays.contains(date)*/ else {
                    debugPrint(date)
                    completion?(TPCTechnicalDictionary(), [String]())
                    return false
                }
            }
        }
        return true
    }
    
    private func loadTechnicalFromNetWorkByYear(year: Int, month: Int, day: Int, completion:((TPCTechnicalDictionary, [String]) -> ())?) {
        TPCNetworkUtil.shareInstance
        alamofire.request(.GET, TPCTechnicalType.Day(year, month, day).path())
            .response(completionHandler: { (request, response, data, errorType) -> Void in
                // 移除已经下载好的请求
                //                    dispatchGlobal() { self.removeRequest(request) }
                dispatchGlobal({ () -> () in
                    // 这里有时候会出现顺序错位情况，但是如果定死单个子线程，解析速度会变慢, 后面再优化
                    if let data = data {
                        var categories = JSON(data: data)["category"].arrayValue.map{ $0.stringValue }
                        var technicalDict = [String : [TPCTechnicalObject]]()
                        if categories.count > 0 {
                            let results = JSON(data: data)["results"].dictionaryValue
                            for item in categories {
                                // filter Android
                                guard TPCVenusUtil.venusFlag || !TPCVenusUtil.filterCategories.contains(item) else {
                                    categories.removeAtIndex(categories.indexOf(item)!)
                                    continue
                                }
                                if let itemArray = results[item]?.arrayValue {
                                    var technicalArray = [TPCTechnicalObject]()
                                        // 这种先查后改的方式并不是最佳选择，应该用NSFetchedResultsController，存入coredata后，不需要手动缓存数据，直接在NSFetchedResultsController代理方法中获取，并且更新。这样unique约束就有用了，否则如果遇到一样的id，在save的时候，内存中的entity就会被置为fault
                                    for json in itemArray where json.dictionary != nil {
                                        var technical = TPCTechnicalObject(dict: json.dictionaryValue)
                                        technical.desc = TPCTextParser.shareTextParser.parseOriginString(technical.desc!)
                                        if !TPCVenusUtil.venusFlag && technical.type == "福利" {
                                            technical.url = TPCGanHuoType.ImageTypeSubtype.VenusImage(Int(300 - self.venusInterval)).path()
                                        }
                                        technicalArray.append(technical)
                                    }
                                    technicalDict[item] = technicalArray
                                }
                            }
                            self.venusInterval++
                        }
                        if categories.count > TPCConfiguration.allCategories.count && TPCVenusUtil.venusFlag {
                            if categories.count > TPCStorageUtil.fetchAllCategories().count {
                                TPCStorageUtil.saveAllCategories(categories)
                                TPCConfiguration.allCategories = categories
                            }
                        }
                        dispatchGlobal {
                            // Do some cache operation
                            if categories.count > 0 {
                                let path = TPCStorageUtil.shareInstance.pathForTechnicalDictionaryByTime((year, month, day))
                                archiveTechnicalDictionary(technicalDict, toFile: path)
                            } 
                        }
                        dispatchAMain() {
                            print(technicalDict)
                            completion?(technicalDict, categories) }
                    }
                    
                })
            })
    }
    
    public func loadAvailableDays(completion: (days: Array<String>) -> ()) {
        alamofire.request(.GET, TPCTechnicalType.AvailableDay.path())
                 .response { (request, respone, data, error) -> Void in
                    if let data = data {
                        if let jsonDict = JSON(data: data).dictionaryValue["results"] {
                            completion(days: jsonDict.arrayValue.flatMap{ $0.stringValue })
                        }
                    }
        }
    }
    
//    public func add2Gank
}

typealias TPCNetworkUtilLoadAuthor = TPCNetworkUtil
extension TPCNetworkUtilLoadAuthor {
    
    public func loadAbountMe(completion: (aboutMe: TPCAboutMe) -> ()) {
        loadGanHuoByPath(TPCGanHuoType.ConfigTypeSubtype.AboutMe) { (response) -> () in
            completion(aboutMe: TPCAboutMe(dict: response))
        }
    }
    
    public func loadLaunchConfig(completion: (launchConfig: TPCLaunchConfig) -> ()) {
//        alamofire.request(.GET, "http://192.168.1.105/test/LaunchConfig.json")
//            .response(completionHandler: { (request, response, data, ErrorType) -> Void in
//                print(data, response)
//                if let data = data {
//                    completion(launchConfig: TPCLaunchConfig(dict: JSON(data: data)))
//                } else {
//                    debugPrint(ErrorType.debugDescription)
//                }
//            })
        loadGanHuoByPath(TPCGanHuoType.ConfigTypeSubtype.LaunchConfig) { (response) -> () in
            completion(launchConfig: TPCLaunchConfig(dict: response))
        }
    }
    
    public func loadGanHuoByPath<T: TPCGanHuoAPI>(path: T, completion: (response: JSON) -> ()) {
        debugPrint(path.path())
        alamofire.request(.GET, path.path())
            .response(completionHandler: { (request, response, data, ErrorType) -> Void in
                if let data = data {
                    completion(response: JSON(data: data))
                } else {
                    debugPrint(ErrorType.debugDescription)
                }
            })
    }
}

//extension TPCStorageUtil {
//    var pathForNoDataDays: String {
//        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! + "/NoDataDays.plist"
//    }
//    
//    func saveNoDataDays(noDataDays: [NSDate]) {
//        noDataDays.writeToFile(pathForNoDataDays, atomically: true)
//    }
//    
//    func fetchNoDataDays() -> [NSDate] {
//        return NSArray(contentsOfFile: pathForNoDataDays) as? Array<NSDate> ?? Array<NSDate>()
//    }
//    
//    func clearNoDateDaysCache() {
//        removeFileAtPath(pathForNoDataDays)
//    }
//}

//extension Array where Element : AnyObject {
//    func writeToFile(path: String, atomically useAuxiliaryFile: Bool) -> Bool {
//        return NSArray(array: self).writeToFile(TPCStorageUtil.shareInstance.pathForNoDataDays, atomically: true)
//    }
//}
