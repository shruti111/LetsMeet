//
//  DimmingPresentationViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 22/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

// This is as per ray Wenderlich tutorial for Animation
// When ViewController is presented, it will show Alpha with animation from 0 to 1 to give the Dimming Effect

class DimmingPresentationViewController: UIPresentationController {

    lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView.bounds
        
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        // Set alpha 0 initially
        
        dimmingView.alpha = 0
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
               
                // In Animation, set its Alpha 1
                self.dimmingView.alpha = 1
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 0
                }, completion: nil)
        }
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
