//
//  TPCSettingViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import Kingfisher

public enum TPCSetItemType: String {
    case FavorableReception = "给幹貨好评"
    case Feedback = "给幹貨反馈"
    case NewVersion = "最新版本"
    case LoadDataEachTime = "每次加载数目"
    case DisplayCategory = "主页显示类目"
    case ContentRules = "显示类目内容"
    case PictureAlpha = "图片透明度"
    case AboutMe = "关于我"
    case ClearCache = "清除缓存"
}

typealias SetAction = ((indexPath: NSIndexPath) -> ())

class TPCSetItem {
    var title: String!
    var action: SetAction?
    var aboutMe: TPCAboutMe?
    var accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    var textAlignment = NSTextAlignment.Left
    var detailTitle: String?
    init(title: TPCSetItemType!, detailTitle: String? = nil, action:SetAction? = nil, accessoryType: UITableViewCellAccessoryType = .DisclosureIndicator, textAlignment: NSTextAlignment = .Left) {
        self.title = title.rawValue
        self.action = action
        self.accessoryType = accessoryType
        self.textAlignment = textAlignment
        self.detailTitle = detailTitle
    }
}

class TPCSettingViewController: TPCViewController {
    let reuseIdentifier = "settingCell"
    var contents = [[TPCSetItem]]()
    var aboutMe: TPCAboutMe?
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
        loadAboutMe()
    }
    
    private func loadAboutMe() {
        // 后期TPCLaunchConfig中存储更新标志，比如版本是否更新，关于我是否更新（可以是一个Int），并保存TPCLaunchConfig，每次下载时进行比较，如果不相等，就下载对应的数据，比如AboutMe从2->3，就下载TPCAboutMe数据，然后存入本地。
        // 这样每次下载的数据只有TPCLaunchConfig中的标志位，不费流量，并且本地缓存更加容易
        TPCNetworkUtil.shareInstance.loadAbountMe { (aboutMe) -> () in
            self.aboutMe = aboutMe
        }
    }
    
    private func setupContent() {
        contents = [sectionOne, sectionTwo, sectionThree, sectionFour]
        if !TPCVenusUtil.venusFlag {
            // 把过滤类型弄到TPCVenusUtil去，改成enum
            contents = contents.map{ $0.filter{ !TPCVenusUtil.filterSetItems.contains($0.title) } }
        }
        view.addSubview(tipLabel)
    }
    
    private var sectionOne: [TPCSetItem] {
        return [TPCSetItem(title: .FavorableReception, action: { [unowned self] (setItem) -> () in
            self.giveAFavorableReception()
            }), TPCSetItem(title: .Feedback, action: { [unowned self] (setItem) -> () in
                self.giveAFeedBack()
                })]
    }
    
    private var sectionTwo: [TPCSetItem] {
        return [TPCSetItem(title: .LoadDataEachTime, detailTitle: TPCStorageUtil.fetchLoadDataNumberOnce(),action: { [unowned self] (indexPath) -> () in
            self.setLoadDataNumberOnce(indexPath)
            }), TPCSetItem(title: .DisplayCategory, detailTitle: TPCStorageUtil.fetchSelectedShowCategory(), action: { [unowned self] (indexPath) -> () in
                self.setCategoryDisplayAtHome(indexPath)
                }), TPCSetItem(title: .ContentRules, detailTitle: getRuleStringWithItems(TPCStorageUtil.fetchRawContentRules()), action: { [unowned self] (indexPath) -> () in
                    self.setContentRulesAtHome(indexPath)
                    }), TPCSetItem(title: .PictureAlpha, detailTitle: String(format: "%.02f", TPCConfiguration.imageAlpha), action: { [unowned self] (indexPath) -> () in
                        self.setPictureTransparency(indexPath)
                        })]
    }
    
    private var sectionThree: [TPCSetItem] {
        return [TPCSetItem(title: .AboutMe, action: { [unowned self] (indexPath) -> () in
            self.aboutMe(indexPath)
            }), TPCSetItem(title: .NewVersion, detailTitle: TPCVersionUtil.versionInfo?.version ?? TPCCurrentVersion, action: { [unowned self] (indexPath) -> () in
                self.setNewVersion()
                })]
    }
    
    private var sectionFour: [TPCSetItem] {
        let sections = [TPCSetItem(title: .ClearCache, action: { [unowned self] (indexPath) -> () in
            self.clearCache(indexPath)
            TPCStorageUtil.shareInstance.clearFileCache()
            }, accessoryType: .None)]
        
        KingfisherManager.sharedManager.cache.calculateDiskCacheSizeWithCompletionHandler { (size) -> () in
            let imageSize = Double(size) / 1000.0 / 1000.0
            let fileSize = Double(TPCStorageUtil.shareInstance.sizeOfFileAtPath(TPCStorageUtil.shareInstance.directoryForTechnicalDictionary)/* + TPCStorageUtil.shareInstance.sizeOfFileAtPath(TPCStorageUtil.shareInstance.pathForNoDataDays)*/) / 1000.0 / 1000.0
            
            print(fileSize)
            let cacheSizeString = String(format: "%.2fM", imageSize + fileSize)
            sections.first!.detailTitle = cacheSizeString
            self.tableView.reloadData()
        }
        return sections
    }
    
    private func setupNav() {
        navigationBarType = .Line
        navigationItem.title = "设置"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", action: { [unowned self] (enable) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    private func getRuleStringWithItems(items: [String]) -> String {
        return items.joinWithSeparator("+")
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
                        TPCConfiguration.loadDataCountOnce = item.getLoadDataNumber()
                        TPCStorageUtil.saveLoadDataNumberOnce(item)
                        self.tableView.reloadData()
                        TPCUMManager.event(TPCUMEvent.LoadDataCountCount, attributes: ["loadDataCountOnce" : item])
                    }
                }
            } else if segue.identifier == "SettingVc2ShowCategoryVc" {
                if let settingSubVc = segue.destinationViewController as? TPCShowCategoryController {
                    settingSubVc.selectedRow = TPCStorageUtil.fetchSelectedShowCategory()
                    settingSubVc.callAction = { (item: String) in
                        self.contents[indexPath.section][indexPath.row].detailTitle = item
                        TPCConfiguration.selectedShowCategory = item
                        TPCStorageUtil.saveSelectedShowCategory(item)
                        self.tableView.reloadData()
                        TPCUMManager.event(TPCUMEvent.ShowCategoryCategory, attributes: ["showCategory" : item])
                    }
                }
            } else if segue.identifier == "SettingVc2ShowContentVc" {
                if let settingSubVc = segue.destinationViewController as? TPCShowContentController {
                    settingSubVc.selectedRows = TPCConfiguration.contentRules
                    settingSubVc.callAction = { (items: [TPCRuleType]) in
                        let ruleString = items.map{ $0.rawValue }
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
            } else if segue.identifier == "SettingVc2AboutMeVc" {
                if let settingSubVc = segue.destinationViewController as? TPCAboutMeController {
                    settingSubVc.aboutMe = aboutMe
                }
            }
        }
    }
}

typealias TPCSettingFunction = TPCSettingViewController
extension TPCSettingFunction {
    private func giveAFavorableReception() {
        TPCVersionUtil.shouldUpdate = false
        TPCVersionUtil.openUpdateLink()
    }
    
    private func giveAFeedBack() {
        let mail = "triplec.linux@gmail.com"
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto://\(mail)")!)
    }
    
    private func setNewVersion() {
        if TPCCurrentVersion < TPCVersionUtil.versionInfo?.version {
            let ac = UIAlertController(title: "发现新版本", message: TPCVersionUtil.versionInfo?.newFunction, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "现在去吃", style: .Default, handler: { (action) -> Void in
                TPCVersionUtil.shouldUpdate = false
                TPCVersionUtil.openUpdateLink()
            }))
            ac.addAction(UIAlertAction(title: "稍后再说", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
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
        KingfisherManager.sharedManager.cache.clearDiskCacheWithCompletionHandler { () -> () in
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
        let modelY: CGFloat = 70
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
        let modelY: CGFloat = 70
        if scrollView.contentOffset.y >= 50 {
            var alpha = abs(scrollView.contentOffset.y - 50) / (modelY - 50)
            debugPrint(alpha)
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
