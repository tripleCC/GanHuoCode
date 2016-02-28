//
//  TPCTabBarController.swift
//  GanHuo
//
//  Created by tripleCC on 16/2/28.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundImage = UIImage(color: UIColor.whiteColor())
        tabBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
