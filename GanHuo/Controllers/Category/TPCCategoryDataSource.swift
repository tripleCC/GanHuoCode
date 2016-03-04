//
//  TPCCategoryDataSource.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryDataSource: NSObject, UITableViewDataSource {
    var technicals = [GanHuoObject]()
    weak var tableView: TPCTableView!
    private var page = 1
    private var categoryTitle: String?
    init(tableView: TPCTableView, categoryTitle: String?) {
        super.init()
        self.categoryTitle = categoryTitle
        self.tableView = tableView
        loadData()
    }
    
    private func loadData() {
        if categoryTitle == nil {
            // random
        } else {
            TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page, completion: { (technicals) -> () in
                self.technicals.appendContentsOf(technicals)
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
