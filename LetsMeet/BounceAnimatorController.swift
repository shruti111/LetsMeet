//
//  BounceAnimatorController.swift
//  LetsMeet
//
//  Created by Shruti  on 22/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit


// Bounce effect when View controller is Presented on screen Modally
class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // This animation is performed on the ViewController which is shown modally
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
                
                toView.frame = transitionContext.finalFrameForViewController(toViewController)
                
                let containerView = transitionContext.containerView()
                containerView.addSubview(toView)
                
                toView.transform = CGAffineTransformMakeScale(0.4, 0.4)
                
                UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CalculationModeCubic, animations: {
                    
                    // Change the size of the view controller from 80% to 100% with 0.5 sec of Time Duration
                    UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    })

                    UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    })
                    
                    }, completion: { finished in
                        transitionContext.completeTransition(finished)
                })
            }
        }
    }
}
