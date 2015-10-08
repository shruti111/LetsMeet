//
//  ContactBubbleStyle.swift
//  LetsMeet
//
//  Created by Shruti  on 17/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class ContactBubbleStyle: NSObject {
    
   // This is contact bubble of contact selected
    var  textColor: UIColor
    var  gradientTop: UIColor?
    var  gradientBottom: UIColor?
    var  borderColor: UIColor?
    var  borderWidth: CGFloat
    var  cornerRadiusFactor: CGFloat
    
    init(textColor: UIColor, gradientTop : UIColor?, gradientBottom: UIColor?, borderColor: UIColor?, borderWidth:CGFloat, cornerRadiusFactor:CGFloat ) {
        self.textColor = textColor
        self.gradientTop = gradientTop
        self.gradientBottom = gradientBottom
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadiusFactor = cornerRadiusFactor
    }
    
    
   
}
