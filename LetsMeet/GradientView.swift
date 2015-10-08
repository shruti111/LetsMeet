//
//  GradientView.swift
//  LetsMeet
//
//  Created by Shruti  on 22/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

// Gradient View which has color space from Grey to Black to give the effect in DimmingPresentationController
class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleWidth | .FlexibleHeight
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleWidth | .FlexibleHeight
    }
    
    override func drawRect(rect: CGRect) {
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
        
        let x = CGRectGetMidX(bounds)
        let y = CGRectGetMidY(bounds)
        let point = CGPoint(x: x, y : y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
    }


}
