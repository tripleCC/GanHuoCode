//
//  TPCCategoryDataSource.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryDataSource: NSObject, UITableViewDataSource {
    init(categoryTitle: String?) {
        super.init()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
