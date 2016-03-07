//
//  TPCCategoryDataSource.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreData

protocol TPCFetchedResultsDataSourceDelegate: class {
    func renderCell(cell: UITableViewCell, withObject object: AnyObject)
}

class TPCFetchedResultsDataSource: NSObject {
    var tableView: TPCTableView!
    weak var delegate: TPCFetchedResultsDataSourceDelegate?
    var fetchedResultController: NSFetchedResultsController! {
        didSet {
//            fetchedResultController.fetchRequest.fetchLimit = 0
            fetchedResultController.delegate = self
            do {
                try fetchedResultController.performFetch()
            } catch {
                print(error)
            }
//            fetchedResultController.fetchRequest.fetchLimit = TPCLoadGanHuoDataOnce
        }
    }
    private var page = 1
    var categoryTitle: String?
    private var reuseIdentifier: String!
    init(tableView: TPCTableView, reuseIdentifier: String) {
        super.init()
        self.reuseIdentifier = reuseIdentifier
        self.tableView = tableView
    }
}

extension TPCFetchedResultsDataSource: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = fetchedResultController.objectAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        delegate?.renderCell(cell, withObject: object)
        print(object.url)
        return cell
    }

}

extension TPCFetchedResultsDataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            case .Delete:
                if let indexPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            case .Move:
                if newIndexPath != nil && indexPath != nil {
                    tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                }
            case .Update:
                if let indexPath = indexPath {
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
        }
        
    }
}

