//
//  TPCSubCategoryViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreData

class TPCSubCategoryViewController: UIViewController {
    var tableView: UITableView!
    var dataSource: TPCCategoryDataSource!
    var categoryTitle: String?
    lazy var fetchRequestController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: GanHuoObject.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: TPCCoreDataManager.shareInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        tableView.backgroundColor = UIColor.randomColor()
        
        let b = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        b.backgroundColor = UIColor.orangeColor()
        b.setTitle("sadfhak", forState: .Normal)
        b.addTarget(self, action: "add", forControlEvents: .TouchUpInside)
        view.addSubview(b)
    }
    
    func add() {
//        for var i = 0; i < 2; i++ {
//            TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
//                GanHuoObject.insertObjectToContext(TPCCoreDataManager.shareInstance.backgroundManagedObjectContext)
//                do {
//                    try TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.save()
//                    
//                } catch{}
//            })
//        }
    }
    
    override func loadView() {
        view = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    }
    
    lazy var noMoreDataFooterView: TPCNoMoreDataFooterView = {
        let footerView = TPCNoMoreDataFooterView.noMoreDataFooterView()
        footerView.hidden = true
        footerView.gotoWebAction = { [unowned self] in
            self.performSegueWithIdentifier("TechnicalVc2BrowserVc", sender: nil)
            TPCUMManager.event(.TechinicalNoMoreData)
        }
        debugPrint(footerView.bounds.height)
        return footerView
    }()

    private func setupSubviews() {
        let reuseIdentifier = "GanHuoCategoryCell"
        tableView = view as! UITableView
        tableView.registerNib(UINib(nibName: String(TPCCategoryViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        dataSource = TPCCategoryDataSource(tableView: tableView, reuseIdentifier: reuseIdentifier, categoryTitle: categoryTitle)
        dataSource.delegate = self
        dataSource.fetchedResultController = fetchRequestController
        tableView.dataSource = dataSource
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = TPCConfiguration.technicalCellHeight
        tableView.tableFooterView = noMoreDataFooterView
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 100
    }
}

extension TPCSubCategoryViewController: TPCCategoryDataSourceDelegate {
    func renderCell(cell: UITableViewCell, withObject object: AnyObject) {
        let o = object as! GanHuoObject
        let cell = cell as! TPCCategoryViewCell
        cell.ganhuo = o
    }
}

extension TPCSubCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
