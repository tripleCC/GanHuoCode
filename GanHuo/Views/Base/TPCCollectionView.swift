//
//  TPCCollectionView.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCollectionView: UICollectionView, TPCRefreshable {
    var refreshControl: UIRefreshControl!
    var refreshingView: TPCActivityIndicator! {
        return customView.subviews.first as! TPCRefreshView
    }
    var customView: UIView!
    var loadMoreFooterView: TPCNoMoreDataFooterView? {
        didSet {
            loadMoreFooterView?.gotoWebAction = { [unowned self] in
                self.viewController?.pushToBrowserViewControllerWithURLString(TPCGankIOURLString)
                TPCUMManager.event(.TechinicalNoMoreData)
            }
        }
    }
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let last = visibleCells().last {
            let rowsIndex = numberOfItemsInSection(0) - 1
            let index = indexPathForCell(last)?.row
            if index > rowsIndex - 3 {
                debugPrint("刷新")
                // 这里会刷新两次，但是不影响
                reloadData()
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupSubviews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        backgroundColor = UIColor.whiteColor()
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.tintColor = UIColor.clearColor()
        addSubview(refreshControl)
        
        let containerViews = NSBundle.mainBundle().loadNibNamed("TPCRefreshContentsView", owner: nil, options: nil)
        customView = containerViews[0] as! UIView
        customView.backgroundColor = UIColor.clearColor()
        customView.frame = refreshControl.bounds
        refreshControl.addSubview(customView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
