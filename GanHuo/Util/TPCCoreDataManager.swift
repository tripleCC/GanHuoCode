//
//  CoreDataManager.swift
//  WKCC
//
//  Created by tripleCC on 15/11/4.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation
import CoreData

protocol TPCCoreDataHelper {
    typealias RawType
    static var entityName: String { get }
    init(context: NSManagedObjectContext, dict: RawType)
    func initializeWithRawType(dict: RawType)
}

extension TPCCoreDataHelper where Self : NSManagedObject {
    static var entityName: String {
        return String(self)
    }
    
    func save() {
        TPCCoreDataManager.shareInstance.saveContext()
    }
}

class TPCCoreDataManager {
    private static let instance = TPCCoreDataManager()
    
    class var shareInstance: TPCCoreDataManager {
        return instance
    }
    
    var storeURL: NSURL {
        return self.coreDataDirectory.URLByAppendingPathComponent("WKCC.sqlite")
    }
    
    // MARK: - Core Data stack
    
    lazy var coreDataDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.triplec.WKCC" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls.first!.URLByAppendingPathComponent("CoreDataCache", isDirectory: true)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WKCC", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}