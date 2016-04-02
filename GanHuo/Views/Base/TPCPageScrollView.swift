//
//  TPCPageScrollView.swift
//  TPCPageScrollView
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCPageScrollView: UIView {
    let padding: CGFloat = 40
    var viewDisappearAction: (() -> ())?
    var imageMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit {
        didSet {
            currentImageView.imageMode = imageMode
            backupImageView.imageMode = imageMode
        }
    }
    var imageURLStrings: [String]! {
        didSet {
            guard imageURLStrings.count > 0 else { return }
            if imageURLStrings.count > 1 {
                backupImageView.imageURLString = imageURLStrings[1]
                backupImageView.tag = 1
            } else {
                scrollView.scrollEnabled = false
                // 覆盖全屏手势
                let pan = UIPanGestureRecognizer(target: self, action: nil)
                currentImageView.addGestureRecognizer(pan)
            }
            currentImageView.imageURLString = imageURLStrings[0]
            currentImageView.tag = 0
            
            countLabel.text = "1 / \(imageURLStrings.count)"
        }
    }
    private var scrollView: UIScrollView!
    private var countLabel: UILabel!
    var currentImageView: TPCImageView!
    var backupImageView: TPCImageView!
    var edgeMaskView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: bounds.width * 3, height: 0)
        scrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        currentImageView = TPCImageView(frame: CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height))
        currentImageView.oneTapAction = { [unowned self] in
            self.removeSelf()
        }
        currentImageView.longPressAction = { [unowned self] in
            self.setupBottomToolView()
        }
        scrollView.addSubview(currentImageView)
        
        backupImageView = TPCImageView(frame: CGRect(x: bounds.width * 2, y: 0, width: bounds.width, height: bounds.height))
        backupImageView.oneTapAction = { [unowned self] in
            self.removeSelf()
        }
        backupImageView.longPressAction = { [unowned self] in
            self.setupBottomToolView()
        }
        scrollView.addSubview(backupImageView)
        
        edgeMaskView = UIView(frame: CGRect(x: -padding, y: 0, width: padding, height: bounds.height))
        edgeMaskView.backgroundColor = UIColor.blackColor()
        addSubview(edgeMaskView)
        
        setupGradientLayers()
        
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        countLabel.center = CGPoint(x: TPCScreenWidth * 0.5, y: 40)
        countLabel.textAlignment = NSTextAlignment.Center
        countLabel.font = TPCConfiguration.themeBFont
        countLabel.textColor = UIColor.whiteColor()
        addSubview(countLabel)
        
//        setupBottomToolView()
    }
    
    private func setupGradientLayers() {
        let gradientLayerH: CGFloat = 60
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor];
        topGradientLayer.opacity = 0.5
        topGradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: gradientLayerH)
        layer.addSublayer(topGradientLayer)
        
        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor];
        bottomGradientLayer.opacity = 0.5
        bottomGradientLayer.frame = CGRect(x: 0, y: bounds.height - gradientLayerH, width: bounds.width, height: gradientLayerH)
        layer.addSublayer(bottomGradientLayer)
    }
    
    private func setupBottomToolView() {
        let alertVc = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertVc.addAction(UIAlertAction(title: "保存图片", style: .Default, handler: { (action) in
            if let image = self.currentImageView.image {
                TPCPhotoUtil.saveImage(image, completion: { (success) -> () in
                    self.imageDidFinishAuthorize(success: success)
                })
            }
        }))
        alertVc.addAction(UIAlertAction(title: "分享图片", style: .Default, handler: { (action) in
            TPCShareView.showWithTitle(nil, desc: "干货", image: self.currentImageView.image)
        }))
        
        alertVc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
//            self.removeSelf()
        }))
        
        viewController?.presentViewController(alertVc, animated: true, completion: nil)
        
        
