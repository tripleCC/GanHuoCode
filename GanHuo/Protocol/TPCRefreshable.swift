//
//  TPCRefreshable.swift
//  GanHuo
//
//  Created by tripleCC on 16/1/23.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public protocol TPCRefreshable {
    var refreshControl: UIRefreshControl! {get set}
    var refreshingView: TPCActivityIndicator! {get}
}

extension TPCRefreshable where Self : UIScrollView {
    
    func beginRefreshing() {
        refreshControl.beginRefreshing()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func refreshing() -> Bool {
        return refreshControl.refreshing
    }
    
    func beginRefreshViewAnimation() {
        refreshingView.addAnimation()
    }
    
    func adjustRefreshViewWithScale(scale: CGFloat) {
        refreshingView.prepareForAnimationWithScale(scale)
    }
}