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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func loadView() {
        view = TPCTableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    }
    
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
        tableView.loadMoreFooterView.gotoWebAction = { [unowned self] in
            self.pushToBrowserViewControllerWithURLString(TPCGankIOURLString)
            TPCUMManager.event(.TechinicalNoMoreData)
        }
    }
    
    private func pushToBrowserViewControllerWithURLString(URLString: String, ganhuo: GanHuoObject? = nil) {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let browserVc = sb.instantiateViewControllerWithIdentifier("BroswerViewController") as! TPCBroswerViewController
        browserVc.URLString = URLString
        browserVc.ganhuo = ganhuo
        self.navigationController?.pushViewController(browserVc, animated: true)
    }
}

extension TPCSubCategoryViewController: TPCCategoryDataSourceDelegate {
    func renderCell(cell: UITableViewCell, withObject object: AnyObject?) {
        // 这种后台上下文队列中的实体在主队列中访问是不可取的，需要通过objectID传递,但是暂时没问题，先这么用着吧。。。
        if let o = object as? GanHuoObject {
            let cell = cell as! TPCCategoryViewCell
            cell.ganhuo = o
        }
        
    }
}

extension TPCSubCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dataSource.fetchGanHuoByIndexPath(indexPath) { (ganhuo) -> () in
            ganhuo.read = true
            let url = ganhuo.url
            dispatchAMain {
                if let url = url {
                    self.pushToBrowserViewControllerWithURLString(url, ganhuo: ganhuo)
                }
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            TPCCoreDataManager.shareInstance.saveContext()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = dataSource.technicals[indexPath.row].cellHeight {
            return CGFloat(height.floatValue)
        }
        return TPCCategoryViewCell.cellHeightWithGanHuo(dataSource.technicals[indexPath.row])
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
        if tableView.refreshing() {
            dataSource.loadNewData()
        }
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
            if Double(indexPath.row) >= Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.7 {
                dataSource.loadMoreData()
            }
        }
//        adjustBarPositionByVelocity(velocity.y, contentOffsetY: targetContentOffset.memory.y)
//        debugPrint(__FUNCTION__, velocity, targetContentOffset.memory.y)
    }
}
