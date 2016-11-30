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
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let point = CGPoint(x: x, y : y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: point, startRadius: 0, endCenter: point, endRadius: radius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
//        context.drawRadialGradient(gradient, startCenter: point, startRadius: 0, endCenter: point, endRadius: radius, options: CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
    }


}
