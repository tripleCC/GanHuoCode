//
//  TPCFadeTransition.swift
//  TPCTransition
//
//  Created by tripleCC on 16/4/5.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

protocol NTTransitionProtocol{
    func transitionCollectionView() -> UICollectionView!
}

protocol NTTansitionWaterfallGridViewProtocol{
    func snapShotForTransition() -> UIImageView!
}

protocol NTHorizontalPageViewControllerProtocol : NTTransitionProtocol{
    func pageViewCellScrollViewContentOffset() -> CGPoint
}

class TPCCollectionToPageZoomTransition: TPCTransitionProtocol {
    init(duration: NSTimeInterval = 1) {
        self.animationDuration = duration
    }
    internal var animationDuration: NSTimeInterval
    
    func isSatisfyRequirementByFromVc(fromVc: UIViewController, toVc: UIViewController, operation: UINavigationControllerOperation) -> Bool {
        
        let fromVCConfromA = (fromVc as? NTTransitionProtocol)
        let fromVCConfromC = (fromVc as? NTHorizontalPageViewControllerProtocol)
        
        let toVCConfromA = (toVc as? NTTransitionProtocol)
        let toVCConfromC = (toVc as? NTHorizontalPageViewControllerProtocol)
        return ((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
        (toVCConfromC != nil) || (fromVCConfromC != nil)))
    }
    
    func popTransitionFromVc(fromVc: UIViewController, toVc: UIViewController, containerView: UIView, completion: (() -> Void)) {
        let toView = toVc.view!
        containerView.addSubview(toView)
        let waterFallView = (toVc as! NTTransitionProtocol).transitionCollectionView()
        let pageView = (fromVc as! NTTransitionProtocol).transitionCollectionView()
        let indexPath = pageView.fromPageIndexPath()
        
        var waterGridView = waterFallView.cellForItemAtIndexPath(indexPath)
        if waterGridView == nil {
            waterFallView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
            waterFallView.layoutIfNeeded()
            waterGridView = waterFallView.cellForItemAtIndexPath(indexPath)
        }
        toView.hidden = true
        
        waterGridView?.hidden = true
        print(indexPath.item)
        
        var leftUpperPoint = CGPoint.zero
        if waterGridView != nil {
            leftUpperPoint = waterGridView!.convertPoint(CGPointZero, toView: toVc.view)
        }
        
        let pageGridView = pageView.cellForItemAtIndexPath(indexPath)
        let snapShot = (pageGridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
        let offsetY : CGFloat = fromVc.navigationController!.navigationBarHidden ? 0.0 : TPCNavigationBarAndStatusBarHeight
        
        if let imageSize = snapShot.image?.size {
            let snapShotH = (toView.frame.size.width / imageSize.width) * imageSize.height
            let y = (TPCScreenHeight + offsetY) * 0.5 - snapShotH * 0.5
            snapShot.frame = CGRect(x: 0, y: y, width: toView.frame.size.width, height: snapShotH)
        }
        
        containerView.addSubview(snapShot)
        toView.hidden = false
        toView.alpha = 0
        let whiteViewContainer = UIView(frame: UIScreen.mainScreen().bounds)
        whiteViewContainer.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(snapShot)
        containerView.insertSubview(whiteViewContainer, belowSubview: toView)
        
        let backgroundView = (fromVc as! TPCViewController).navigationBarBackgroundView
        containerView.addSubview(backgroundView)
        
        UIView.animateWithDuration(animationDuration, animations: {
            TPCRootViewController.tabBar.frame.origin.y = TPCScreenHeight - TPCTabBarHeight
            snapShot.frame = CGRectMake(leftUpperPoint.x, leftUpperPoint.y, TPCCollectionViewWaterflowLayout.defaultCellWidth, TPCCollectionViewWaterflowLayout.defaultCellWidth)
            toView.alpha = 1
            }, completion:{finished in
                if finished {
                    (fromVc as! TPCViewController).view.addSubview(backgroundView)
                    snapShot.removeFromSuperview()
                    whiteViewContainer.removeFromSuperview()
                    waterGridView?.hidden = false
                    completion()
                }
        })
    }
    
    func pushTransitionFromVc(fromVc: UIViewController, toVc: UIViewController, containerView: UIView, completion: (() -> Void)) {
        let fromView = fromVc.view
        let toView = toVc.view
        
        let waterFallView : UICollectionView = (fromVc as! NTTransitionProtocol).transitionCollectionView()
        let pageView : UICollectionView = (toVc as! NTTransitionProtocol).transitionCollectionView()
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        let indexPath = waterFallView.toIndexPath()
        let gridView = waterFallView.cellForItemAtIndexPath(indexPath)
        gridView?.hidden = true
        
        let leftUpperPoint = gridView!.convertPoint(CGPointZero, toView: nil)
        pageView.hidden = true
        pageView.scrollToItemAtIndexPath(indexPath, atScrollPosition:.CenteredHorizontally, animated: false)
        
        let offsetY : CGFloat = fromVc.navigationController!.navigationBarHidden ? 0.0 : TPCNavigationBarAndStatusBarHeight
        let snapShot = (gridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
        containerView.addSubview(snapShot)
        
        
        let backgroundView = (fromVc as! TPCViewController).navigationBarBackgroundView
        containerView.addSubview(backgroundView)
        
        snapShot.frame.origin = leftUpperPoint
        
        UIView.animateWithDuration(animationDuration, animations: {
            TPCRootViewController.tabBar.frame.origin.y = TPCScreenHeight + TPCTabBarHeight
            if let imageSize = snapShot.image?.size {
                if imageSize.width != 0 {
                    let snapShotH = (fromView.frame.size.width / imageSize.width) * imageSize.height
                    let snapShotY = (TPCScreenHeight + offsetY) * 0.5 - snapShotH * 0.5
                    snapShot.frame = CGRect(x: 0, y: snapShotY, width: fromView.frame.size.width, height: snapShotH)                    
                }
            }
            
            fromView.alpha = 0
            },completion:{finished in
                if finished {
                    (fromVc as! TPCViewController).view.addSubview(backgroundView)
                    snapShot.removeFromSuperview()
                    pageView.hidden = false
                    gridView?.hidden = false
                    completion()
                }
        })
    }
}

//protocol TPCGridZoomTransitionProtocol {
//    var girdContainerView: UICollectionView {get}
//    var navigationOffsetY: CGFloat {get}
//    var statusOffsetY: CGFloat {get}
//}
//
//extension TPCGridZoomTransitionProtocol {
//    var navigationOffsetY: CGFloat {
//        return 44 + statusOffsetY
//    }
//    
//    var statusOffsetY: CGFloat {
//        let instance = UIApplication.sharedApplication()
//        return instance.statusBarHidden == true ? 0 : instance.statusBarFrame.height
//    }
//}
