//
//  TPCMarkReadView.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/7.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

@IBDesignable
class TPCMarkReadView: UIView {
    var readed: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if readed {
            UIColor.lightGrayColor().colorWithAlphaComponent(0.2).set()
        } else {
            UIColor.blueColor().colorWithAlphaComponent(0.2).set()
        }
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, rect.size.width, 0)
        CGContextAddLineToPoint(context, 0, rect.size.height)
        CGContextClosePath(context)
        CGContextFillPath(context)
    }

}
