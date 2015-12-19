//
//  TPCViewController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

enum TPCNavigationBarType {
    case Line
    case GradientView
}

class TPCViewController: UIViewController {
    var navigationBarFrame: CGRect? {
        get {
            return self.navigationController?.navigationBar.frame
        }
        set {
            self.navigationController?.navigationBar.frame = newValue!
            let navigationBarBackgroundViewY = newValue!.origin.y < 0 ? newValue!.origin.y : 0
            self.navigationBarBackgroundView.frame = CGRect(x: 0, y: navigationBarBackgroundViewY, width: newValue!.width, height: TPCNavigationBarHeight + TPCStatusBarHeight)
        }
    }
    var navigationBarType: TPCNavigationBarType = .GradientView {
        didSet {
            switch navigationBarType {
                case .Line:
                    self.bottomLine.hidden = false
                    self.bottomView.hidden = true
                case .GradientView:
                    self.bottomLine.hidden = true
                    self.bottomView.hidden = false
            }
        }
    }
    
    private var bottomLine: CALayer!
    private var bottomView: TPCGradientView!
    
    
    lazy var navigationBarBackgroundView: UIView = {
        let navigationBarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: TPCScreenWidth, height: TPCNavigationBarHeight + TPCStatusBarHeight))
        navigationBarBackgroundView.backgroundColor = TPCConfiguration.navigationBarBackgroundColor
        return navigationBarBackgroundView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(navigationBarBackgroundView)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: navigationBarBackgroundView.bounds.height - 0.5, width: TPCScreenWidth, height: 0.5)
        bottomLine.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        navigationBarBackgroundView.layer.addSublayer(bottomLine)
        bottomLine.hidden = true
        
        bottomView = TPCGradientView(frame:CGRect(x: 0, y: TPCNavigationBarHeight + TPCStatusBarHeight, width: TPCScreenWidth, height: TPCConfiguration.technicalTableViewTopBottomMargin * 2))
        bottomView.toColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        bottomView.fromColor = UIColor.whiteColor()
        bottomView.opacity = 1
        navigationBarBackgroundView.addSubview(bottomView)
    }
    
    deinit {
        debugPrint("\(self) 被释放了")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(navigationBarBackgroundView)
        self.navigationBarFrame!.origin.y = TPCStatusBarHeight
        if navigationItem.title != nil {
            TPCUMManager.beginLogPageView(navigationItem.title!)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationItem.title != nil {
            TPCUMManager.endLogPageView(navigationItem.title!)
        }
    }
    
    func adjustBarPositionByVelocity(velocity: CGFloat, contentOffsetY: CGFloat, animated: Bool = true) {
        guard let _ = view.window else { return }
        var descY = navigationBarFrame!.origin.y
        if velocity > 1.0 {
//            debugPrint("隐藏")
            descY = -TPCNavigationBarHeight
        } else if velocity < -1.0 {
//            debugPrint("显示")
            descY = TPCStatusBarHeight
        } else {
            if contentOffsetY <= TPCNavigationBarHeight * 2 + TPCStatusBarHeight {
//                debugPrint("显示")
                descY = TPCStatusBarHeight
            }
        }
        if descY != navigationBarFrame!.origin.y {
            if animated {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.navigationBarFrame!.origin.y = descY
                })
            } else {
                self.navigationBarFrame!.origin.y = descY
            }
        }
    }
    
    func adjustBarToOriginPosition(animated: Bool = true) {
        adjustBarPositionByVelocity(-2.0, contentOffsetY: 0, animated: animated)
    }
    
    func adjustBarToHidenPosition(animated: Bool = true) {
        adjustBarPositionByVelocity(2.0, contentOffsetY: 0, animated: animated)
    }
}

typealias TPCNotificationManager = TPCViewController
extension TPCNotificationManager {
    func registerObserverForApplicationDidEnterBackground() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func registerReloadTableView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView", name: TPCTechnicalReloadDataNotification, object: nil)
    }
    
    func postReloadTableView() {
        NSNotificationCenter.defaultCenter().postNotificationName(TPCTechnicalReloadDataNotification, object: nil)
    }
    
    func reloadTableView() { }
    
    func removeObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        print(__FUNCTION__, self)
        adjustBarToOriginPosition(false)
    }
}