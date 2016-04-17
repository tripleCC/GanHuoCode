//
//  TPCCategoryDataSource.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreData

protocol TPCCategoryDataSourceDelegate: class {
    func renderCell(cell: UIView, withObject object: AnyObject?)
}

class TPCCategoryDataSource: NSObject {
    var technicals = [GanHuoObject]()
    weak var delegate: TPCCategoryDataSourceDelegate?
    private var page = 1
    var loadNewRefreshing = false
    var loadMoreRefreshing = false
    var categoryTitle: String? {
        didSet {
            categoryTitle = categoryTitle?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            loadNewData()
        }
    }
    private var reuseIdentifier: String!
    var collectionView: TPCCollectionView!
    init(collectionView: TPCCollectionView, reuseIdentifier: String) {
        super.init()
        self.reuseIdentifier = reuseIdentifier
        self.collectionView = collectionView
    }
    
    func fetchGanHuoByIndexPath(indexPath: NSIndexPath, completion:((ganhuo: GanHuoObject) -> ())) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            completion(ganhuo: self.technicals[indexPath.row])
        }
    }
}

typealias TPCCategoryDataSourceLoad = TPCCategoryDataSource
extension TPCCategoryDataSourceLoad {
    func loadNewData() {
        if loadNewRefreshing { return }
        loadNewRefreshing = true
        collectionView.loadMoreFooterView?.hidden = true
        collectionView.beginRefreshViewAnimation()
        page = 1
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) { (technicals, error) -> () in
//            print(technicals.count)
            self.technicals.removeAll()
            self.refreshWithTechnicals(technicals, error: error)
            self.collectionView.loadMoreFooterView?.hidden = technicals.count == 0
        }
    }
    
    func loadMoreData() {
        if loadMoreRefreshing { return }
        loadMoreRefreshing = true
        collectionView.loadMoreFooterView?.hidden = technicals.count == 0
        collectionView.loadMoreFooterView?.beginRefresh()
        TPCNetworkUtil.shareInstance.loadTechnicalByType(categoryTitle!, page: page) { (technicals, error) -> () in
            self.refreshWithTechnicals(technicals, error: error)
            self.collectionView.loadMoreFooterView?.endRefresh()
            self.loadMoreRefreshing = false
        }
    }
    
    func refreshWithTechnicals(technicals: [GanHuoObject], error: NSError?) {
        if error == nil {
            if technicals.count > 0 {
                self.technicals.appendContentsOf(technicals)
                self.page += 1
                debugPrint("下载完成")
                self.collectionView.reloadData()
                NSNotificationCenter.defaultCenter().postNotificationName(TPCCategoryReloadDataNotification, object: self)
            }
            
            if technicals.count < TPCLoadGanHuoDataOnce {
                self.collectionView.loadMoreFooterView?.type = .NoData
            } else {
                self.collectionView.loadMoreFooterView?.type = .LoadMore
            }
        } else {
            // 本地加载
            loadFromCache {
                self.collectionView.reloadData()
                NSNotificationCenter.defaultCenter().postNotificationName(TPCCategoryReloadDataNotification, object: self)
            }
        }
        if loadNewRefreshing {
            dispatchSeconds(0.5) {
                self.collectionView.endRefreshing()
                self.loadNewRefreshing = false
            }
        }
    }
    
    func loadFromCache(completion:(() -> ())) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            let fetchResults = GanHuoObject.fetchByCategory(self.categoryTitle, offset: self.technicals.count)
            debugPrint(fetchResults.count, self.technicals.count)
            if fetchResults.count > 0 {
                self.technicals.appendContentsOf(fetchResults)
                self.page += 1
            } else {
                self.collectionView.loadMoreFooterView?.type = .NoData
            }
            dispatchAMain{ completion() }
        }
    }
}

extension TPCCategoryDataSource: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugPrint("刷新数据")
        return technicals.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        delegate?.renderCell(cell, withObject: technicals[indexPath.row])
        print(indexPath.item)
        return cell
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reuseableView = TPCLoadMoreReusableView()
        if kind == UICollectionElementKindSectionFooter {
            reuseableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: String(TPCLoadMoreReusableView.self), forIndexPath: indexPath) as! TPCLoadMoreReusableView
            if self.collectionView.loadMoreFooterView == nil {
                self.collectionView.loadMoreFooterView = reuseableView.noMoreDataFooterView
                self.collectionView.loadMoreFooterView?.hidden = technicals.count == 0
            }
        }
        return reuseableView
    }
}


