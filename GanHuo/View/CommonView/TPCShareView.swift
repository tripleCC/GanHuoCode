//
//  TPCShareView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/30.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCShareView: UIView {
    var title: String?
    var desc: String?
    var image: UIImage?
    var mediaURL: NSURL?
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            doAppearAnimation(containerView)
        }
    }
    
    @IBOutlet weak var sinaContainerView: UIView! {
        didSet {
            sinaContainerView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "sinaContainerViewOnClicked")
            sinaContainerView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var qqContainerView: UIView! {
        didSet {
            qqContainerView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "qqContainerViewOnClicked")
            qqContainerView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var qqZoneContainerView: UIView! {
        didSet {
            qqZoneContainerView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "qqZoneContainerViewOnClicked")
            qqZoneContainerView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var wxContainerView: UIView! {
        didSet {
            wxContainerView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "wxContainerViewOnClicked")
            wxContainerView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet var nameLabels: [UILabel]! {
        didSet {
            if let nameLabels = nameLabels {
                for nameText in nameLabels {
                    nameText.font = TPCConfiguration.themeSFont
                    nameText.textColor = UIColor.grayColor()
                }
            }
        }
    }
    
    func qqContainerViewOnClicked() {
        TPCShareManager.shareInstance.shareQQWithTitle(title, desc: desc, image: image, mediaURL: mediaURL)
        maskViewOnClicked()
    }
    
    func qqZoneContainerViewOnClicked() {
        TPCShareManager.shareInstance.shareQQZoneWithTitle(title, desc: desc, image: image, mediaURL: mediaURL)
        maskViewOnClicked()
    }
    
    func wxContainerViewOnClicked() {
        TPCShareManager.shareInstance.shareWXWithTitle(title, desc: desc, image: image, mediaURL: mediaURL)
        maskViewOnClicked()
    }
    
    func sinaContainerViewOnClicked() {
        TPCShareManager.shareInstance.shareSinaWithTitle(title, desc: desc, image: image, mediaURL: mediaURL)
        maskViewOnClicked()
    }
    
    func doAppearAnimation(view: UIView) {
        view.transform = CGAffineTransformMakeScale(0.001, 0.001)
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            view.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func maskViewOnClicked() {
        TPCUMManager.event(TPCUMEvent.ShareCountCount)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 0
            }) { (finished) -> Void in
                self.removeFromSuperview()
        }
    }
    class func shareView() -> TPCShareView {
        return NSBundle.mainBundle().loadNibNamed("TPCShareView", owner: nil, options: nil)[0] as! TPCShareView
    }
    
    class func showWithTitle(title: String?, desc: String? = nil, image: UIImage? = nil, mediaURL: NSURL? = nil) {
        let shareView = TPCShareView.shareView()
        let tap = UITapGestureRecognizer(target: shareView, action: "maskViewOnClicked")
        shareView.addGestureRecognizer(tap)
        shareView.title = title
        shareView.desc = desc
        shareView.image = image
        shareView.mediaURL = mediaURL
        shareView.frame = UIScreen.mainScreen().bounds
        UIApplication.sharedApplication().keyWindow?.addSubview(shareView)
    }
}
