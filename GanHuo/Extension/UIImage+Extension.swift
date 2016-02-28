//
//  UIImage+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(layer: CALayer) {
        // it support retina, UIGraphicsBeginImageContext not
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0.0);
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        self.init(CGImage: UIGraphicsGetImageFromCurrentImageContext().CGImage!)
        UIGraphicsEndImageContext()
    }
    
    convenience init(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        self.init(CGImage: UIGraphicsGetImageFromCurrentImageContext().CGImage!)
        UIGraphicsEndImageContext()
    }
}