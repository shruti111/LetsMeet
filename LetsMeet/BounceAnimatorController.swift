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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // This animation is performed on the ViewController which is shown modally
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                
                toView.frame = transitionContext.finalFrame(for: toViewController)
                
                let containerView = transitionContext.containerView
                containerView.addSubview(toView)
                
                toView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                
                UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .calculationModeCubic, animations: {
                    
                    // Change the size of the view controller from 80% to 100% with 0.5 sec of Time Duration
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    })

                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
                    
                    }, completion: { finished in
                        transitionContext.completeTransition(finished)
                })
            }
        }
    }
}
