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
    func renderCell(cell: UITableViewCell, withObject object: AnyObject?)
}

class TPCCategoryDataSource: NSObject {
    var technicals = [GanHuoObject]()
    var tableView: TPCTableView!
    weak var delegate: TPCCategoryDataSourceDelegate?
    private var page = 1
    var loadNewRefreshing = false
    var categoryTitle: String? {
        didSet {
            categoryTitle = categoryTitle?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            loadNewData()
        }
    }
    private var reuseIdentifier: String!
    init(tableView: TPCTableView, reuseIdentifier: String) {
        super.init()
        self.reuseIdentifier = reuseIdentifier
        self.tableView = tableView
    }
    
    func markAsReadedByIndexPath(indexPath: NSIndexPath) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            self.technicals[indexPath.row].read = true
            dispatchAMain {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            TPCCoreDataManager.shareInstance.saveContext()
        }
    }
}

typealias TPCCategoryDataSourceLoad = TPCCategoryDataSource
extension TPCCategoryDataSourceLoad {
    func loadNewData() {
        loadNewRefreshing = true
        tableView.loadMoreFooterView.hidden = true
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: 1) { (technicals, error) -> () in
            self.tableView.loadMoreFooterView.hidden = technicals.count == 0
            self.technicals.removeAll()
            self.loadNewRefreshing = false
            self.refreshWithTechnicals(technicals, error: error)
        }
    }
    
    func loadMoreData() {
        tableView.loadMoreFooterView.hidden = technicals.count == 0
        tableView.loadMoreFooterView.beginRefresh()
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) { (technicals, error) -> () in
            self.refreshWithTechnicals(technicals, error: error)
            self.tableView.loadMoreFooterView.endRefresh()
        }
    }
    
    func refreshWithTechnicals(technicals: [GanHuoObject], error: NSError?) {
        if error == nil {
            self.technicals.appendContentsOf(technicals)
        } else {
            // 本地加载
            loadFromCache {
                self.tableView.reloadData()                
            }
        }
        self.page++
        self.tableView.reloadData()
        if loadNewRefreshing {
            self.tableView.endRefreshing()
        }
    }
    
    func loadFromCache(completion:(() -> ())) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            self.technicals.appendContentsOf(GanHuoObject.fetchWithCategory(self.categoryTitle))
            dispatchAMain{ completion() }
        }
    }
}

extension TPCCategoryDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return technicals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        delegate?.renderCell(cell, withObject: technicals[indexPath.row])
        return cell
    }
}


