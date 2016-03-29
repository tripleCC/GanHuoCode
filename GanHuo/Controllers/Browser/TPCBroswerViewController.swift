//
//  TPCBroswerViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import WebKit

class TPCBroswerViewController: TPCViewController {

    var technical: TPCTechnicalObject? {
        didSet {
            self.URLString = technical?.url
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
    
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var backItem: TPCSystemButton! {
        didSet {
            backItem.animationCompletion = { [unowned self] (inout enable: Bool) in
                if self.webView.canGoBack {
                    self.webView.goBack()
                }

            }
        }
    }
    @IBOutlet weak var forwardItem: TPCSystemButton! {
        didSet {
            forwardItem.animationCompletion = { [unowned self] (inout enable: Bool) in
                if self.webView.canGoForward {
                    self.webView.goForward()
                }
                
            }
        }
    }
    @IBOutlet weak var refreshItem: TPCSystemButton! {
        didSet {
            refreshItem.animationCompletion = { [unowned self] (inout enable: Bool) in
                self.webView.reload()
            }
        }
    }
    @IBOutlet weak var closeItem: TPCSystemButton! {
        didSet {
            closeItem.animationCompletion = { [unowned self] (inout enable: Bool) in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    @IBOutlet weak var shareItem: TPCSystemButton! {
        didSet {
            shareItem.animationCompletion = { [unowned self] (inout enable: Bool) in
                debugPrint("分享")
                var shareText = self.navigationItem.title ?? "" + " "
                if let urlString = self.webView.URL?.absoluteString {
                    shareText += urlString
                }
                TPCShareView.showWithTitle(self.technical?.desc, desc: self.technical?.desc, mediaURL: self.webView.URL)
            }
        }
    }
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多", action: { [unowned self] (enable) -> () in
            self.more()
        })
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

extension TPCBroswerViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.progress = 0
        lastEstimatedProgress = 0
        debugPrint(#function, navigation)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        navigationItem.title = webView.title
        forwardItem.enable = webView.canGoForward
        backItem.enable = webView.canGoBack
        
        debugPrint(webView.title)
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

