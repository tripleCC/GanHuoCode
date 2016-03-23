//
//  TPCShowCategoryController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCShowCategoryController: TPCViewController {
    private let reuseIdentifier = "TPCSettingSubCell"
    private let categories = TPCStorageUtil.fetchAllCategories()
    var selectedRow = "iOS"
    var callAction: ((item: String) -> ())?
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = TPCConfiguration.settingCellHeight
            tableView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCStatusBarHeight, left: 0, bottom: 0, right: 0)
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = 10
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
        }
    }
    var showCategory: String?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarType = .Line
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        callAction?(item: selectedRow)
        postReloadTableView()
    }
}

extension TPCShowCategoryController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCSettingSubCell
        cell.textLabel?.text = categories[indexPath.row]
        cell.selectedButton.enable = selectedRow == categories[indexPath.row]
        
        return cell
    }
}

extension TPCShowCategoryController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = categories[indexPath.row]
        tableView.reloadData()
        debugPrint(#function, selectedRow, indexPath.row)
    }
}