//        let buttonWH: CGFloat = 30.0
//        let backButtonX = TPCScreenWidth * 0.1
//        let backButtonY = TPCScreenHeight - buttonWH * 1.5
//        let backButton = TPCSystemButton(frame: CGRect(x: TPCScreenWidth - backButtonX - buttonWH, y: backButtonY, width: buttonWH, height: buttonWH))
//        backButton.title = "关闭"
//        backButton.animationCompletion = { [unowned self] (inout enable: Bool) in
//            self.removeSelf()
//        }
//        addSubview(backButton)
//        
//        let saveButton = TPCSystemButton(frame: CGRect(x: TPCScreenWidth * 0.5 - buttonWH * 0.5, y: backButtonY, width: buttonWH, height: buttonWH))
//        saveButton.title = "保存"
//        saveButton.animationCompletion = { [unowned self] (inout enable: Bool) in
//            debugPrint("保存")
//            if let image = self.currentImageView.image {
//                TPCPhotoUtil.saveImage(image, completion: { (success) -> () in
//                    self.imageDidFinishAuthorize(success: success)
//                })
//            }
//        }
//        addSubview(saveButton)
//        
//        let shareButton = TPCSystemButton(frame: CGRect(x: backButtonX, y: backButtonY, width: buttonWH, height: buttonWH))
//        shareButton.title = "分享"
//        shareButton.animationCompletion = { [unowned self] (inout enable: Bool) in
//            TPCShareView.showWithTitle(nil, desc: "干货", image: self.currentImageView.image)
//        }
//        addSubview(shareButton)
    }
    
    func imageDidFinishAuthorize(success success: Bool) {
        alpha = 0
        let vc = UIApplication.sharedApplication().keyWindow!.rootViewController!
        var ac: UIAlertController
        func recoverActionInSeconds(seconds: NSTimeInterval) {
            dispatchSeconds(seconds) {
                self.alpha = 1
                ac.dismissViewControllerAnimated(false, completion: {
                    vc.navigationController?.navigationBarHidden = false
                    ac.navigationController?.navigationBarHidden = false
                })
            }
        }
        if success {
            ac = UIAlertController(title: "保存成功", message: "恭喜你！又新增一妹子！(｡・`ω´･)", preferredStyle: .Alert)
        } else {
            ac = UIAlertController(title: "保存失败", message: "是否前往设置访问权限", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
                recoverActionInSeconds(0.5)
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = url where UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }))
            ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
                recoverActionInSeconds(0)
            }))
        }
        vc.presentViewController(ac, animated: false, completion: {
            vc.navigationController?.navigationBarHidden = true
            ac.navigationController?.navigationBarHidden = true
        })
        if ac.actions.count == 0 {
            recoverActionInSeconds(1)
        }
    }
    
    private func setupBackButton() {
        let backButton = TPCSystemButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addSubview(backButton)
    }
    
    private func removeSelf() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 0
            self.viewDisappearAction?()
            }) { (finished) -> Void in
                self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}

extension TPCPageScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        if offsetX < bounds.width {
            edgeMaskView.frame.origin.x = padding / bounds.width * (bounds.width - offsetX) + bounds.width - offsetX - padding
            backupImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            backupImageView.tag = (currentImageView.tag - 1 + imageURLStrings.count) % imageURLStrings.count
            backupImageView.imageURLString = imageURLStrings[backupImageView.tag]
        } else if offsetX > bounds.width {
            edgeMaskView.frame.origin.x = padding / bounds.width * (bounds.width - offsetX) + 2 * bounds.width - offsetX
            backupImageView.frame = CGRect(x: bounds.width * 2, y: 0, width: bounds.width, height: bounds.height)
            backupImageView.tag = (currentImageView.tag + 1) % imageURLStrings.count
            backupImageView.imageURLString = imageURLStrings[backupImageView.tag]
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        scrollView.contentOffset.x = bounds.size.width
        if offsetX < bounds.width * 1.5 && offsetX > bounds.width * 0.5 {
            return
        }
        
        currentImageView.imageURLString = backupImageView.imageURLString
        currentImageView.tag = backupImageView.tag
        countLabel.text = "\(currentImageView.tag + 1) / \(imageURLStrings.count)"
    }
}