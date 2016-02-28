//
//  TPCLoadDataCountController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCLoadDataCountController: TPCViewController {
    private let reuseIdentifier = "TPCSettingSubCell"
    private let loadDataOnceArray = ["3个妹子", "5个妹子", "10个妹子", "15个妹子", "20个妹子"]
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
    
    var selectedRow = "5个妹子"
    var callAction: ((item: String) -> ())?
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
    }
}

extension TPCLoadDataCountController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadDataOnceArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCSettingSubCell
        cell.textLabel?.text = loadDataOnceArray[indexPath.row]
        cell.selectedButton.enable = selectedRow == loadDataOnceArray[indexPath.row]
        return cell
    }
}

extension TPCLoadDataCountController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = loadDataOnceArray[indexPath.row]
        tableView.reloadData()
        debugPrint(__FUNCTION__, selectedRow, indexPath.row)
    }
}
