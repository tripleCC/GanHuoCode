//
//  TPCSubCategoryViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCSubCategoryViewController: UIViewController {
    var tableView: TPCTableView!
    var categoryTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        tableView.backgroundColor = UIColor.randomColor()
    }
    
    override func loadView() {
        view = TPCTableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
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
        tableView = view as! TPCTableView
        tableView.delegate = self
        tableView.dataSource = TPCCategoryDataSource(tableView: tableView, categoryTitle: categoryTitle)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = TPCConfiguration.technicalCellHeight
        tableView.tableFooterView = noMoreDataFooterView
    }
}

extension TPCSubCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
