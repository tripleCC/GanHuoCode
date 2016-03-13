//
//  TPCTabBarController.swift
//  GanHuo
//
//  Created by tripleCC on 16/2/28.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreImage

class TPCTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // opaque
//        tabBar.translucent = false
        tabBar.backgroundImage = UIImage(color: UIColor.whiteColor())
        tabBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTabBarMirrorForView(view: UIView) -> UIImageView {
        let tabBarF = self.view.convertRect(tabBar.frame, toView: view)
        let tabBarImageView = UIImageView(frame: tabBarF)
        tabBarImageView.image = UIImage(layer: tabBar.layer)
        view.addSubview(tabBarImageView)
        return tabBarImageView
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
