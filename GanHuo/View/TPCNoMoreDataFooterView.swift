//
//  TPCNoMoreDataFooterView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/24.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCNoMoreDataFooterView: UIView {
    var gotoWebAction: (() -> ())?
    
    class func noMoreDataFooterView() -> TPCNoMoreDataFooterView {
        let footerView =  NSBundle.mainBundle().loadNibNamed("TPCNoMoreDataFooterView", owner: nil, options: nil).first as! TPCNoMoreDataFooterView
        footerView.bounds.size.height = TPCConfiguration.technicalTableViewFooterViewHeight
        return footerView
    }
    
    @IBOutlet weak var endLabel: UILabel! {
        didSet {
            endLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: 22.0)
            endLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    @IBOutlet weak var endLineLeftImageView: UIImageView!
    @IBOutlet weak var endLineRightImageView: UIImageView!
    @IBOutlet weak var snowPointLabel: UILabel! {
        didSet {
            snowPointLabel.textColor = TPCConfiguration.themeTextColor
            let transformAnimation = CABasicAnimation(keyPath: "transform")
            transformAnimation.removedOnCompletion = false
            transformAnimation.repeatCount = MAXFLOAT
            transformAnimation.duration = 2.0
            transformAnimation.beginTime = CACurrentMediaTime()
            transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeRotation(0, 0, 0, 1.0))
            transformAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2 * 2.0), 0, 0, 1.0))
            snowPointLabel.layer.addAnimation(transformAnimation, forKey: "nil")
        }
    }
    @IBOutlet weak var gotoWebButton: UIButton! {
        didSet {
            gotoWebButton.setTitleColor(TPCConfiguration.themeTextColor, forState: UIControlState.Normal)
            gotoWebButton.titleLabel!.font = UIFont(name: TPCConfiguration.themeSFontName, size: 12.0)
        }
    }

    @IBAction func gotoWeb(sender: AnyObject) {
        debugPrint("去网页干货")
        gotoWebAction?()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        debugPrint("点击了尾部")
    }
}
