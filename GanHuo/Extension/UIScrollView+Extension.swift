//
//  UIScrollView+Extension.swift
//
//  Created by tripleCC on 16/1/29.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

extension UIScrollView {
    /**
     滚动至顶部
     
     - parameter animated: 是否执行动画
     */
    public func scrollToTopAnimated(animated: Bool = true) {
        var offset = contentOffset
        offset.y = -contentInset.top
        setContentOffset(offset, animated: animated)
    }
    
    /**
     滚动至底部
     
     - parameter animated: 是否执行动画
     */
    public func scrollToBottomAnimated(animated: Bool = true) {
        var offset = contentOffset
        offset.y = contentSize.height - bounds.height + contentInset.bottom
        setContentOffset(offset, animated: animated)
    }
    
    /**
     滚动至左边
     
     - parameter animated: 是否执行动画
     */
    public func scrollToLeftAnimated(animated: Bool = true) {
        var offset = contentOffset
        offset.x = -contentInset.left
        setContentOffset(offset, animated: animated)
    }
    
    /**
     滚动至右边
     
     - parameter animated: 是否执行动画
     */
    public func scrollToRightAnimated(animated: Bool = true) {
        var offset = contentOffset
        offset.x = contentSize.width - bounds.width + contentInset.right
        setContentOffset(offset, animated: animated)
    }
}