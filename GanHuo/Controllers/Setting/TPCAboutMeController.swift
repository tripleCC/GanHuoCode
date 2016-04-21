//
//  TPCAboutMeController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import SwiftyJSON

class TPCAboutMeController: TPCViewController {
    var aboutMe: TPCAboutMe? {
        didSet {
            if aboutMe?.detail == nil {
                aboutMe = TPCAboutMe(dict: JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("AboutMe", ofType: "json")!)!))
            }
        }
    }
    
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
    
    @IBOutlet weak var otherLinksLabel: UILabel! {
        didSet {
            otherLinksLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellBFontSize)
            otherLinksLabel.textColor = TPCConfiguration.themeTextColor
        }
    }
    
    @IBOutlet var linkButtons: [TPCLinkButton]! {
        didSet {
            linkButtons.forEach{ $0.addTarget(self, action: #selector(TPCAboutMeController.gotoLinks(_:)), forControlEvents: .TouchDown) }
        }
    }
    
    func gotoLinks(sender: TPCLinkButton) {
        performSegueWithIdentifier("AboutMeVc2BrowserVc", sender: sender.title)
        TPCUMManager.event(.AboutMeJianShu)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AboutMeVc2BrowserVc" {
            if let descVc = segue.destinationViewController as? TPCBroswerViewController,
                let title = sender as? String {
                if let aboutMe = aboutMe {
                    if let links = aboutMe.links {
                        for link in links {
                            if link.title == title {
                                descVc.URLString = link.url
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
    }
    
    private func setupContents() {
        contentLabel.text = aboutMe?.detail
//        
//        for link in aboutMe!.links! {
//            let linkButton = TPCLinkButton(title: link.title!, link: link.url!)
//            scrollView.addSubview(linkButton)
//            linkButtons.append(linkButton)
//        }
    }
}
