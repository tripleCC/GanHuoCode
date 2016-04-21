//
//  TPCBroswerViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class TPCBroswerViewController: TPCViewController {
    private let rightCustomButtonImageViewAnimationKey = "rightCustomButtonImageView"
    var technical: TPCTechnicalObject? {
        didSet {
            URLString = technical?.url
            navigationItem.title = technical?.desc ?? ""
            if let rawData = technical?.rawData {
                TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
                    self.ganhuo = GanHuoObject.insertObjectInBackgroundContext(rawData)
                })
            }
        }
    }
    var URLString: String?
    var ganhuo: GanHuoObject?
    private lazy var webView: TPCWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        var webView = TPCWebView(frame: CGRectZero, configuration: configuration)
        webView.navigationDelegate = self
        webView.UIDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.adjustBarPosition = {[unowned self] in
            self.adjustBarPositionByVelocity($0.y, contentOffsetY: $1)
            self.adjustToolBarPositionByVelocity($0.y, contentOffsetY: $1)
        }
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0
        progressView.progressTintColor = UIColor.lightGrayColor()
        progressView.trackTintColor = UIColor.whiteColor()
        return progressView
    }()
    
    @IBOutlet weak var toolBar: UIToolbar! {
        didSet {
            for view in toolBar.subviews {
                if view.bounds.height < 2 {
                    if let view = view as? UIImageView {
                        view.removeFromSuperview()
                        break
                    }
                }
            }
        }
    }
    
    
    @IBAction func backItemOnClicked(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardItemOnClicked(sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func shareItemOnClicked(sender: AnyObject) {
        var shareText = navigationItem.title ?? "" + " "
        if let urlString = webView.URL?.absoluteString {
            shareText += urlString
        }
        TPCShareView.showWithTitle(technical?.desc, desc: technical?.desc, mediaURL: webView.URL)
    }
    
    @IBAction func readItemOnClicked(sender: AnyObject) {
        // 这里有条件可以从localhost读取，这样就可以读取网页缓存了（为知笔记就是这么干的，就是不知道他的实现方式）
        // 应该是执行js，然后用document.documentElement.outerHTML导出储存，用SFSafariViewController打开本地HTML
        let sfVc = SFSafariViewController(URL: webView.URL ?? NSURL(), entersReaderIfAvailable: true)
        sfVc.delegate = self
        navigationController?.navigationBar.hidden = true
        navigationController?.pushViewController(sfVc, animated: true)
    }
    
    @IBAction func favoriteItemOnClicked(sender: AnyObject) {
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
            if self.ganhuo != nil {
                if self.ganhuo!.favorite == nil {
                    self.ganhuo!.favorite = NSNumber(bool: false)
                }
                self.ganhuo!.favorite = NSNumber(bool: !self.ganhuo!.favorite!.boolValue)
                self.ganhuo!.favoriteAt = String(NSDate().timeIntervalSince1970)
            }
            dispatchAMain {
                self.changeFavoriteImage()
                NSNotificationCenter.defaultCenter().postNotificationName(TPCFavoriteGanHuoChangeNotification, object: nil)
            }
        })
    }
    
    func changeFavoriteImage() {
        favoriteItem.image = ganhuo?.favorite?.boolValue == true ? UIImage(named: "favorite_h") : UIImage(named: "favorite")
    }
    
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var forwardItem: UIBarButtonItem!
    @IBOutlet weak var readItem: UIBarButtonItem!
    @IBOutlet weak var favoriteItem: UIBarButtonItem! {
        didSet {
            changeFavoriteImage()
        }
    }
    @IBOutlet weak var shareItem: UIBarButtonItem!
    
    @IBOutlet weak var toolBar2ViewBottomConstrains: NSLayoutConstraint!
    
    var lastEstimatedProgress: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        setupNav()
        webView.loadRequest(URLString.flatMap{ NSURL(string: $0).flatMap{ NSMutableURLRequest(URL: $0, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15) } } ?? NSURLRequest())
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        registerObserverForApplicationDidEnterBackground()
    }
    
    func setupNav() {
        navigationBarBackgroundView.addSubview(progressView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "browser_refresh"), target: self, action: #selector(TPCBroswerViewController.refreshWebView), position: .Right)
    }
    
    var rightCustomButtonImageView: UIImageView? {
        return (navigationItem.rightBarButtonItem?.customView as? UIButton)?.imageView
    }
    
    func refreshWebView() {
        rightCustomButtonImageView?.layer.addRotateAnimationWithDuration(1.0, forKey: rightCustomButtonImageViewAnimationKey)
        webView.reload()
    }
    
    func more() {
        var messages = ["用浏览器打开"];
        if let ganhuo = ganhuo {
            messages.append(ganhuo.favorite == nil || !ganhuo.favorite!.boolValue ? "加入收藏" : "取消收藏")
        }
        
        TPCPopoverView.showMessages(messages, containerSize: CGSize(width: 120, height: CGFloat(messages.count) * TPCPopViewDefaultCellHeight), fromView: navigationItem.rightBarButtonItem!.customView!, fadeDirection: TPCPopoverViewFadeDirection.RightTop) { (row) -> () in
            switch row {
            case 0:
                self.openBySafari()
            case 1:
                TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
                    if self.ganhuo != nil {
                        if self.ganhuo!.favorite == nil {
                            self.ganhuo!.favorite = NSNumber(bool: false)
                        }
                        self.ganhuo!.favorite = NSNumber(bool: !self.ganhuo!.favorite!.boolValue)
                        self.ganhuo!.favoriteAt = String(NSDate().timeIntervalSince1970)
                    }
                    dispatchAMain {
                        NSNotificationCenter.defaultCenter().postNotificationName(TPCFavoriteGanHuoChangeNotification, object: nil)
                    }
                })
            default:
                return
            }
        }
    }
    
    func openBySafari() {
        if let url = NSURL(string: URLString ?? "") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        removeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navigationController = navigationController {
            webView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            webView.scrollView.contentInset = UIEdgeInsets(top: navigationController.navigationBar.bounds.height + TPCStatusBarHeight, left: 0, bottom: 0, right: 0)
            progressView.frame = CGRect(x: 0, y: TPCNavigationBarHeight + TPCStatusBarHeight - progressView.frame.height - 1.0, width: TPCScreenWidth, height: progressView.frame.height)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(toolBar)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
                    print(navigationController?.navigationBar.frame)
        if let keyPath = keyPath {
            if keyPath == "estimatedProgress" && object === webView && lastEstimatedProgress <= webView.estimatedProgress {
                progressView.setProgress((Float)(webView.estimatedProgress), animated: true)
                progressView.hidden = progressView.progress == 1.0
                lastEstimatedProgress = webView.estimatedProgress
                if progressView.progress == 1.0 {
                    rightCustomButtonImageView?.layer.removeAllAnimations()
                }
                
                print(progressView.progress)
            }
        }
    }
    
    func adjustToolBarPositionByVelocity(velocity: CGFloat, contentOffsetY: CGFloat, animated: Bool = true) {
        guard let _ = view.window else { return }
        var descC = toolBar2ViewBottomConstrains.constant
        if velocity > 1.0 {
            debugPrint("隐藏")
            descC = -toolBar.bounds.height
        } else if velocity < -1.0 {
            debugPrint("显示")
            descC = 0
        } else {
            if contentOffsetY <= TPCNavigationBarHeight * 2 + TPCStatusBarHeight {
                debugPrint("显示")
                descC = 0
            }
        }
        
        debugPrint(descC, toolBar2ViewBottomConstrains.constant)
        if descC != toolBar2ViewBottomConstrains.constant {
            self.toolBar2ViewBottomConstrains.constant = descC
            if animated {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

}

extension TPCBroswerViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        debugPrint(#function)
        navigationController?.popViewControllerAnimated(true)
        navigationController?.navigationBar.hidden = false
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        debugPrint(#function)
    }
}

extension TPCBroswerViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.progress = 0
        lastEstimatedProgress = 0
        changeBackForwordImage()
        debugPrint(#function, navigation)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        navigationItem.title = webView.title
        changeBackForwordImage()
        rightCustomButtonImageView?.layer.removeAllAnimations()
        debugPrint(webView.title, webView.canGoForward, webView.canGoBack)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        rightCustomButtonImageView?.layer.removeAllAnimations()
    }
    
    func changeBackForwordImage() {
        forwardItem.enabled = webView.canGoForward
        backItem.enabled = webView.canGoBack
        forwardItem.image = forwardItem.enabled ? UIImage(named: "brower_foward") : UIImage(named: "brower_forword_d")
        backItem.image = backItem.enabled ? UIImage(named: "brower_back") : UIImage(named: "brower_back_d")
    }
}

extension TPCBroswerViewController: WKUIDelegate {
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.mainFrame ?? true {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
}

