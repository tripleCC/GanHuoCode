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
    }
    
    public init (dict: JSON) {
        
    }
}

