//
//  TPCFavoriteGanHuoView.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/13.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCFavoriteGanHuoView: UIView {
    let reuseIdentifier = "GanHuoCategoryCell"
    var tableView: UITableView!
    var noFavoriteTipView: UIView!
    var technicals = [GanHuoObject]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        loadfavoriteGanHuo()
        setupConfig()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        loadfavoriteGanHuo()
        setupConfig()
    }
    
    private func setupConfig() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TPCFavoriteGanHuoView.favoriteGanHuoChange), name: TPCFavoriteGanHuoChangeNotification, object: nil)
    }
    
    func favoriteGanHuoChange() {
        loadfavoriteGanHuo()
    }
    
    private func setupSubviews() {
        tableView = UITableView(frame: frame, style: .Plain)
        tableView.registerNib(UINib(nibName: String(TPCCategoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        addSubview(tableView)
        
        noFavoriteTipView = NSBundle.mainBundle().loadNibNamed("TPCNoFavoriteTipView", owner: nil, options: nil).first as! UIView
        addSubview(noFavoriteTipView)
    }
    
    private func loadfavoriteGanHuo() {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock { () -> Void in
            self.technicals = GanHuoObject.fetchFavorite()
            dispatchAMain{
                debugPrint(#function, "\(self.technicals.count)")
                if self.technicals.count > 0 {
                    self.noFavoriteTipView.hidden = true
                } else {
                    self.noFavoriteTipView.hidden = false
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.separatorStyle = .None
        tableView.frame = bounds
        noFavoriteTipView.bounds.size = CGSize(width: 300, height: 100)
        noFavoriteTipView.center = tableView.center
    }
}

extension TPCFavoriteGanHuoView: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let url = technicals[indexPath.row].url {
            let sb = UIStoryboard(name: "HomePage", bundle: nil)
            let browserVc = sb.instantiateViewControllerWithIdentifier("BroswerViewController") as! TPCBroswerViewController
            browserVc.URLString = url
            browserVc.ganhuo = technicals[indexPath.row]
            self.viewController?.navigationController?.pushViewController(browserVc, animated: true)
        }
    }
}

extension TPCFavoriteGanHuoView: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCCategoryTableViewCell
        cell.readedView.hidden = true
        cell.ganhuo = technicals[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return technicals.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = technicals[indexPath.row].cellHeight {
            return CGFloat(height.floatValue)
        }
        return TPCCategoryTableViewCell.cellHeightWithGanHuo(technicals[indexPath.row])
    }
    // UICollectionView没有这个功能，需要自己实现，还是用UITableView好了
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "取消收藏") { (action, indexpath) -> Void in
            TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlockAndWait({ () -> Void in
                let ganhuo = self.technicals[indexPath.row]
                ganhuo.favorite = NSNumber(bool: false)
                self.technicals.removeAtIndex(indexPath.row)
                TPCCoreDataManager.shareInstance.saveContext()
                dispatchAMain({ () -> () in
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.noFavoriteTipView.hidden = self.technicals.count != 0
                })
            })
        }
        action.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
//        action.backgroundEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        return [action]
    }
}