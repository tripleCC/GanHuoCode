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
    var loadMoreRefreshing = false
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
    
    func fetchGanHuoByIndexPath(indexPath: NSIndexPath, completion:((ganhuo: GanHuoObject) -> ())) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            completion(ganhuo: self.technicals[indexPath.row])
        }
    }
}

typealias TPCCategoryDataSourceLoad = TPCCategoryDataSource
extension TPCCategoryDataSourceLoad {
    func loadNewData() {
        if loadNewRefreshing { return }
        loadNewRefreshing = true
        tableView.loadMoreFooterView.hidden = true
        tableView.beginRefreshViewAnimation()
        page = 1
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) { (technicals, error) -> () in
            print(technicals.count)
            self.technicals.removeAll()
            self.tableView.loadMoreFooterView.hidden = technicals.count == 0
            self.refreshWithTechnicals(technicals, error: error)
        }
    }
    
    func loadMoreData() {
        if loadMoreRefreshing { return }
        loadMoreRefreshing = true
        tableView.loadMoreFooterView.hidden = technicals.count == 0
        tableView.loadMoreFooterView.beginRefresh()
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) { (technicals, error) -> () in
//            print(self.page, technicals.count)
            self.refreshWithTechnicals(technicals, error: error)
            self.tableView.loadMoreFooterView.endRefresh()
            self.loadMoreRefreshing = false
        }
    }
    
    func refreshWithTechnicals(technicals: [GanHuoObject], error: NSError?) {
        if error == nil {
            if technicals.count > 0 {
                self.technicals.appendContentsOf(technicals)
                self.page += 1
                self.tableView.reloadData()
            }
            
            if technicals.count < TPCLoadGanHuoDataOnce {
                self.tableView.loadMoreFooterView.type = .NoData
            } else {
                self.tableView.loadMoreFooterView.type = .LoadMore
            }
        } else {
            // 本地加载
            loadFromCache {
                self.tableView.reloadData()
            }
        }
        if loadNewRefreshing {
            dispatchSeconds(0.5) {
                self.tableView.endRefreshing()
                self.loadNewRefreshing = false
            }
        }
    }
    
    func loadFromCache(completion:(() -> ())) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            let fetchResults = GanHuoObject.fetchByCategory(self.categoryTitle, offset: self.technicals.count)
            debugPrint(fetchResults.count, self.technicals.count)
            if fetchResults.count > 0 {
                self.technicals.appendContentsOf(fetchResults)
                self.page += 1
            } else {
                self.tableView.loadMoreFooterView.type = .NoData
            }
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


