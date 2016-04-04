//
//  UIViewController+Extension.swift
//  GanHuo
//
//  Created by tripleCC on 15/12/27.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

public enum TPCIdentifierType: String {
    case AboutMeVc2BrowserVc = "AboutMeVc2BrowserVc"
    case SettingVc2LoadDataCountVc = "SettingVc2LoadDataCountVc"
    case SettingVc2ShowCategoryVc = "SettingVc2ShowCategoryVc"
    case SettingVc2ShowContentVc = "SettingVc2ShowContentVc"
    case SettingVc2ImageAlphaVc = "SettingVc2ImageAlphaVc"
    case SettingVc2AboutMeVc = "SettingVc2AboutMeVc"
    case DetailVc2BrowserVc = "DetailVc2BrowserVc"
    case TechnicalVc2BrowserVc = "TechnicalVc2BrowserVc"
    case TechnicalVc2SettingVc = "TechnicalVc2SettingVc"
    case TechnicalVc2DetailVc = "TechnicalVc2DetailVc"
}

extension UIViewController {
    func performSegueWithIdentifierType(type: TPCIdentifierType, sender: AnyObject?) {
        performSegueWithIdentifier(type.rawValue, sender: sender)
    }
    
    func pushToBrowserViewControllerWithURLString(URLString: String, ganhuo: GanHuoObject? = nil) {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let browserVc = sb.instantiateViewControllerWithIdentifier("BroswerViewController") as! TPCBroswerViewController
        browserVc.URLString = URLString
        browserVc.navigationItem.title = ganhuo?.desc ?? ""
        browserVc.ganhuo = ganhuo
        self.navigationController?.pushViewController(browserVc, animated: true)
    }
}
