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
    static var queryString = ""
    static var sortString = "publishedAt"
    static var ascending = false
    static var fetchOffset = 0
    static var fetchLimit = TPCLoadGanHuoDataOnce
    static var request: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.fetchOffset = fetchOffset
        if queryString.characters.count > 0 {
            let predicate = NSPredicate(format: queryString)
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortString, ascending: ascending)]
        return fetchRequest
    }
    init(context: NSManagedObjectContext, dict: RawType) {
        let entity = NSEntityDescription.entityForName(GanHuoObject.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        initializeWithRawType(dict)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static func insertObjectInBackgroundContext(dict: RawType) -> GanHuoObject {
        if let id = dict["_id"]?.stringValue {
            let results = fetchById(id)
            if let ganhuo = results.first {
                ganhuo.initializeWithRawType(dict)
                return ganhuo
            }
        }
        return GanHuoObject(dict: dict)
    }
    
//    static func insertObjectToContext(context: NSManagedObjectContext, dict: RawType) {
//        let ganhuo = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as! GanHuoObject
//        ganhuo.initializeWithRawType(dict)
//    }
    
    convenience init(dict: RawType) {
        self.init(context: TPCCoreDataManager.shareInstance.backgroundManagedObjectContext, dict: dict)
    }
    
    func initializeWithRawType(dict: RawType) {
        who = dict["who"]?.stringValue ?? ""
        publishedAt = dict["publishedAt"]?.stringValue ?? ""
        objectId = dict["_id"]?.stringValue ?? ""
        used = dict["used"]?.numberValue ?? NSNumber()
        type = dict["type"]?.stringValue ?? ""
        createdAt = dict["createdAt"]?.stringValue ?? ""
        desc = TPCTextParser.shareTextParser.parseOriginString(dict["desc"]?.stringValue ?? "")
        url = dict["url"]?.stringValue ?? ""
        calculateCellHeight()
    }
    
    private func calculateCellHeight() {
        cellHeight = TPCCategoryViewCell.cellHeightWithGanHuo(self)
    }
}

typealias GanHuoObjectFetch = GanHuoObject
extension GanHuoObjectFetch {
    static func fetchByTime(time: (year: Int, month: Int, day: Int)) -> [GanHuoObject] {
        queryString = String(format: "publishedAt CONTAINS '%04ld-%02ld-%02ld'", time.year, time.month, time.day)
        return fetchInBackgroundContext()
    }
    static func fetchById(id: String) -> [GanHuoObject] {
        queryString = "objectId == '\(id)'"
        return fetchInBackgroundContext()
    }
    static func fetchByCategory(category: String?, offset: Int) -> [GanHuoObject] {
        if let category = category {
            queryString = "type == '\(category)'"
        } else {
            queryString = ""
        }
        fetchOffset = offset
        return fetchInBackgroundContext()
    }
    
    static func fetchFavorite() -> [GanHuoObject] {
        queryString = "favorite == \(NSNumber(bool: true))"
        sortString = "favoriteAt"
        fetchLimit = 1000
        return fetchInBackgroundContext()
    }
}

infix operator !? { }
func !?<T: StringLiteralConvertible> (wrapped: T?, @autoclosure failureText: ()->String) -> T {
    assert(wrapped != nil, failureText)
    return wrapped ?? ""
}
