//
//  ShareViewController.swift
//  GanHuoShareExtension
//
//  Created by tripleCC on 16/4/12.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import Social


class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sb = UIStoryboard(name: "TPCShareViewController", bundle: NSBundle(forClass: TPCShareViewController.self))
        if let vc = sb.instantiateInitialViewController() {
            addChildViewController(vc)
            self.view.addSubview(vc.view)
            vc.view.frame = view.bounds
            vc.view.alpha = 0
            UIView.animateWithDuration(0.1, animations: {
                vc.view.alpha = 1
            })
        }
    }
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [AnyObject]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }

}
