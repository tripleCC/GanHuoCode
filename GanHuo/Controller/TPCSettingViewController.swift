//
//  TPCSettingViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import SDWebImage

private let GIVE_A_FAVORABLE_RECEPTION = "给幹貨好评"
private let GIVE_A_FEEDBACK = "给幹貨反馈"
private let LOAD_DATA_EACH_TIME = "每次加载数目"
private let CATEGORY_DISPLAY_AT_HOME = "主页显示类目"
private let CONTENT_RULES_AT_HOME = "显示类目内容"
private let PICTURE_TRANSPARENCY = "图片透明度"
private let ABOUT_ME = "关于我"
private let CLEAR_CACHE = "清除缓存"

typealias SetAction = ((indexPath: NSIndexPath) -> ())

class TPCSetItem {
    var title: String!
    var action: SetAction?
    var accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    var textAlignment = NSTextAlignment.Left
    var detailTitle: String?
    init(title: String!, detailTitle: String? = nil, action:SetAction? = nil, accessoryType: UITableViewCellAccessoryType = .DisclosureIndicator, textAlignment: NSTextAlignment = .Left) {
        self.title = title
        self.action = action
        self.accessoryType = accessoryType
        self.textAlignment = textAlignment
        self.detailTitle = detailTitle
    }
}

class TPCSettingViewController: TPCViewController {
    let reuseIdentifier = "settingCell"
    var contents = [[TPCSetItem]]()
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = TPCConfiguration.settingCellHeight
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = 10
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
            tableView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCStatusBarHeight, left: 0, bottom: 0, right: 0)
            tableView.registerClass(TPCSettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    var tipLabel: UILabel = {
        let tipLabel = UILabel(frame: CGRect(x: 0, y: TPCScreenHeight - 20 - 10, width: TPCScreenWidth, height: 20))
        tipLabel.text = "继续下拉返回首页"
        tipLabel.font = TPCConfiguration.themeSFont
        tipLabel.textColor = TPCConfiguration.themeTextColor
        tipLabel.textAlignment = .Center
        tipLabel.alpha = 0
        return tipLabel
    }()
    lazy var mirrorView: UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(layer: self.view.layer)
        let data = UIImagePNGRepresentation(UIImage(layer: self.tableView.layer))
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] + "/tableView.png"
        debugPrint(path)
        data?.writeToFile(path, atomically: false)
        return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupContent()
    }
    
    private func setupContent() {
        setupOneSection()
        setupTwoSection()
        setupThreeSection()
        setupFourSection()
        view.addSubview(tipLabel)
    }
    
    private func setupOneSection() {
        let sectionOne = [TPCSetItem(title: GIVE_A_FAVORABLE_RECEPTION, action: { [unowned self] (setItem) -> () in
            self.giveAFavorableReception()
            }), TPCSetItem(title: GIVE_A_FEEDBACK, action: { [unowned self] (setItem) -> () in
                self.giveAFeedBack()
                })]
        guard TPCVenusUtil.venusFlag else { return }
        contents.append(sectionOne)
    }
    private func setupTwoSection() {
        let sectionTwo = [TPCSetItem(title: LOAD_DATA_EACH_TIME, detailTitle: TPCStorageUtil.fetchLoadDataNumberOnce(),action: { [unowned self] (indexPath) -> () in
            self.setLoadDataNumberOnce(indexPath)
            }), TPCSetItem(title: CATEGORY_DISPLAY_AT_HOME, detailTitle: TPCStorageUtil.fetchSelectedShowCategory(), action: { [unowned self] (indexPath) -> () in
                self.setCategoryDisplayAtHome(indexPath)
                }), TPCSetItem(title: CONTENT_RULES_AT_HOME, detailTitle: getRuleStringWithItems(TPCStorageUtil.fetchRawContentRules()), action: { [unowned self] (indexPath) -> () in
                    self.setContentRulesAtHome(indexPath)
                    }), TPCSetItem(title: PICTURE_TRANSPARENCY, detailTitle: String(format: "%.02f", TPCConfiguration.imageAlpha), action: { [unowned self] (indexPath) -> () in
                        self.setPictureTransparency(indexPath)
                        })]
        contents.append(sectionTwo)
    }
    private func setupThreeSection() {
        let sectionThree = [TPCSetItem(title: ABOUT_ME, action: { [unowned self] (indexPath) -> () in
                self.aboutMe(indexPath)
            })]
        contents.append(sectionThree)
    }
    private func setupFourSection() {
        let diskSize = String(format: "%.2f", Double(SDImageCache.sharedImageCache().getSize()) / 1024.0 / 1024.0)
        let sectionFour = [TPCSetItem(title: CLEAR_CACHE, detailTitle: "\(diskSize)M", action: { [unowned self] (indexPath) -> () in
            self.clearCache(indexPath)
            }, accessoryType: .None)]
        contents.append(sectionFour)
    }
    
    private func setupNav() {
        navigationBarType = .Line
        navigationItem.title = "设置"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", action: { [unowned self] (enable) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    private func getRuleStringWithItems(items: [String]) -> String {
        var descString = String()
        for item in items {
            descString += "\(item)+"
        }
        if descString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            descString = descString.substringToIndex(descString.endIndex.advancedBy(-1))
        }
        return descString
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = sender as? NSIndexPath {
            let descVc = segue.destinationViewController
            descVc.navigationItem.title = contents[indexPath.section][indexPath.row].title
            if segue.identifier == "SettingVc2LoadDataCountVc" {
                if let settingSubVc = segue.destinationViewController as? TPCLoadDataCountController {
                    settingSubVc.selectedRow = TPCStorageUtil.fetchLoadDataNumberOnce()
                    settingSubVc.callAction = { (item: String) in
                        self.contents[indexPath.section][indexPath.row].detailTitle = item
                        self.tableView.reloadData()
                        TPCStorageUtil.saveLoadDataNumberOnce(item)
                        TPCConfiguration.loadDataCountOnce = item.getLoadDataNumber()
                        TPCUMManager.event(TPCUMEvent.LoadDataCountCount, attributes: ["loadDataCountOnce" : item])
                    }
                }
            } else if segue.identifier == "SettingVc2ShowCategoryVc" {
                if let settingSubVc = segue.destinationViewController as? TPCShowCategoryController {
                    settingSubVc.selectedRow = TPCStorageUtil.fetchSelectedShowCategory()
                    settingSubVc.callAction = { (item: String) in
                        self.contents[indexPath.section][indexPath.row].detailTitle = item
                        self.tableView.reloadData()
                        TPCStorageUtil.saveSelectedShowCategory(item)
                        TPCConfiguration.selectedShowCategory = item
                        TPCUMManager.event(TPCUMEvent.ShowCategoryCategory, attributes: ["showCategory" : item])
                    }
                }
            } else if segue.identifier == "SettingVc2ShowContentVc" {
                if let settingSubVc = segue.destinationViewController as? TPCShowContentController {
                    settingSubVc.selectedRows = TPCConfiguration.contentRules
                    settingSubVc.callAction = { (items: [TPCRuleType]) in
                        var ruleString = [String]()
                        for rule in items {
                            ruleString.append(rule.rawValue)
                        }
                        TPCConfiguration.contentRules = items
                        self.contents[indexPath.section][indexPath.row].detailTitle = self.getRuleStringWithItems(ruleString)
                        TPCStorageUtil.saveContentRules(ruleString)
                        self.tableView.reloadData()
                        TPCUMManager.event(TPCUMEvent.ContentRuleRule, attributes: ["showCategory" : self.getRuleStringWithItems(ruleString)])
                    }
                }
            } else if segue.identifier == "SettingVc2ImageAlphaVc" {
                if let settingSubVc = segue.destinationViewController as? TPCImageAlphaController {
                    settingSubVc.callAction = { (item: Float) in
                        TPCConfiguration.imageAlpha = item
                        self.contents[indexPath.section][indexPath.row].detailTitle = String(format: "%.02f", TPCConfiguration.imageAlpha)
                        TPCStorageUtil.saveImageAlpha(item)
                        self.tableView.reloadData()
                        TPCUMManager.event(TPCUMEvent.ImageAlphaAlpha, attributes: ["imageAlpha" : "imageAlpha"], counter: Int(item *  1000))
                    }
                }
            }
        }
    }
}

