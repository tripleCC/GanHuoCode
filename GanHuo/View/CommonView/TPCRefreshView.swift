//
//  TPCRefreshView.swift
//  Animation
//
//  Created by tripleCC on 15/11/22.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCRefreshView: UIView, TPCActivityIndicator {
    
    var circleLayers = [CALayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addLayersWithSize(frame.size, tintColor: UIColor.lightGrayColor())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addLayersWithSize(frame.size, tintColor: UIColor.lightGrayColor())
    }
}

extension TPCActivityIndicator where Self : TPCRefreshView {
    func addLayersWithSize(size: CGSize, tintColor: UIColor) {
        let oX = (size.width - size.width) / 2.0;
        let oY = (size.height - size.height) / 2.0;
        
        for _ in 0..<2 {
            let circle = CALayer()
            circle.frame = CGRectMake(oX, oY, size.width, size.height)
            circle.anchorPoint = CGPointMake(0.5, 0.5)
            circle.opacity = 0.5
            circle.cornerRadius = size.height / 2.0
            circle.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            circle.backgroundColor = tintColor.CGColor
            circleLayers.append(circle)
            layer.addSublayer(circle)
        }
    }
    
    func addAnimation() {
        let beginTime = CACurrentMediaTime()
        for circle in circleLayers {
            let transformAnimation = CAKeyframeAnimation(keyPath:"transform")
            transformAnimation.removedOnCompletion = false
            transformAnimation.repeatCount = MAXFLOAT
            transformAnimation.duration = 2.0
            transformAnimation.beginTime = beginTime - (1.0 * Double(circleLayers.indexOf(circle)!))
            transformAnimation.keyTimes = [0.0, 0.5, 1.0]
            transformAnimation.timingFunctions = [CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut),
                CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut),
                CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)]
            transformAnimation.values = [NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0)),
                NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)),
                NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0))
            ]
            circle.addAnimation(transformAnimation,forKey:"animation")
        }
    }
    
    func removeAnimation() {
        for circle in circleLayers {
            circle.removeAnimationForKey("animation")
        }
    }
    
    func prepareForAnimationWithScale(var scale: CGFloat) {
        scale = max(min(scale, 1), 0)
        transform = CGAffineTransformMakeScale(scale, scale)
        if scale <= 0.2 {
            removeAnimation()
        }
    }
    
    func endForAnimation() {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
}
