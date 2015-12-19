//
//  TPCSystemButton.swift
//  iconCreator
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

@IBDesignable
class TPCSystemButton: UIView {
    @IBInspectable var title: String! {
        didSet {
            self.titleView.text = title
        }
    }
    private var circleView: UIButton!
    private var titleView: UILabel!
    private var circleLayer: CAShapeLayer!
    var animationCompletion: ((inout enable: Bool) -> ())?
    @IBInspectable var enable: Bool = true {
        didSet {
            self.circleLayer.fillColor = !enable ? UIColor.whiteColor().CGColor : UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
            self.titleView.textColor = !enable ? UIColor.lightGrayColor().colorWithAlphaComponent(0.5) : UIColor.whiteColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        circleView = UIButton(type: UIButtonType.Custom)
        circleView.adjustsImageWhenHighlighted = false
        circleView.addTarget(self, action: "circleViewDidTouchDown", forControlEvents: UIControlEvents.TouchDown)
        circleView.addTarget(self, action: "circleViewDidTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(circleView)
        circleView.frame = bounds
        
        circleLayer = CAShapeLayer()
        circleLayer.frame = circleView.bounds
        let circleLayerDrawRect = CGRect(x: circleView.frame.origin.x + 1, y: circleView.frame.origin.y + 1, width: circleView.frame.width - 2, height: circleView.frame.height - 2)
        circleLayer.path = UIBezierPath(ovalInRect: circleLayerDrawRect).CGPath
        circleLayer.strokeColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        circleLayer.fillColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        circleLayer.opacity = 1.0
        circleView.layer.addSublayer(circleLayer)
        
        titleView = UILabel()
        titleView.textColor = UIColor.whiteColor()
        titleView.textAlignment = NSTextAlignment.Center
        titleView.font = UIFont.systemFontOfSize(10)
        circleView.addSubview(titleView)
        
        let titleViewWH = sqrt((bounds.width * bounds.width) * 0.5)
        titleView.bounds = CGRect(x: 0, y: 0, width: titleViewWH, height: titleViewWH)
        titleView.center = circleView.center
    }
    
    func circleViewDidTouchDown() {
        UIView.animateWithDuration(0.05, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }) { (finished) -> Void in
        }
    }
    
    func circleViewDidTouchUpInside() {
        UIView.animateWithDuration(0.2, delay: 0.1, usingSpringWithDamping: 5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.circleView.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                self.animationCompletion?(enable: &self.enable)
        }
    }
}
