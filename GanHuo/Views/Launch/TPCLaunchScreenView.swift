//
//  TPCLaunchScreenView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/29.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCLaunchScreenView: UIView {
    class func showLaunchAniamtion() {
        let launch = createLaunchView()
        launch.frame.origin = CGPointZero
        UIApplication.sharedApplication().keyWindow?.addSubview(launch)
        UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
        launch.layer.saveImageWithName("launch")
        launch.startAnimation()
    }
    
    class func createLaunchView() -> TPCLaunchScreenView {
        let launchView = NSBundle.mainBundle().loadNibNamed("TPCLaunchScreenView", owner: nil, options: nil)[0] as! TPCLaunchScreenView
        launchView.bounds = UIScreen.mainScreen().bounds
        return launchView
    }
    
    @IBOutlet weak var centerImageView: UIImageView!
    
    func startAnimation() {
        var count = 0
        bringSubviewToFront(centerImageView)
        for subview in subviews {
            if subview != centerImageView {
                let transition = CGPoint(x: centerImageView.center.x - subview.center.x, y: centerImageView.center.y - subview.center.y)
                let index = Double(subviews.indexOf(subview)!)
                UIView.animateWithDuration(0.4, delay: 0.15 * index, options: .CurveLinear, animations: { () -> Void in
                    subview.transform = CGAffineTransformTranslate(subview.transform, transition.x, transition.y)
                    }, completion: { (finished) -> Void in
                        if ++count == self.subviews.count - 1 {
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.centerImageView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                                }, completion: { (finished) -> Void in
                                    UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                                        self.centerImageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
                                        }, completion: { (finished) -> Void in
                                            UIView.animateWithDuration(0.4, animations: { () -> Void in
                                                self.alpha = 0
                                                }, completion: { (finished) -> Void in
                                                    self.removeFromSuperview()
                                            })
                                    })
                            })
                        }
                })
            }
        }
    }

}
