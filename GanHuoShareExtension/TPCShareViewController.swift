//
//  TPCShareViewController.swift
//  干货
//
//  Created by tripleCC on 16/4/11.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import Social
import Alamofire

public class TPCShareViewController: UIViewController {
    var URLString: String?
    var items = [TPCShareItem]()
    var actionBeforeDisapear: ((vc: TPCShareViewController) -> Void)?
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickView: TPCShareItemTypePickView! {
        didSet {
            // 这里到时候要从userdefault里面取
            pickView.typesTitle = ["Android", "iOS", "休息视频", "福利", "拓展资源", "前端", "瞎推荐", "App"]
        }
    }
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancel(sender: AnyObject) {
        if postButton.titleForState(.Normal) == "发布" {
            hideSelf({ 
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.extensionContext?.cancelRequestWithError(error)
            })
        } else {
            hidePickView()
        }
    }
    
    @IBAction func post(sender: AnyObject) {
        if postButton.titleForState(.Normal) == "发布" {
            postGanHuo()
        } else {
            if let item = items.last {
                item.content = pickView.selectedTitle
                tableView.reloadData()
            }
            hidePickView()
        }
    }
    
    override public func viewDidLoad() {
        initializeItems()
        fetchURLString()
        
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pickView.transform = CGAffineTransformMakeTranslation(0, pickView.frame.height)
        containerView.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.height - containerView.frame.maxY)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        containerView.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.height - containerView.frame.maxY)
        doAnimateAction({
            self.containerView.transform = CGAffineTransformIdentity
            })
    }
    
    deinit {
        print("释放了")
    }
}

extension TPCShareViewController {
    private func fetchURLString() {
        if let item = extensionContext?.inputItems.first {
            let itemp = item.attachments.flatMap{ $0.first }
            if let itemp = itemp as? NSItemProvider {
                if itemp.hasItemConformingToTypeIdentifier("public.url") {
                    itemp.loadItemForTypeIdentifier("public.url", options: nil, completionHandler: { (url, error) in
                        if let url = url as? NSURL {
                            self.URLString = url.absoluteString
                            if let URLItem = self.items.first {
                                URLItem.content = self.URLString
                                self.tableView.reloadData()
                            }
                            print(url.absoluteString)
                        }
                    })
                }
            }
        }
    }
    
    private func initializeItems() {
        items.removeAll()
        
        let URLItem = TPCShareItem(content: URLString, placeholder: "输入分享链接", contentImage: UIImage(named: "se_link")!)
        let descItem = TPCShareItem(placeholder: "输入分享描述", contentImage: UIImage(named: "se_detail")!)
        let publisherItem = TPCShareItem(content: getPublsiher(), placeholder: "输入发布人昵称", contentImage: UIImage(named: "se_publisher")!)
        let typeItem = TPCShareItem(content: "iOS", contentImage: UIImage(named: "se_type")!, type: .Display, clickAction: { [unowned self] content in
            self.showPickView()
        })
        items.appendContentsOf([URLItem, descItem, publisherItem, typeItem])
    }
    
    private func postGanHuo() {
        let keys = ["url", "desc", "who", "type", "debug"]
        var parameters = [String : AnyObject]()
        for (idx, key) in keys.enumerate() {
            if idx < items.count {
                parameters[key] = items[idx].content
            }
        }
        parameters["debug"] = true
        savePublisher(parameters["who"] as? String ?? "")
        print(parameters)
        Alamofire.request(.POST, TPCTechnicalType.Add2Gank.path(), parameters: parameters)
                 .response { (request, response, data, error) in
                    print(response, data, request)
        }
        hideSelf {
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        }
    }
    
    private func savePublisher(publisher: String) {
        let userDefaults = NSUserDefaults(suiteName: "group.com.triplecc.WKCC")
        userDefaults?.setObject(publisher, forKey: "who")
    }
    
    private func getPublsiher() -> String {
        let userDefaults = NSUserDefaults(suiteName: "group.com.triplecc.WKCC")
        return userDefaults?.objectForKey("who") as? String ?? ""
    }
    
    private func hideSelf(completion: (() -> Void)) {
        doAnimateAction({
            self.containerView.transform = CGAffineTransformMakeTranslation(0, -self.containerView.frame.maxY)
            self.view.alpha = 0
            }, completion: { finished in
                completion()
                self.dismissViewControllerAnimated(false, completion: nil)
                self.actionBeforeDisapear?(vc: self)
        })
    }
    
    private func showPickView() {
        doAnimateAction({
            self.pickView.transform = CGAffineTransformIdentity
            }, completion: {
                self.postButton.setTitle("确定", forState: .Normal)
        })
    }
    
    private func hidePickView() {
        doAnimateAction({
            self.pickView.transform = CGAffineTransformMakeTranslation(0, self.pickView.frame.height)
            }, completion: {
                self.postButton.setTitle("发布", forState: .Normal)
        })
    }
    
    private func doAnimateAction(action: (() -> Void), completion:(() -> Void)? = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
            action()
            }, completion: { finished in
                completion?()
        })
    }
}

extension TPCShareViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = items[indexPath.row]
        item.clickAction?(item.content)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TPCShareViewCell
        cell.beEditing()
    }
}

extension TPCShareViewController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TPCShareViewCell", forIndexPath: indexPath) as! TPCShareViewCell
        cell.item = items[indexPath.row]
        cell.editCallBack = { [unowned self] content in
            self.items[indexPath.row].content = content
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}
