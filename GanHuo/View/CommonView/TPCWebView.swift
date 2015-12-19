//
//  TPCWebView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/21.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import WebKit

class TPCWebView: WKWebView {
    var adjustBarPosition: ((velocity: CGPoint, contentOffsetY: CGFloat) -> ())?
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollView.delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        adjustBarPosition?(velocity: velocity, contentOffsetY: targetContentOffset.memory.y)
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        self.scrollView.delegate?.scrollViewDidScrollToTop?(scrollView)
        adjustBarPosition?(velocity: CGPoint(x: 0, y: -2.0), contentOffsetY: 0)
        return true
    }
}