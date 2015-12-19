//
//  UIButton+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

extension UIButton {
    class func createSystemButtonWith(title: String, action: ((inout enable: Bool) -> ())?) -> TPCSystemButton {
        let customView = TPCSystemButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customView.title = title
        customView.animationCompletion = { (inout enable: Bool) in
            action?(enable: &enable)
        }
        return customView
    }
}
