//
//  TPCPageViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/6.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCPageViewController: TPCViewController {

    @IBOutlet weak var collectionView: TPCCollectionView! {
        didSet {
            let flowLayout = UICollectionViewFlowLayout()
            let itemSize  = self.navigationController!.navigationBarHidden ?
                CGSize(width: TPCScreenWidth, height: TPCScreenHeight + 20) : CGSize(width: TPCScreenWidth, height: TPCScreenHeight - TPCNavigationBarHeight - TPCStatusBarHeight)
            flowLayout.itemSize = itemSize
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.scrollDirection = .Horizontal
            collectionView.setCollectionViewLayout(flowLayout, animated: false)
        }
    }
    var scrollCallBack: ((indexPath: NSIndexPath) -> Void)?
    var dataSource: TPCCategoryDataSource!
    var indexPath: NSIndexPath!
    var pullOffset = CGPoint.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "福利"
        navigationBarType = .Line
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.setToIndexPath(indexPath)
        collectionView.performBatchUpdates({self.collectionView.reloadData()}, completion: { finished in
            if finished {
                self.collectionView.scrollToItemAtIndexPath(self.indexPath, atScrollPosition:.CenteredHorizontally, animated: false)
            }})
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: TPCCategoryReloadDataNotification, object: dataSource)
    }
    
    func reloadData() {
        print("pageView" + #function)
        collectionView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.top = TPCNavigationBarHeight + TPCStatusBarHeight
    }
}

extension TPCPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TPCPageViewCell", forIndexPath: indexPath) as! TPCPageViewCell
        cell.imageURLString = dataSource.technicals[indexPath.item].url
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.technicals.count
    }
    
}

extension TPCPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / collectionView.frame.width)
        if index < dataSource.technicals.count {
            if let publishAt = dataSource.technicals[index].publishedAt {
                let subIndex = publishAt.startIndex.advancedBy("XXXX-XX-XX".lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                var title = publishAt.substringToIndex(subIndex)
                if let who = dataSource.technicals[index].who {
                    title += "(via.\(who))"
                }
                navigationItem.title = title
            }
            
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / collectionView.frame.width)
        scrollCallBack?(indexPath: NSIndexPath(forItem: index, inSection: 0))
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let indexPath = collectionView.indexPathForItemAtPoint(CGPoint(x: targetContentOffset.memory.x, y: 100)) {
            if Double(indexPath.row) >= Double(dataSource.technicals.count) - Double(TPCLoadGanHuoDataOnce) * 0.9 {
                dataSource.loadMoreData()
            }
        }
    }
}

extension TPCPageViewController: NTTransitionProtocol, NTHorizontalPageViewControllerProtocol {
    func transitionCollectionView() -> UICollectionView! {
        return collectionView
    }
    
    func pageViewCellScrollViewContentOffset() -> CGPoint {
        return pullOffset
    }
}
