//
//  TPCShareView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/30.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCShareView: UIView {
    var title: String = ""
    var desc: String = ""
    var image: UIImage?
    var mediaURL: NSURL?
    @IBOutlet weak var sinaContainerView: UIView! {
        didSet {
            sinaContainerView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "sinaContainerViewOnClicked")
            sinaContainerView.addGestureRecognizer(tap)
            doAppearAnimation(sinaContainerView)
        }
    }
    @IBOutlet weak var nameText: UILabel! {
        didSet {
            nameText.font = TPCConfiguration.themeSFont
            nameText.textColor = UIColor.grayColor()
        }
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
    
    class func showWithTitle(title: String = "", desc: String = "", image: UIImage? = nil, mediaURL: NSURL? = nil) {
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
