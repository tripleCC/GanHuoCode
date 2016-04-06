//
//  TPCtransition.swift
//  TPCTransition
//
//  Created by tripleCC on 16/4/5.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

protocol TPCTransitionProtocol {
    var animationDuration: NSTimeInterval {get}
    func isSatisfyRequirementByFromVc(fromVc: UIViewController, toVc: UIViewController, operation: UINavigationControllerOperation) -> Bool
    func pushTransitionFromVc(fromVc: UIViewController, toVc: UIViewController, containerView: UIView, completion: (() -> Void))
    func popTransitionFromVc(fromVc: UIViewController, toVc: UIViewController, containerView: UIView, completion: (() -> Void))
}

class TPCTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var transition: TPCTransitionProtocol = TPCCollectionToPageZoomTransition()
    var operation: UINavigationControllerOperation
    init(transition: TPCTransitionProtocol, operation: UINavigationControllerOperation = .Push) {
        self.transition = transition
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transition.animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) ,
            let containerView = transitionContext.containerView() {
            let comletion = {
                toVC.view.hidden = false
                transitionContext.completeTransition(true)
            }
            switch operation {
            case .Push:
                transition.pushTransitionFromVc(fromVC, toVc: toVC, containerView: containerView, completion: comletion)
            case .Pop:
                transition.popTransitionFromVc(fromVC, toVc: toVC, containerView: containerView, completion: comletion)
            default:
                comletion()
                break
            }
        } else {
            transitionContext.completeTransition(true)
        }
    }
}

extension TPCTransition: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard transition.isSatisfyRequirementByFromVc(fromVC, toVc: toVC, operation: operation) else { return nil }
        return TPCTransition(transition: transition, operation: operation)
    }
}
