//
//  UIBarButtonItem+Extension.swift
//
//  Created by tripleCC on 15/11/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

public enum UIBarButtonItemPosition: Int {
    case Right
    case Left
}

extension UIBarButtonItem {
    public convenience init(image: UIImage?, target: AnyObject?, action: Selector, position:UIBarButtonItemPosition = .Left, fit: Bool = false) {
        let btn = UIButton(type: UIButtonType.Custom)
        btn.frame = CGRect(x: 0, y: 0, width: 80, height: 35)
        if position == .Left {
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchDown)
        btn.setImage(image, forState: UIControlState.Normal)
        btn.contentHorizontalAlignment = position == .Left ? .Left : .Right
        if fit { btn.sizeToFit() }
        
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