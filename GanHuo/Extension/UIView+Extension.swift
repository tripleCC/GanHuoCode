//
//  UIView+Extension.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/12.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import Foundation

extension UIView {
    var viewController: UIViewController? {
        var view: UIView? = self
        while view != nil {
            if let nextResponder = view!.nextResponder() as? UIViewController {
                return nextResponder
            } else {
                view = view?.superview
            }
        }
        return nil
    }
}