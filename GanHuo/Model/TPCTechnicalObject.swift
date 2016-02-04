//
//  TPCTechnicalObject.swift
//  
//
//  Created by tripleCC on 16/2/4.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(TPCTechnicalObject)
public final class TPCTechnicalObject: NSManagedObject ,TPCCoreDataHelper {
    public typealias RawType = JSON
    init(context: NSManagedObjectContext, dict: RawType) {
        let entity = NSEntityDescription.entityForName(TPCTechnicalObject.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        initializeWithRawType(dict)
    }
    
    func initializeWithRawType(dict: RawType) {
        updatedAt = dict["updatedAt"].stringValue
        who = dict["who"].stringValue
        publishedAt = dict["publishedAt"].stringValue
        objectId = dict["objectId"].stringValue
        used = dict["used"].numberValue
        type = dict["type"].stringValue
        createdAt = dict["createdAt"].stringValue
        desc = dict["desc"].stringValue
        url = dict["url"].stringValue
    }
}

