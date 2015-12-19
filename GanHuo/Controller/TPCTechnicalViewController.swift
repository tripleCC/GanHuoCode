//
//  TPCTechnicalViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/17.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import SwiftyJSON


class TPCTechnicalViewController: TPCViewController {
    let reuseIdentifier = "TPCTechnicalCell"
    @IBOutlet weak var tableView: TPCTableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            tableView.rowHeight = TPCConfiguration.technicalCellHeight
            tableView.tableFooterView = noMoreDataFooterView
        }
    }
    private var technocals = [TPCTechnicalDictionary]()
    private var categoriesArray = [[String]]()
    private var (year, month, day) = NSDate.currentTime()
    private var loadDataCount = 0
    private var loadEmptyCount = 0
    lazy private var dayInterval: NSTimeInterval = {
       return TPCVenusUtil.dayInterval
    }()
    
    private var loadingMore = false
    private var loadingNew = false
    
    private var loadNoMoreData = false {
        didSet {
            if loadNoMoreData {
                tableView.reloadData()
            }
            tableView.tableFooterView?.hidden = !loadNoMoreData
        }
    }
    override func reloadTableView() {
        if categoriesArray.count != 0 && technocals.count != 0 && !tableView.refreshing() {
            tableView.reloadData()
            debugPrint("刷新主页图片")
        }
    }
    private var contentOffsetReference: CGFloat {
        get {
            if self.categoriesArray.count == TPCConfiguration.loadDataCountOnce {
                return self.lastScrollViewOffsetY + CGFloat(TPCConfiguration.loadDataCountOnce) * 0.5 * TPCConfiguration.technicalCellHeight
            } else {
                return TPCConfiguration.technicalCellHeight * CGFloat(self.categoriesArray.count - TPCConfiguration.loadDataCountOnce) + self.lastScrollViewOffsetY - TPCScreenHeight - TPCConfiguration.technicalTableViewFooterViewHeight
            }
        }
    }
    private var lastScrollViewOffsetY: CGFloat = TPCConfiguration.technicalOriginScrollViewContentOffsetY
    private var technocalsTemp = [TPCTechnicalDictionary]()
    private var categoriesArrayTemp = [[String]]()
    var canLoadMoreData: Bool {
        get {
            return !self.tableView.refreshing() && !self.loadingMore && !self.loadingNew
        }
    }
    var canLoadNewData: Bool {
        get {
            return self.tableView.refreshing() && !self.loadingNew
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TPCLaunchScreenView.showLaunchAniamtion()
        TPCVenusUtil.setInitialize { (launchConfig) -> () in
            (self.year, self.month, self.day) = TPCVenusUtil.startTime
            self.loadNewData()
            self.setupNav()
            self.registerObserverForApplicationDidEnterBackground()
            self.registerReloadTableView()
        }
//        UIFont.showAllFonts()
//        UIFont.createAllTypeIcon()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        removeObserver()
    }

    private func setupNav() {
        navigationItem.titleView = TPCApplicationTitleView(frame: CGRect(x: 0, y: 0, width: TPCNavigationBarHeight, height: TPCNavigationBarHeight))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "设置", action: { [unowned self] (enable) -> () in
            self.set()
        })
    }
    
    func set() {
        tableView.refreshControl.endRefreshing()
        performSegueWithIdentifier("TechnicalVc2SettingVc", sender: nil)
        TPCUMManager.event(.TechnicalSet)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = navigationController {
            tableView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCConfiguration.technicalTableViewTopBottomMargin + TPCStatusBarHeight, left: 0, bottom: TPCConfiguration.technicalTableViewTopBottomMargin, right: 0)
             tableView.tableFooterView?.bounds.size.height = TPCConfiguration.technicalTableViewFooterViewHeight
        }
    }
    
    private func loadData(allLoadedAppend: Bool = false, completion: (() -> ())? = nil) {
        guard !TPCConfiguration.checkBelowStartTime(year, month: month, day: day) else {
            self.loadNoMoreData = true
            self.loadingNew = false
            self.loadingMore = false
            self.reloadTableView()
            self.resetCounter()
            if self.tableView.refreshing() {
                self.tableView.endRefreshing()
            }
            debugPrint("低于起始时间")
            return
        }
        
        TPCNetworkUtil.loadTechnicalByYear(year, month: month, day: day) { (technicalDict, categories) -> () in
//            debugPrint("TPCVenusUtil.venusFlag=\(TPCVenusUtil.venusFlag)")
            if TPCVenusUtil.venusFlag || !TPCVenusUtil.compareWithYear(self.year, month: self.month, day: self.day) {
                if categories.count > 0 {
                    debugPrint(__FUNCTION__, self.year, self.month, self.day)
                    // 这里考虑后面把数据源河网络独立出来，可以删掉
//                    if (!self.tableView.decelerating) {
//                        self.reloadTableView()
//                    }
                    if !allLoadedAppend {
                        self.technocals.append(technicalDict)
                        self.categoriesArray.append(categories)
                    } else {
                        self.technocalsTemp.append(technicalDict)
                        self.categoriesArrayTemp.append(categories)
                    }
                    guard ++self.loadDataCount != TPCConfiguration.loadDataCountOnce else {
                        self.resetCounter()
                        completion?()
                        return
                    }
                } else {
                    guard ++self.loadEmptyCount < TPCConfiguration.loadDataCountOnce * 2 else {
                        self.resetCounter()
                        completion?()
                        debugPrint("下载为空超过最大次数")
                        return
                    }
                }
            }

            (self.year, self.month, self.day) = NSDate.timeSinceNowByDayInterval(-(++self.dayInterval))
            self.loadData(allLoadedAppend, completion: completion)
        }
    }
    
    private func loadNewData() {
        loadNoMoreData = false
        loadingNew = true
        (year, month, day) = TPCVenusUtil.startTime
        dayInterval = TPCVenusUtil.dayInterval
        resetCounter()
        tableView.beginRefreshViewAnimation()
        debugPrint("开始加载")
        loadData(true) { () -> () in
            self.technocals.removeAll()
            self.categoriesArray.removeAll()
            self.technocals.appendContentsOf(self.technocalsTemp)
            self.categoriesArray.appendContentsOf(self.categoriesArrayTemp)
            self.technocalsTemp.removeAll()
            self.categoriesArrayTemp.removeAll()
            self.tableView.endRefreshing()
            self.loadingNew = false
            // 延迟0.5s，防抖动
            dispatchSeconds(0.5) { self.reloadTableView() }
        }
    }
    
    private func loadMoreData() {
        guard canLoadMoreData else { return }
        loadingMore = true
        (year, month, day) = NSDate.timeSinceNowByDayInterval(-(++self.dayInterval))
        loadData() {
            self.loadingMore = false
            self.reloadTableView()
        }
    }
    
    private func resetCounter() {
        loadEmptyCount = 0
        loadDataCount = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TechnicalVc2DetailVc" {
            if let detailVc = segue.destinationViewController as? TPCDetailViewController {
                if let row = sender?.row {
                    detailVc.technicalDict = technocals[row]
                    detailVc.categories = categoriesArray[row]
                }
            }
        } else if segue.identifier == "TechnicalVc2BrowserVc" {
            if let browserVc = segue.destinationViewController as? TPCBroswerViewController {
                browserVc.URLString = TPCGankIOURLString
            }
        }
    }
}

