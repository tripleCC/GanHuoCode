//
//  TPCArchivable.swift
//  GanHuo
//
//  Created by tripleCC on 16/1/23.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import Foundation

public protocol TPCArchivable {
    func archive() -> NSDictionary
    init?(unarchive: NSDictionary?)
}


public func unarchiveObjectWithFile<T: TPCArchivable>(path: String) -> T? {
    return T(unarchive: NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? NSDictionary)
}

public func archiveObject<T: TPCArchivable>(object: T, toFile path: String) {
    NSKeyedArchiver.archiveRootObject(object.archive(), toFile: path)
}

public func archiveObjectLists<T: TPCArchivable>(lists: [T], toFile path: String) {
    let encodedLists = lists.map{ $0.archive() }
    NSKeyedArchiver.archiveRootObject(encodedLists, toFile: path)
}

public func unarchiveObjectListsWithFile<T: TPCArchivable>(path: String) -> [T]? {
    guard let decodedLists = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [NSDictionary] else { return nil }
    return decodedLists.flatMap{ T(unarchive: $0) }
}
