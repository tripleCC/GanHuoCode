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
    var tableView: TPCTableView!
    var dataSource: TPCCategoryDataSource!
    var categoryTitle: String?
    var page = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
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
        let reuseIdentifier = "GanHuoCategoryCell"
        tableView = view as! TPCTableView
        tableView.registerNib(UINib(nibName: String(TPCCategoryViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        dataSource = TPCCategoryDataSource(tableView: tableView, reuseIdentifier: reuseIdentifier)
        dataSource.delegate = self
        dataSource.categoryTitle = categoryTitle
        tableView.dataSource = dataSource
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tableFooterView = noMoreDataFooterView
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dataSource.markAsReadedByIndexPath(indexPath)
    }
}

extension TPCSubCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let scale = (abs(scrollView.contentOffset.y)) / TPCRefreshControlOriginHeight
            tableView.adjustRefreshViewWithScale(scale)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        tableView.beginRefreshViewAnimation()
//        if canLoadNewData {
//            loadNewData()
//        }
//        // 到顶部时不进行刷新
//        if scrollView.contentOffset.y > 0 {
//            let expectedOffsetY = tableView.contentOffset.y + UIScreen.mainScreen().bounds.height - noMoreDataFooterView.bounds.height - TPCConfiguration.technicalTableViewTopBottomMargin
//            print(expectedOffsetY, scrollView.contentSize.height)
//            if scrollView.contentSize.height >= expectedOffsetY {
//                loadMoreData()
//            }
//            reloadTableView()
//        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let indexPath = tableView.indexPathForRowAtPoint(CGPoint(x: 1, y: targetContentOffset.memory.y)) {
            if Double(indexPath.row) > Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.5 {
                dataSource.loadMoreData()
            }
        }
//        adjustBarPositionByVelocity(velocity.y, contentOffsetY: targetContentOffset.memory.y)
//        debugPrint(__FUNCTION__, velocity, targetContentOffset.memory.y)
    }
}