typealias TPCSettingFunction = TPCSettingViewController
extension TPCSettingFunction {
    private func giveAFavorableReception() {
        TPCVersionUtil.openUpdateLink()
    }
    
    private func giveAFeedBack() {
        let mail = "triplec.linux@gmail.com"
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto://\(mail)")!)
    }
    
    private func setLoadDataNumberOnce(indexPath: NSIndexPath) {
        performSegueWithIdentifier("SettingVc2LoadDataCountVc", sender: indexPath)
    }
    
    private func setCategoryDisplayAtHome(indexPath: NSIndexPath) {
        performSegueWithIdentifier("SettingVc2ShowCategoryVc", sender: indexPath)
    }
    
    private func setContentRulesAtHome(indexPath: NSIndexPath) {
        performSegueWithIdentifier("SettingVc2ShowContentVc", sender: indexPath)
    }
    
    private func setPictureTransparency(indexPath: NSIndexPath) {
        performSegueWithIdentifier("SettingVc2ImageAlphaVc", sender: indexPath)
    }
    
    private func aboutMe(indexPath: NSIndexPath) {
        performSegueWithIdentifier("SettingVc2AboutMeVc", sender: indexPath)
    }
    
    private func clearCache(indexPath: NSIndexPath) {
        let item = contents[indexPath.section][indexPath.row]
        SDImageCache.sharedImageCache().clearDiskOnCompletion{ () -> Void in
            item.detailTitle = "0.00M"
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}

extension TPCSettingViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return contents.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCSettingCell
        cell.setItem = contents[indexPath.section][indexPath.row]
        return cell
    }
}

extension TPCSettingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let setItem = contents[indexPath.section][indexPath.row]
        setItem.action?(indexPath: indexPath)
    }
}

extension TPCSettingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let modelY: CGFloat = 0
        if scrollView.contentOffset.y > modelY {
            UIApplication.sharedApplication().keyWindow?.addSubview(mirrorView)
            mirrorView.transform = CGAffineTransformIdentity
            dismissViewControllerAnimated(false, completion: nil)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.mirrorView.transform = CGAffineTransformMakeTranslation(0, -self.mirrorView.bounds.height)
                }, completion: { (finished) -> Void in
                    self.mirrorView.removeFromSuperview()
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let modelY: CGFloat = 0
        if scrollView.contentOffset.y >= -20 {
            var alpha = abs(scrollView.contentOffset.y + 20) / (modelY + 10)
            alpha = min(alpha, 1)
            tipLabel.alpha = alpha
            tipLabel.text = "继续下拉返回首页"
        } else {
            tipLabel.alpha = 0
        }
        
        if scrollView.contentOffset.y > modelY {
            tipLabel.text = "松手返回首页"
        }
    }
}
