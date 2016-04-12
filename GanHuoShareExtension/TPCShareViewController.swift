//
//  TPCShareViewController.swift
//  干货
//
//  Created by tripleCC on 16/4/11.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import Social

public class TPCShareViewController: UIViewController {
    var URLString: String?
    var items = [TPCShareItem]()

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
        if !postButton.selected {
            hideSelf({ 
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.extensionContext?.cancelRequestWithError(error)
            })
        } else {
            hidePickView()
        }
    }
    
    @IBAction func post(sender: AnyObject) {
        if !postButton.selected {
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
        let publisherItem = TPCShareItem(placeholder: "输入发布人昵称", contentImage: UIImage(named: "se_publisher")!)
        let typeItem = TPCShareItem(content: "iOS", contentImage: UIImage(named: "se_type")!, type: .Display, clickAction: { content in
            self.showPickView()
        })
        items.appendContentsOf([URLItem, descItem, publisherItem, typeItem])
    }
    
    private func postGanHuo() {
        hideSelf { 
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        }
    }
    
    private func hideSelf(completion: (() -> Void)) {
        doAnimateAction({ 
            self.containerView.transform = CGAffineTransformMakeTranslation(0, -self.containerView.frame.maxY)
            self.view.alpha = 0
            }, completion: completion)
    }
    
    private func showPickView() {
        doAnimateAction({
            self.pickView.transform = CGAffineTransformIdentity
            }, completion: {
                self.postButton.selected = true
        })
    }
    
    private func hidePickView() {
        doAnimateAction({
            self.pickView.transform = CGAffineTransformMakeTranslation(0, self.pickView.frame.height)
            }, completion: {
                self.postButton.selected = false
        })
    }
    
    private func doAnimateAction(action: (() -> Void), completion:(() -> Void)? = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
            action()
            }, completion: { finished in
        completion?()
        })
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pickView.transform = CGAffineTransformMakeTranslation(0, pickView.frame.height)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        containerView.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.height - containerView.frame.maxY)
        doAnimateAction({ 
            self.containerView.transform = CGAffineTransformIdentity
            })
    }
}

extension TPCShareViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = items[indexPath.row]
        item.clickAction?(item.content)
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
    
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }

//    override func didSelectPost() {
//        if let item = extensionContext?.inputItems.first {
//            
//            let oitem = NSExtensionItem()
//            oitem.attributedContentText = NSAttributedString(string: contentText)
//            
//            extensionContext?.completeRequestReturningItems([oitem], completionHandler: nil)
//        }
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [AnyObject]! {
//        let one = SLComposeSheetConfigurationItem()
//        one.title = "分类"
//        one.value = "iOS"
//        one.tapHandler = {
//            let v = UIViewController()
//            self.pushConfigurationViewController(v)
//        }
//        return [one]
//    }

//}