extension TPCTechnicalViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        debugPrint(technocals.count)
        return technocals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! TPCTechnicalCell
//        debugPrint(__FUNCTION__, indexPath.row, technocals.count)
        if technocals.count > indexPath.row {
            cell.technicalDict = technocals[indexPath.row]
        }
        // 这里会有一个问题，刷新时突然往下拉，会出现图片不对应的情况，然后等加载完成刷新时才正确
        return cell
    }
}

extension TPCTechnicalViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard !self.tableView.refreshing() else { return }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TPCTechnicalCell {
            let (beautyImageView, describeLabel) = cell.createSubviewsMirrorForView(view)
            view.addSubview(beautyImageView)
            view.addSubview(describeLabel)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                let scale = TPCScreenWidth / beautyImageView.frame.width
                beautyImageView.frame = CGRect(x: 0, y: 0, width: TPCScreenWidth, height: beautyImageView.frame.height * scale)
                describeLabel.frame = CGRect(x: beautyImageView.frame.origin.x, y: beautyImageView.frame.maxY - describeLabel.frame.height * scale, width: beautyImageView.frame.width, height: describeLabel.frame.height * scale)
                tableView.alpha = 0
                describeLabel.alpha = 0
                self.navigationController?.navigationBar.alpha = 0
                }) { (finished) -> Void in
                    self.performSegueWithIdentifier("TechnicalVc2DetailVc", sender: indexPath)
                    self.navigationController?.navigationBar.alpha = 1.0
                    describeLabel.removeFromSuperview()
                    beautyImageView.removeFromSuperview()
                    tableView.alpha = 1.0
            }
        }
    }
}

extension TPCTechnicalViewController {
    private func loadDataByContentOffsetY(contentOffsetY: CGFloat) {
//        debugPrint(loading, contentOffsetY, contentOffsetReference)
        if contentOffsetY > contentOffsetReference {
            loadMoreData()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if canLoadNewData {
            loadNewData()
        }
        // 到顶部时不进行刷新
        if scrollView.contentOffset.y > 0 {
            reloadTableView()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        loadDataByContentOffsetY(targetContentOffset.memory.y)
        adjustBarPositionByVelocity(velocity.y, contentOffsetY: targetContentOffset.memory.y)
        
        if tableView.refreshing() {
            targetContentOffset.memory.y = min(CGFloat(TPCConfiguration.loadDataCountOnce) * TPCConfiguration.technicalCellHeight + TPCConfiguration.technicalOriginScrollViewContentOffsetY, targetContentOffset.memory.y)
        }
//        debugPrint(__FUNCTION__, velocity, targetContentOffset.memory.y)
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        adjustBarToOriginPosition()
//        debugPrint(__FUNCTION__)
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        debugPrint(__FUNCTION__, scrollView.contentOffset.y)
        if scrollView.contentOffset.y < TPCConfiguration.technicalOriginScrollViewContentOffsetY {
            let scale = (abs(scrollView.contentOffset.y - TPCConfiguration.technicalOriginScrollViewContentOffsetY)) / TPCRefreshControlOriginHeight
            tableView.adjustRefreshViewWithScale(scale)
        }
    }
    
    //    func scrollViewDidScroll(scrollView: UIScrollView) {
    //        let viewHeight = scrollView.bounds.height + scrollView.contentInset.top
    //        let visibleCells = tableView.visibleCells as! [TPCTechnicalCell]
    //        for cell in visibleCells {
    //            let p = (cell.center.y) - scrollView.contentOffset.y - viewHeight * 0.5
    //            let scale = cos(p / viewHeight * 0.8) * 0.95
    //            UIView.animateWithDuration(0.15, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction, .BeginFromCurrentState], animations: { () -> Void in
    //                    cell.beautyImageView.transform = CGAffineTransformMakeScale(scale, scale)
    //                    cell.describeLabel.transform = CGAffineTransformMakeScale(scale, scale)
    //                }, completion: nil)
    //        }
    //        print(scrollView.contentOffset.y)
    //    }
}
