//
//  TPCWelfareViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCWelfareViewController: TPCViewController {
    private let reuseIndentifier = "TPCWelfareCollectionViewCell"
    private let columnCount: CGFloat = 2
    private var itemHeight: CGFloat {
        return (collectionView.bounds.width - (columnCount + 1) * 10) / 2
    }
    @IBOutlet weak var venusMaskView: UIView!
    @IBOutlet weak var collectionView: TPCCollectionView!
    var dataSource: TPCCategoryDataSource!
    var categoryTitle: String = "福利"
    
    var imagesSize = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.hidden = !TPCVenusUtil.venusFlag
        venusMaskView.hidden = !collectionView.hidden
        
        navigationItem.title = categoryTitle
        collectionView.backgroundColor = UIColor.whiteColor()
        let layout = TPCCollectionViewWaterflowLayout()
        layout.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        dataSource = TPCCategoryDataSource(collectionView: collectionView, reuseIdentifier: reuseIndentifier)
        dataSource.delegate = self
        dataSource.categoryTitle = categoryTitle
        collectionView.dataSource = dataSource
        collectionView.registerNib(UINib(nibName: String(TPCWelfareCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIndentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCConfiguration.technicalTableViewTopBottomMargin + TPCStatusBarHeight, left: 0, bottom: TPCConfiguration.technicalTableViewTopBottomMargin + TPCTabBarHeight, right: 0)
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
        if let indexPath = collectionView.indexPathForItemAtPoint(CGPoint(x: 100, y: targetContentOffset.memory.y)) {
            if Double(indexPath.row) >= Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.9 {
                dataSource.loadMoreData()
            }
        }
    }
}