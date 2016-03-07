//
//  GanHuoObject+CoreDataProperties.swift
//  
//
//  Created by tripleCC on 16/3/7.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GanHuoObject {

    @NSManaged var createdAt: String?
    @NSManaged var desc: String?
    @NSManaged var objectId: String?
    @NSManaged var publishedAt: String?
    @NSManaged var type: String?
    @NSManaged var url: String?
    @NSManaged var used: NSNumber?
    @NSManaged var who: String?
    @NSManaged var read: NSNumber?

}
