//
//  CALayer+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/12/14.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
extension CALayer {
    func saveImageWithName(name: String) {
        let data = UIImagePNGRepresentation(UIImage(layer: self))
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] + "/\(name).png"
            debugPrint(path)
            data?.writeToFile(path, atomically: false)
        }
    }
    
    func addRotateAnimationWithDuration(duration: Float, forKey key: String? = nil) {
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.removedOnCompletion = false
        transformAnimation.repeatCount = MAXFLOAT
        transformAnimation.duration = CFTimeInterval(duration)
        transformAnimation.beginTime = CACurrentMediaTime()
        transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeRotation(0, 0, 0, 1.0))
        transformAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2 * 2.0), 0, 0, 1.0))
        addAnimation(transformAnimation, forKey: key)
    }
    
    // 好像没用
    func pausingAnimation() {
        guard let _ = animationKeys() else { return }
        speed = 0.0;
        timeOffset = convertTime(CACurrentMediaTime(), fromLayer: nil)
    }
    
    func resumeAniamtion() {
        guard let _ = animationKeys() else { return }
        speed = 1.0;
        let pausedTime = timeOffset;
        timeOffset = 0.0;
        beginTime = 0.0;
        let timeSincePause = convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        beginTime = timeSincePause;
    }
}