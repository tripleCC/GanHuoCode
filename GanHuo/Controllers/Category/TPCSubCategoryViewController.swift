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
    var categoryTitle: String? {
        didSet {
            categoryTitle = categoryTitle?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
    }
    var page = 1
    lazy var fetchRequestController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: GanHuoObject.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: false)]
        let predicate = NSPredicate(format: "type = '\(self.navigationItem.title!)'")
        request.predicate = predicate
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: TPCCoreDataManager.shareInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
//        tableView.backgroundColor = UIColor.randomColor()
        loadNewData()
        
//        let b = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
//        b.backgroundColor = UIColor.orangeColor()
//        b.setTitle("sadfhak", forState: .Normal)
//        b.addTarget(self, action: "add", forControlEvents: .TouchUpInside)
//        view.addSubview(b)
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
        dataSource.fetchedResultController = fetchRequestController
        tableView.dataSource = dataSource
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = TPCConfiguration.technicalCellHeight
        tableView.tableFooterView = noMoreDataFooterView
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 100
    }
    
    private func loadNewData() {
        if categoryTitle == nil {
            // random
        } else {
            print("start loading")
            TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: 1) {
                self.tableView.endRefreshing()
                self.page++
                print("end loading")
            }
        }
    }
    
    private func loadMoreData() {
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) {
            self.tableView.endRefreshing()
            self.page++
        }
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
        if let sections = fetchRequestController.sections {
            if let allAcount = sections.first?.numberOfObjects {
                if let indexPath = tableView.indexPathForRowAtPoint(CGPoint(x: 1, y: targetContentOffset.memory.y)) {
                    if Double(indexPath.row) > Double(allAcount) - Double(TPCLoadGanHuoDataOnce) * 0.5 {
                        loadMoreData()
                    }
                }
            }
        }
//        adjustBarPositionByVelocity(velocity.y, contentOffsetY: targetContentOffset.memory.y)
        
        if tableView.refreshing() {
            targetContentOffset.memory.y = min(CGFloat(TPCConfiguration.loadDataCountOnce) * TPCConfiguration.technicalCellHeight + TPCConfiguration.technicalOriginScrollViewContentOffsetY, targetContentOffset.memory.y)
        }
        //        debugPrint(__FUNCTION__, velocity, targetContentOffset.memory.y)
    }
}
