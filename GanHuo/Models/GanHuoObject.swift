//
//  GanHuoObject.swift
//  
//
//  Created by tripleCC on 16/3/4.
//
//

import Foundation
import CoreData
import SwiftyJSON

//@objc(GanHuoObject) 
/* http://stackoverflow.com/questions/25076276/unable-to-find-specific-subclass-of-nsmanagedobject */
public final class GanHuoObject: NSManagedObject ,TPCCoreDataHelper {
    public typealias RawType = [String : JSON]
    static var queryTimeString: String!
    init(context: NSManagedObjectContext, dict: RawType) {
        let entity = NSEntityDescription.entityForName(GanHuoObject.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        initializeWithRawType(dict)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(dict: RawType) {
        self.init(context: TPCCoreDataManager.shareInstance.managedObjectContext, dict: dict)
    }
    
    func initializeWithRawType(dict: RawType) {
        who = dict["who"]?.stringValue ?? ""
        publishedAt = dict["publishedAt"]?.stringValue ?? ""
        objectId = dict["_id"]?.stringValue ?? ""
        used = dict["used"]?.numberValue ?? NSNumber()
        type = dict["type"]?.stringValue ?? ""
        createdAt = dict["createdAt"]?.stringValue ?? ""
        desc = dict["desc"]?.stringValue ?? ""
        url = dict["url"]?.stringValue ?? ""
    }
}

extension TPCCoreDataHelper where Self : GanHuoObject {
    static var request: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.fetchLimit = 1000
        fetchRequest.fetchBatchSize = 20;
        let predicate = NSPredicate(format: queryTimeString)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    static func fetchByTime(time: (year: Int, month: Int, day: Int)) -> [Self] {
        queryTimeString = String(format: "publishedAt CONTAINS '%04ld-%02ld-%02ld'", time.year, time.month, time.day)
        return fetch()
    }
    static func fetchById(id: String) -> [Self] {
        queryTimeString = "objectId == '\(id)'"
        return fetch()
    }
}

infix operator !? { }
func !?<T: StringLiteralConvertible> (wrapped: T?, @autoclosure failureText: ()->String) -> T {
        assert(wrapped != nil, failureText)
        return wrapped ?? ""
}
