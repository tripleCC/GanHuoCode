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
