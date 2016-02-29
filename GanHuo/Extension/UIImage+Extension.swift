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
    
    convenience init(color: UIColor, alpha: CGFloat = 0.0) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1 - alpha);
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        self.init(CGImage: UIGraphicsGetImageFromCurrentImageContext().CGImage!)
        UIGraphicsEndImageContext()
    }
}