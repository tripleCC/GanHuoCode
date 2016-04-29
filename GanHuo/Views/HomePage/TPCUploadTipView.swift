//
//  TPCUploadTipView.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/28.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import LTMorphingLabel

let kTPCUploadTipViewSize = CGSize(width: 200, height: 300)
class TPCUploadTipView: UIView {

    @IBOutlet weak var tipLabel: LTMorphingLabel!
    @IBOutlet weak var imageView: UIImageView! 
    var refreshView: TPCRefreshView!
    lazy var images: [UIImage] = {
        var images = [UIImage]()
        for i in 1...6 {
            images.append(UIImage(named: "upload_\(i)")!)
        }
        return images
    }()
    
    lazy var centers: [CGPoint] = {
        var centers = [CGPoint]()
        centers.append(CGPoint(x: 184.5, y: 48.5))
        centers.append(CGPoint(x: 26.5, y: 306.5))
        centers.append(CGPoint(x: 99.5, y: 364.5))
        centers.append(CGPoint(x: 112.5, y: 200.5))
        centers.append(CGPoint(x: 142.5, y: 363.5))
        centers.append(CGPoint(x: 178.5, y: 82.5))
        
        var trueCenters = [CGPoint]()
        for point in centers {
            trueCenters.append(CGPoint(x: point.x + self.imageView.frame.origin.x, y: point.y + self.imageView.frame.origin.y))
        }
        return trueCenters
    }()
    
    lazy var tips: [String] = {
        var tips = [String]()
        tips.append("上传干货的正确姿势!")
        tips.append("在safari中打开文章")
        tips.append("点击safari底部分享栏")
        tips.append("点击干货App")
        tips.append("没有干货App?点击更多并打开开关")
        tips.append("点击发布，欢迎老司机上车！")
        return tips
    }()
    
    override func awakeFromNib() {
        refreshView = TPCRefreshView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 25)))
        refreshView.addAnimation()
        addSubview(refreshView)
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(min(0.5, CGFloat(TPCConfiguration.imageAlpha) * 0.8))
        
        let rgb = CGFloat(TPCConfiguration.imageAlpha)
        tipLabel.textColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 1.0)
        tipLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: 18.0)
        tipLabel.text = tips.first
        
        imageView.image = images[0]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if refreshView.frame.origin == CGPoint.zero {
            refreshView.center = centers[0]
        }
    }
    
    private func changeImage(image: UIImage) {
        let duration = 0.8
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush;
        imageView.layer.addAnimation(transition, forKey: "Image")
        imageView.image = image
        if let index = images.indexOf(image) {
            tipLabel.text = tips[index]
            UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: { 
                self.refreshView.center = self.centers[index]
                }, completion: nil)
        }
    }
    
    private func hideSelf() {
        UIView.animateWithDuration(0.25, animations: { 
            self.alpha = 0
            }) { (finished) in
                self.removeFromSuperview()
        }
    }
    
    static func showTipView() {
        let tipView = NSBundle.mainBundle().loadNibNamed(String(TPCUploadTipView), owner: nil, options: nil).first as! TPCUploadTipView
        tipView.frame = UIScreen.mainScreen().bounds
        UIApplication.sharedApplication().keyWindow?.addSubview(tipView)
        tipView.alpha = 0
        UIView.animateWithDuration(0.5) {
            tipView.alpha = 1
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = touches.first?.locationInView(self) {
            if CGRectContainsPoint(imageView.frame, point) {
                if imageView.image == images.last {
                    hideSelf()
                } else {
                    if let index = images.indexOf(imageView.image!) {
                        changeImage(images[index.successor()])
                    }
                }
            } else {
//                hideSelf()
            }
        }
    }
    deinit {
        print("释放了")
    }
}