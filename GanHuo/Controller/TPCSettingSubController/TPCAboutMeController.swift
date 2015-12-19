//
//  TPCAboutMeController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCAboutMeController: TPCViewController {

    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.layer.cornerRadius = 5
            iconImageView.layer.borderWidth = 0.5
            iconImageView.layer.borderColor = TPCConfiguration.themeTextColor.colorWithAlphaComponent(0.5).CGColor
        }
    }
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            versionLabel.font = TPCConfiguration.themeSFont
            versionLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    @IBOutlet weak var authorLabel: UILabel! {
        didSet {
            authorLabel.font = TPCConfiguration.themeSFont
            authorLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel! {
        didSet {
            contentLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellBFontSize)
            contentLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    
    @IBOutlet weak var jianshuButton: UIButton! {
        didSet {
            jianshuButton.titleLabel?.font = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellBFontSize)
            jianshuButton.setTitleColor(TPCConfiguration.themeTextColor, forState: .Normal)
        }
    }
    
    @IBOutlet weak var otherLinksLabel: UILabel! {
        didSet {
            otherLinksLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellBFontSize)
            otherLinksLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    
    @IBAction func gotoJianshu() {
        performSegueWithIdentifier("AboutMeVc2BrowserVc", sender: nil)
        TPCUMManager.event(.AboutMeJianShu)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AboutMeVc2BrowserVc" {
            if let descVc = segue.destinationViewController as? TPCBroswerViewController {
                descVc.URLString = "http://www.jianshu.com/users/97e39e95c2cc/latest_articles"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
}
