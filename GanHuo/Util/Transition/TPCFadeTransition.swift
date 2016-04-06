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
    func snapShotForTransition() -> UIView!
}

protocol NTWaterFallViewControllerProtocol : NTTransitionProtocol{
    func viewWillAppearWithPageIndex(pageIndex : NSInteger)
}

protocol NTHorizontalPageViewControllerProtocol : NTTransitionProtocol{
    func pageViewCellScrollViewContentOffset() -> CGPoint
}

class TPCCollectionToPageZoomTransition: TPCTransitionProtocol {
    init(duration: NSTimeInterval = 1, zoomScale: CGFloat = 0.25) {
        self.animationDuration = duration
        self.zoomScale = zoomScale
    }
    internal var animationDuration: NSTimeInterval
    private var zoomScale: CGFloat
    
    func isSatisfyRequirementByFromVc(fromVc: UIViewController, toVc: UIViewController, operation: UINavigationControllerOperation) -> Bool {
        
        let fromVCConfromA = (fromVc as? NTTransitionProtocol)
        let fromVCConfromB = (fromVc as? NTWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVc as? NTHorizontalPageViewControllerProtocol)
        
        let toVCConfromA = (toVc as? NTTransitionProtocol)
        let toVCConfromB = (toVc as? NTWaterFallViewControllerProtocol)
        let toVCConfromC = (toVc as? NTHorizontalPageViewControllerProtocol)
        return ((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
        (fromVCConfromB != nil && toVCConfromC != nil) || (fromVCConfromC != nil && toVCConfromB != nil)))
    }
    
    func popTransitionFromVc(fromVc: UIViewController, toVc: UIViewController, containerView: UIView, completion: (() -> Void)) {
        let toView = toVc.view!
        containerView.addSubview(toView)
        toView.hidden = true
        let waterFallView = (toVc as! NTTransitionProtocol).transitionCollectionView()
        let pageView = (fromVc as! NTTransitionProtocol).transitionCollectionView()
                    waterFallView.layoutIfNeeded()
        let indexPath = pageView.fromPageIndexPath()
        let gridView = waterFallView.cellForItemAtIndexPath(indexPath)
        let leftUpperPoint = gridView!.convertPoint(CGPointZero, toView: toVc.view)
        
        let snapShot = (gridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
        snapShot.transform = CGAffineTransformMakeScale(zoomScale, zoomScale)
        let pullOffsetY = (fromVc as! NTHorizontalPageViewControllerProtocol).pageViewCellScrollViewContentOffset().y
        let offsetY : CGFloat = fromVc.navigationController!.navigationBarHidden ? 0.0 : TPCNavigationBarAndStatusBarHeight
        snapShot.origin(CGPointMake(0, -pullOffsetY+offsetY))
        containerView.addSubview(snapShot)
        toView.hidden = false
        toView.alpha = 0
        toView.transform = snapShot.transform
        toView.frame = CGRectMake(-(leftUpperPoint.x * zoomScale),-((leftUpperPoint.y-offsetY) * zoomScale+pullOffsetY+offsetY),
                                  toView.frame.size.width, toView.frame.size.height)
        let whiteViewContainer = UIView(frame: UIScreen.mainScreen().bounds)
        whiteViewContainer.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(snapShot)
        containerView.insertSubview(whiteViewContainer, belowSubview: toView)
        
        UIView.animateWithDuration(animationDuration, animations: {
            snapShot.transform = CGAffineTransformIdentity
            snapShot.frame = CGRectMake(leftUpperPoint.x, leftUpperPoint.y, snapShot.frame.size.width, snapShot.frame.size.height)
            toView.transform = CGAffineTransformIdentity
            toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height);
            toView.alpha = 1
            }, completion:{finished in
                if finished {
                    snapShot.removeFromSuperview()
                    whiteViewContainer.removeFromSuperview()
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
        
        let leftUpperPoint = gridView!.convertPoint(CGPointZero, toView: nil)
        pageView.hidden = true
        pageView.scrollToItemAtIndexPath(indexPath, atScrollPosition:.CenteredHorizontally, animated: false)
        
        let offsetY : CGFloat = fromVc.navigationController!.navigationBarHidden ? 0.0 : TPCNavigationBarAndStatusBarHeight
        let offsetStatuBar : CGFloat = toVc.navigationController!.navigationBarHidden ? 0.0 :
        TPCStatusBarHeight;
        let snapShot = (gridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
        containerView.addSubview(snapShot)
        snapShot.origin(leftUpperPoint)
        UIView.animateWithDuration(animationDuration, animations: {
            snapShot.transform = CGAffineTransformMakeScale(self.zoomScale,
                self.zoomScale)
            snapShot.frame = CGRectMake(0, offsetY, snapShot.frame.size.width, snapShot.frame.size.height)
            
            fromView.alpha = 0
            fromView.transform = snapShot.transform
            fromView.frame = CGRectMake(-(leftUpperPoint.x)*self.zoomScale,
                -(leftUpperPoint.y-offsetStatuBar)*self.zoomScale+offsetStatuBar,
                fromView.frame.size.width,
                fromView.frame.size.height)
            },completion:{finished in
                if finished {
                    snapShot.removeFromSuperview()
                    pageView.hidden = false
                    fromView.transform = CGAffineTransformIdentity
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
