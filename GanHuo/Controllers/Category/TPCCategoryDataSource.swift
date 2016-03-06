//
//  TPCCategoryDataSource.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreData

protocol TPCCategoryDataSourceDelegate: class {
    func renderCell(cell: UITableViewCell, withObject object: AnyObject)
}

class TPCCategoryDataSource: NSObject {
//    var technicals = [GanHuoObject]()
    var tableView: UITableView!
    weak var delegate: TPCCategoryDataSourceDelegate?
    var fetchedResultController: NSFetchedResultsController! {
        didSet {
            fetchedResultController.delegate = self
            do {
                try fetchedResultController.performFetch()
            } catch {
                print(error)
            }

        }
    }
    private var page = 1
    var categoryTitle: String?
    private var reuseIdentifier: String!
    init(tableView: UITableView, reuseIdentifier: String, categoryTitle: String?) {
        super.init()
        self.reuseIdentifier = reuseIdentifier
        self.tableView = tableView
        self.categoryTitle = categoryTitle
        loadData()
    }
    
    private func loadData() {
        if categoryTitle == nil {
            // random
        } else {
            TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page)
        }
    }
}

extension TPCCategoryDataSource: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("section:", fetchedResultController.sections)
        return fetchedResultController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultController.sections else { return 0 }
        print("numberOfObjects:" , sections[section].numberOfObjects)
        return sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = fetchedResultController.objectAtIndexPath(indexPath)
        print("fetchedObject:", object)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        delegate?.renderCell(cell, withObject: object)
        return cell
    }

}

extension TPCCategoryDataSource: NSFetchedResultsControllerDelegate {
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
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            case .Delete:
                if let indexPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            case .Move:
                if newIndexPath != nil && indexPath != nil {
                    tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                }
            case .Update:
                if let indexPath = indexPath {
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
        }
        
    }
}

