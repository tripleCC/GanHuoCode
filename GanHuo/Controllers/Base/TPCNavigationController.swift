//
//  TPCNavigationController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/17.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCNavigationController: UINavigationController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationBar.tintColor = TPCConfiguration.navigationBarBackColor
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSFontAttributeName : TPCConfiguration.navigationBarTitleFont!, NSForegroundColorAttributeName : TPCConfiguration.navigationBarBackColor]
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
//        if viewControllers.count != 0 {
//            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", action: { [unowned self] (enable) -> () in
//                self.back()
//            })
//        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    func back() {
        self.popViewControllerAnimated(true)
    }
}
