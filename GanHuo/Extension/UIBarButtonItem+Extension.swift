//
//  UIBarButtonItem+Extension.swift
//  QiaobutangSwift
//
//  Created by tripleCC on 15/11/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    public convenience init(image: UIImage?, target: AnyObject?, action: Selector) {
        let btn = UIButton(type: UIButtonType.Custom)
        btn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchDown)
        btn.setImage(image, forState: UIControlState.Normal)
        btn.adjustsImageWhenHighlighted = false
        
        self.init(customView: btn)
    }
    
    public convenience init(title: String, action: ((inout enable: Bool) -> ())?) {
        let customView = TPCSystemButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customView.title = title
        customView.animationCompletion = { (inout enable: Bool) in
            action?(enable: &enable)
        }
        self.init(customView: customView)
    }
}