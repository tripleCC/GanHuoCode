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
    var collectionView: TPCCollectionView!
    var dataSource: TPCCategoryDataSource!
    var categoryTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func loadView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        view = TPCCollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
    }
    
    private func setupSubviews() {
        let reuseIdentifier = "GanHuoCategoryCell"
        collectionView = view as! TPCCollectionView
        collectionView.registerNib(UINib(nibName: String(TPCCategoryViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.registerNib(UINib(nibName: String(TPCLoadMoreReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(TPCLoadMoreReusableView.self))
        collectionView.delegate = self
        dataSource = TPCCategoryDataSource(collectionView: collectionView, reuseIdentifier: reuseIdentifier)
        dataSource.delegate = self
        dataSource.categoryTitle = categoryTitle
        collectionView.dataSource = dataSource
    }
}

extension TPCSubCategoryViewController: TPCCategoryDataSourceDelegate {
    func renderCell(cell: UIView, withObject object: AnyObject?) {
        // 这种后台上下文队列中的实体在主队列中访问是不可取的，需要通过objectID传递,但是暂时没问题，先这么用着吧。。。
        if let o = object as? GanHuoObject {
            let cell = cell as! TPCCategoryViewCell
            cell.ganhuo = o
        }
    }
}

extension TPCSubCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dataSource.fetchGanHuoByIndexPath(indexPath) { (ganhuo) -> () in
            ganhuo.read = true
            let url = ganhuo.url
            dispatchAMain {
                if let url = url {
                    self.pushToBrowserViewControllerWithURLString(url, ganhuo: ganhuo)
                }
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            TPCCoreDataManager.shareInstance.saveContext()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let height = dataSource.technicals[indexPath.row].cellHeight {
            return CGSize(width: view.bounds.width, height: CGFloat(height.floatValue))
        }
        return CGSize(width: view.bounds.width, height: TPCCategoryViewCell.cellHeightWithGanHuo(dataSource.technicals[indexPath.row]))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: TPCConfiguration.technicalFooterViewHeight)
    }
}

extension TPCSubCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let scale = (abs(scrollView.contentOffset.y)) / TPCRefreshControlOriginHeight
            collectionView.adjustRefreshViewWithScale(scale)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if collectionView.refreshing() {
            dataSource.loadNewData()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let indexPath = collectionView.indexPathForItemAtPoint(CGPoint(x: 1, y: targetContentOffset.memory.y)) {
            if Double(indexPath.row) >= Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.7 {
                dataSource.loadMoreData()
            }
        }
    }
}
