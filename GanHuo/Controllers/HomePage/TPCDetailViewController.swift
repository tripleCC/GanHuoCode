//
//  TPCDetailViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import Kingfisher

class TPCDetailViewController: TPCViewController {
    let navigationBarHideKey = "TPCDetailViewNavigationBarHideKey"
    let reuseIdentifier = "TPCDetailCell"
    let reuseHeaderIdentifier = "TPCDetailHeader"
    var technicalDict: TPCTechnicalDictionary?
    var categories: [String]? {
        didSet {
            categories = categories?.sort{ $0 < $1 }
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.clearColor()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = TPCConfiguration.detailCellHeight
            tableView.sectionFooterHeight = 0
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            tableView.registerClass(TPCDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: reuseHeaderIdentifier)
            tableView.contentInset = UIEdgeInsets(top: TPCConfiguration.detailHeaderImageViewHeight, left: 0, bottom: 0, right: 0)
        }
    }
    
    private lazy var headerImageView: UIImageView = {
        let headerImageView = UIImageView()
        headerImageView.frame = CGRect(x: 0, y: 0, width: TPCScreenWidth, height: TPCConfiguration.detailHeaderImageViewHeight)
        headerImageView.clipsToBounds = true
        headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        headerImageView.alpha = CGFloat(TPCConfiguration.imageAlpha)
        return headerImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        view.insertSubview(headerImageView, belowSubview: tableView)
        debugPrint(technicalDict)
        if let technicals = technicalDict?["福利"] where technicals.count > 1 {
            technicals.forEach{ debugPrint("\($0.url)") }
        }
        if let technical = technicalDict?["福利"]?.first {
            headerImageView.kf_setImageWithURL(NSURL(string: technical.url!)!)
        }
        registerObserverForApplicationDidEnterBackground()
        registerObserverForApplicationDidEnterForeground()
    }
    
    private func setupNav() {
        navigationBarBackgroundView.removeFromSuperview()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "all"), style: .Done, target: self, action: #selector(TPCDetailViewController.showAllImages))
    }
    
    func showAllImages() {
        if let technicals = technicalDict?["福利"] {
            let pageScrollView = TPCPageScrollView(frame: view.bounds)
            pageScrollView.backgroundColor = UIColor.blackColor()
            pageScrollView.viewDisappearAction = { [unowned self] in
                self.prepareForPageDisappear()
            }
            pageScrollView.imageURLStrings = technicals.flatMap{ $0.url }
            pageScrollView.alpha = 0
            view.addSubview(pageScrollView)
            UIView.animateWithDuration(0.5) { () -> Void in
                self.prepareForPageAppear()
                pageScrollView.alpha = 1
            }
        }
    }
    
    func prepareForPageAppear() {
//        view.alpha = 0
        headerImageView.alpha = 0
        tableView.alpha = 0
        navigationController!.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 0.1
        adjustBarToHidenPosition()
    }
    
    func prepareForPageDisappear() {
//        view.alpha = 1
        headerImageView.alpha = 1
        tableView.alpha = 1
        navigationController!.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 0
        adjustBarToOriginPosition()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func applicationDidEnterBackground(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().setBool(navigationBarFrame!.origin.y == TPCStatusBarHeight, forKey: navigationBarHideKey)
        debugPrint(#function, navigationBarFrame!.origin.y == TPCStatusBarHeight)
    }
    
    override func applicationDidEnterForeground(notification: NSNotification) {
        debugPrint(#function)
        if !NSUserDefaults.standardUserDefaults().boolForKey(navigationBarHideKey) {
            dispatchSeconds(0.5, action: { 
                self.adjustBarToHidenPosition()
            })
        }
    }
    
    deinit {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: navigationBarHideKey)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailVc2BrowserVc" {
            if let broswerVc = segue.destinationViewController as? TPCBroswerViewController {
                if let row = sender?.row,
                    let section = sender?.section,
                    let category = categories?[section] {
                        broswerVc.technical = technicalDict?[category]?[row]
                    }
                }
            }
        }
    }


extension TPCDetailViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard categories?[section] != nil else {  return 0 }
        return technicalDict?[categories![section]]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! TPCDetailViewCell
        if let catagory = categories?[indexPath.section] {
            cell.technical = technicalDict?[catagory]?[indexPath.row]
        }

        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseHeaderIdentifier) as! TPCDetailHeaderView
        header.title = categories?[section]
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TPCConfiguration.detailSectionHeaderHeight
    }
}

extension TPCDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("DetailVc2BrowserVc", sender: indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if abs(scrollView.contentOffset.y) < scrollView.contentInset.top {
                headerImageView.transform = CGAffineTransformMakeTranslation(0, -(scrollView.contentOffset.y + scrollView.contentInset.top) * 0.5)
            } else {
                let scale = (abs(scrollView.contentOffset.y + scrollView.contentInset.top) + TPCConfiguration.detailHeaderImageViewHeight) / TPCConfiguration.detailHeaderImageViewHeight
                headerImageView.transform = CGAffineTransformMakeScale(scale, scale)
                headerImageView.frame.origin.y = 0
            }
        }
    }
}

