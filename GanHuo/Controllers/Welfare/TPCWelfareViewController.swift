//
//  TPCWelfareViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCWelfareViewController: TPCViewController, UICollectionViewDelegate {
    private let reuseIndentifier = "TPCWelfareCollectionViewCell"
    private let columnCount: CGFloat = 2
    private var itemHeight: CGFloat {
        return (collectionView.bounds.width - (columnCount + 1) * 10) / 2
    }
    @IBOutlet weak var venusMaskView: UIView!
    @IBOutlet weak var collectionView: TPCCollectionView!
    var dataSource: TPCCategoryDataSource!
    var categoryTitle: String = "福利"
    let delegateHolder = TPCTransition(transition: TPCCollectionToPageZoomTransition(duration: 0.5))
    
    var pageIndexPath: NSIndexPath?
    var shouldLayoutAfterLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venusMaskView.hidden = TPCVenusUtil.venusFlag
        collectionView.hidden = !venusMaskView.hidden
        
        navigationBarType = .Line
        navigationController!.delegate = delegateHolder
        navigationItem.title = categoryTitle
        collectionView.backgroundColor = UIColor.whiteColor()
        let layout = TPCCollectionViewWaterflowLayout()
        layout.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        dataSource = TPCCategoryDataSource(collectionView: collectionView, reuseIdentifier: reuseIndentifier)
        dataSource.delegate = self
        dataSource.categoryTitle = categoryTitle
        collectionView.dataSource = dataSource
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: TPCCategoryReloadDataNotification, object: dataSource)
    }
    
    func reloadData() {
        print("welfare" + #function)
        // 在每次总行数增加时，就会忽略掉这里的一次更新
        // 所以这里还有手动更新一次，很是郁闷
        if let indexPath = pageIndexPath {
            if shouldLayoutAfterLoad {
                shouldLayoutAfterLoad = false
                self.collectionView.performBatchUpdates({self.collectionView.reloadData()}, completion: { finished in
                    if finished {
                        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
                    }})
                self.collectionView.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCConfiguration.technicalTableViewTopBottomMargin + TPCStatusBarHeight, left: 0, bottom: TPCConfiguration.technicalTableViewTopBottomMargin + TPCTabBarHeight, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        let sb = UIStoryboard(name: "Welfare", bundle: nil)
        if let pageVc = sb.instantiateViewControllerWithIdentifier(String(TPCPageViewController.self)) as? TPCPageViewController {
            collectionView.setToIndexPath(indexPath)
            pageVc.dataSource = dataSource
            pageVc.indexPath = indexPath
            pageVc.scrollCallBack = { indexPath in
                print("滚动：\(indexPath.item)")
                // 这里要每次都刷新，即使是看不见的cell，返回时会用到，但是只在转场pop代理方法中调用一次结果又不正确，比较坑爹
                // 在每次总行数增加时，就会忽略掉这里的一次更新，很是郁闷
                self.shouldLayoutAfterLoad = true
                self.pageIndexPath = indexPath
                self.collectionView.performBatchUpdates({self.collectionView.reloadData()}, completion: { finished in
                    if finished {
                        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
                    }})
                self.collectionView.layoutIfNeeded()
            }
            navigationController!.pushViewController(pageVc, animated: true)
        }
    }
}

extension TPCWelfareViewController: NTTransitionProtocol {
    func transitionCollectionView() -> UICollectionView! {
        return collectionView
    }
}

// 返回的json数据中没有图片尺寸，瀑布流不好实现啊。。。
extension TPCWelfareViewController: TPCCollectionViewWaterflowLayoutDelegate {
    func waterflowLayout(waterflowLayout: TPCCollectionViewWaterflowLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        return itemHeight
    }
    
    func commonConfigurationForWaterflowLayout() -> (rowMargin: CGFloat?, columnMargin: CGFloat?, columnCount: Int?, edgeInsets: UIEdgeInsets?) {
        return (nil, nil, nil, nil)
    }
}

extension TPCWelfareViewController: TPCCategoryDataSourceDelegate {
    func renderCell(cell: UIView, withObject object: AnyObject?) {
        if let o = object as? GanHuoObject {
            let cell = cell as! TPCWelfareCollectionViewCell
            cell.imageURLString = o.url
        }
    }
}

extension TPCWelfareViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let scale = (abs(scrollView.contentOffset.y - TPCConfiguration.technicalOriginScrollViewContentOffsetY)) / TPCRefreshControlOriginHeight
            collectionView.adjustRefreshViewWithScale(scale)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if collectionView.refreshing() {
            dataSource.loadNewData()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        shouldLayoutAfterLoad = false
        if let indexPath = collectionView.indexPathForItemAtPoint(CGPoint(x: 100, y: targetContentOffset.memory.y)) {
            if Double(indexPath.row) >= Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.9 {
                dataSource.loadMoreData()
            }
        }
    }
}