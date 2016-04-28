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
import MobileCoreServices

public class TPCShareViewController: UIViewController {
    var URLString: String?
    var items = [TPCShareItem]()
    var actionBeforeDisapear: ((vc: TPCShareViewController) -> Void)?
    
    var categories: [String] {
        get {
            if let categories = TPCStorageUtil.objectForKey(TPCAllCategoriesKey, suiteName: TPCAppGroupKey) as? [String] {
                return categories
            } else {
                return ["iOS", "Android", "App", "瞎推荐", "前端", "福利", "休息视频", "拓展资源"].filter{ !TPCFilterCategories.contains($0) }
            }
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var refreshView: TPCRefreshView! {
        didSet {
            refreshView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        }
    }
    @IBOutlet weak var titleView: TPCApplicationTitleView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickView: TPCShareItemTypePickView! {
        didSet {
            // 这里到时候要从userdefault里面取
            pickView.typesTitle = categories
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
        containerView.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.height)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pickView.transform = CGAffineTransformMakeTranslation(0, pickView.frame.height)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
                if itemp.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                    itemp.loadItemForTypeIdentifier(String(kUTTypePropertyList), options: nil, completionHandler: { (jsData, error) in
                        if let jsDict = jsData as? NSDictionary {
                            if let jsPreprocessingResults = jsDict[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                                if let title = jsPreprocessingResults["title"] as? String {
                                    self.items[1].content = title
                                }
                                
                                if let URLString = jsPreprocessingResults["URL"] as? String {
                                    self.URLString = URLString
                                    if let URLItem = self.items.first {
                                        URLItem.content = self.URLString
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func initializeItems() {
        items.removeAll()
        
        let URLItem = TPCShareItem(content: URLString, placeholder: "输入/粘贴分享链接", contentImage: UIImage(named: "se_link")!)
        let descItem = TPCShareItem(placeholder: "输入分享描述", contentImage: UIImage(named: "se_detail")!)
        let publisherItem = TPCShareItem(content: getPublsiher(), placeholder: "输入发布人昵称", contentImage: UIImage(named: "se_publisher")!)
        let typeItem = TPCShareItem(content: categories.first, contentImage: UIImage(named: "se_type")!, type: .Display, clickAction: { [unowned self] content in
            self.showPickView()
        })
        items.appendContentsOf([URLItem, descItem, publisherItem, typeItem])
    }
    
    private func startUpload() {
        refreshView.removeAnimation()
        refreshView.addAnimation()
        UIView.animateWithDuration(0.5) {
            self.refreshView.transform = CGAffineTransformIdentity
            self.titleView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            self.titleView.alpha = 0
            self.refreshView.alpha = 1
        }
    }
    
    private func stopUpload() {
        UIView.animateWithDuration(0.5) {
            self.titleView.transform = CGAffineTransformIdentity
            self.refreshView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            self.titleView.alpha = 1
            self.refreshView.alpha = 0
        }
    }
    
    private func postGanHuo() {
        postButton.userInteractionEnabled = false
        let keys = ["url", "desc", "who", "type", "debug"]
        var parameters = [String : AnyObject]()
        for (idx, key) in keys.enumerate() {
            if idx < items.count {
                parameters[key] = items[idx].content
            }
        }
        parameters["debug"] = "true"
        savePublisher(parameters["who"] as? String ?? "")
        print(parameters)
        startUpload()
        Alamofire.request(.POST, TPCTechnicalType.Add2Gank.path(), parameters: parameters)
                 .response { (request, response, data, error) in
                    self.stopUpload()
                    self.postButton.userInteractionEnabled = true
                    print(data.flatMap{try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments)})
                    var message: String?
                    var title: String?
                    if let data = data {
                        do {
                            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            if let error = result["error"] as? Bool {
                                title = error ? "上传失败 = =|" : "上传成功!"
                            }
                            message = result["msg"] as? String
                            
                        } catch {}
                    }
                    let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    self.presentViewController(ac, animated: true, completion: {
                        dispatchSeconds(1) {
                            ac.dismissViewControllerAnimated(true, completion: { finished in
                                if title == "上传成功!" {
                                    self.hideSelf {
                                        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                                    }
                                }
                            })
                        }
                    })
        }
    }
    
    private func savePublisher(publisher: String) {
        let userDefaults = NSUserDefaults(suiteName: TPCAppGroupKey)
        userDefaults?.setObject(publisher, forKey: "who")
    }
    
    private func getPublsiher() -> String {
        let userDefaults = NSUserDefaults(suiteName: TPCAppGroupKey)
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
