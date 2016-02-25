//
//  TPCTechnicalObject.swift
//  WKCC
//
//  Created by tripleCC on 15/11/17.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol TPCGanHuo {
    typealias RawType
    init (dict: RawType)
}

public struct TPCTechnicalObject: TPCGanHuo {
    public typealias RawType = [String : JSON]
    var who: String!
    var publishedAt: String!
    var desc: String!
    var type: String!
    var url: String!
    var used: NSNumber!
    var objectId: String!
    var createdAt: String!
    var updatedAt: String!
    
    public init (dict: RawType) {
        updatedAt = dict["updatedAt"]?.stringValue ?? ""
        who = dict["who"]?.stringValue ?? ""
        publishedAt = dict["publishedAt"]?.stringValue ?? ""
        objectId = dict["objectId"]?.stringValue ?? ""
        used = dict["used"]?.numberValue ?? NSNumber()
        type = dict["type"]?.stringValue ?? ""
        createdAt = dict["createdAt"]?.stringValue ?? ""
        desc = dict["desc"]?.stringValue ?? ""
        url = dict["url"]?.stringValue ?? ""

    }
    
    public init () {
    }
}

extension TPCTechnicalObject: TPCArchivable{
    public func archive() -> NSDictionary {
        return ["who" : who, "publishedAt" : publishedAt, "desc" : desc, "type" : type,
            "url" : url, "used" : used, "objectId" : objectId, "createdAt" : createdAt, "updatedAt" : updatedAt];
    }
    
    public init?(unarchive: NSDictionary?) {
        guard let values = unarchive else { return nil }
        if let who = values["who"] as? String,
            publishedAt = values["publishedAt"] as? String,
            desc = values["desc"] as? String,
            type = values["type"] as? String,
            url = values["url"] as? String,
            used = values["used"] as? NSNumber,
            createdAt = values["createdAt"] as? String,
            objectId = values["objectId"] as? String,
            updatedAt = values["updatedAt"] as? String
        {
            self.who = who
            self.publishedAt = publishedAt
            self.desc = desc
            self.type = type
            self.url = url
            self.used = used
            self.createdAt = createdAt
            self.objectId = objectId
            self.updatedAt = updatedAt
        } else {
            return nil
        }
    }
}

extension TPCStorageUtil {
    var directoryForTechnicalDictionary: String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! + "/TPCFileCache/"
    }
    
    func pathForTechnicalDictionaryByTime(time: (year: Int, month: Int, day: Int)) -> String {
        let directPath = directoryForTechnicalDictionary
        if !TPCStorageUtil.shareInstance.fileManager.fileExistsAtPath(directPath) {
            do {
                try TPCStorageUtil.shareInstance.fileManager.createDirectoryAtPath(directPath, withIntermediateDirectories: true, attributes: nil)
            } catch { }
        }
        return directPath + "\(time.year)" + String(format: "%02d", time.month) + String(format: "%02d", time.day) + ".plist"
    }
}

public func archiveTechnicalDictionary(dictionary: [String : [TPCTechnicalObject]], toFile path: String) {
    let encodedLists = Array(dictionary).map{ [$0 : $1.map{ $0.archive() }] }
    NSKeyedArchiver.archiveRootObject(encodedLists, toFile: path)
}

public func unarchiveTechnicalDictionaryWithFile(path: String) -> [String : [TPCTechnicalObject]]? {
    guard let decodedLists = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [[String : [NSDictionary]]] else { return nil }
    var dictionary = [String : [TPCTechnicalObject]]()
    decodedLists.forEach{ Array($0).forEach{ dictionary[$0] = $1.map{ TPCTechnicalObject(unarchive: $0) ?? TPCTechnicalObject() }} }
    return dictionary
}
