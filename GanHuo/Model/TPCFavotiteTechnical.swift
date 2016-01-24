//
//  TPCFavotite.swift
//  GanHuo
//
//  Created by tripleCC on 16/1/24.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import Foundation

public struct TPCFavotiteTechnical {
    var technical: TPCTechnicalObject!
    var time: NSDate!
}

extension TPCFavotiteTechnical: TPCArchivable{
    public func archive() -> NSDictionary {
        let dictionary = NSMutableDictionary(dictionary: technical.archive())
        dictionary["time"] = time
        return dictionary;
    }
    
    public init?(unarchive: NSDictionary?) {
        guard let values = unarchive else { return nil }
        if let technical = TPCTechnicalObject(unarchive: values),
          let time = values["time"] as? NSDate {
            self.technical = technical
            self.time = time
        } else {
            return nil
        }
    }
}

extension TPCStorageUtil {
    var directoryForFavoriteTechnical: String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! + "/TPCFavoriteCache/"
    }
    
    func pathForTechnicalDictionaryByTechnicalType(technicalType: String) -> String {
        let directPath = directoryForFavoriteTechnical
        if !TPCStorageUtil.shareInstance.fileManager.fileExistsAtPath(directPath) {
            do {
                try TPCStorageUtil.shareInstance.fileManager.createDirectoryAtPath(directPath, withIntermediateDirectories: true, attributes: nil)
            } catch { }
        }
        return directPath + technicalType + ".plist"
    }
    
    func clearFavoriteCache() {
        removeFileAtPath(directoryForFavoriteTechnical)
    }
}