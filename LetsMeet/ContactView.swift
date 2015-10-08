//
//  ContactView.swift
//  LetsMeet
//
//  Created by Shruti  on 17/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

protocol ContactViewDelegate : NSObjectProtocol {
    func contactViewSelected(contactView: ContactView)
    func contactViewWasUnselected(contactView: ContactView)
    func contactViewShouldBeRemoved(contactView: ContactView)
}

class ContactView: UIView , UITextViewDelegate, UITextInputTraits, ContactTextFieldDelegate {

    //MARK:- All constants
    
    let kHorizontalPadding:CGFloat = 3
    let kVerticalPadding:CGFloat = 2
    
    let kDefaultBorderWidth = 1
    let kDefaultCornerRadiusFactor = 5
    
    let kColorSelectedText = UIColor.whiteColor()
    let kColorSelectedGradientTop = UIColor(red: 79.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let kColorSelectedGradientBottom = UIColor(red: 73.0/255.0, green: 58.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    let kColorSelectedBorder = UIColor(red: 56.0/255.0, green: 0.0/255.0, blue: 233.0/255.0, alpha: 1.0)

    
    let k7DefaultBorderWidth:CGFloat = 0
    let k7DefaultCornerRadiusFactor: CGFloat = 5
    
    let k7ColorText = applicationThemeColor()
    var  k7ColorGradientTop: UIColor?  = nil
    var k7ColorGradientBottom: UIColor? =  nil
    var  k7ColorBorder: UIColor? = nil
    
    let k7ColorSelectedText = UIColor.whiteColor()
    let k7ColorSelectedGradientTop = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    let k7ColorSelectedGradientBottom = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    let k7ColorSelectedBorder: UIColor? =  nil
    
    //MARK:- Properties
    var  name:String?
    var label:UILabel?
    var textField:ContactTextField? // used to capture keyboard touches when view is selected
    var  isSelected =  false
    var  showComma = true
    var  maxWidth:CGFloat = 0
    var  minWidth:CGFloat = 0
    weak var delegate:ContactViewDelegate?
    var  gradientLayer:CAGradientLayer?
    
    var  style:ContactBubbleStyle?
    var  selectedStyle:ContactBubbleStyle?
    

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     init(name: String, style: ContactBubbleStyle?, selectedStyle: ContactBubbleStyle?, showComma: Bool) {
        
        super.init(frame: CGRectZero)
        
        self.name = name
        self.isSelected = false
        self.showComma = showComma
        self.style = style
        self.selectedStyle = selectedStyle
        
        //Default styles
        if self.style == nil {
            self.style = ContactBubbleStyle(textColor: k7ColorText, gradientTop: k7ColorGradientTop, gradientBottom: k7ColorGradientBottom, borderColor: k7ColorBorder, borderWidth: k7DefaultBorderWidth, cornerRadiusFactor: k7DefaultCornerRadiusFactor)
        }
        
        if  self.selectedStyle == nil {
           self.selectedStyle = ContactBubbleStyle(textColor: k7ColorSelectedText, gradientTop: k7ColorSelectedGradientTop, gradientBottom: k7ColorSelectedGradientBottom, borderColor: k7ColorSelectedBorder, borderWidth: k7DefaultBorderWidth, cornerRadiusFactor: k7DefaultCornerRadiusFactor)
        }
        
        setupView()
        
    }
    
     convenience init(name: String, style: ContactBubbleStyle?, selectedStyle: ContactBubbleStyle?) {
       self.init(name: name, style: style, selectedStyle: selectedStyle, showComma: false)
    }
    
     convenience init(name: String) {
         self.init(name: name, style: nil, selectedStyle: nil)
    }
    
    
    func setupView() {
        // Create a new label
        label = UILabel()
        label!.backgroundColor = UIColor.clearColor()
        if showComma {
            label!.text =   name! + ","

        } else {
           label!.text = name!
        }
        addSubview(label!)
        
        // Create a new textField
        textField = ContactTextField()
        textField!.autocorrectionType = UITextAutocorrectionType.No
        textField!.contactTextFieldDelegate = self
        textField!.hidden = true
        addSubview(textField!)
        
        
        // Create a tapgesture
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
        
        maxWidth = 2 * kHorizontalPadding
        minWidth =  2 * kVerticalPadding
        
        self.adjustSize()
        self.unSelect()
    }
    
    func adjustSize() {
        
        // Adjust the label frames
        
        label!.sizeToFit()
        
        var frame = label!.frame
        frame.origin.x = kHorizontalPadding
        frame.origin.y = kVerticalPadding
        
        let newmaxWidth = maxWidth -  2 * kHorizontalPadding
        let newminWidth = minWidth -  2 * kHorizontalPadding
        
        if newminWidth < newmaxWidth {
            if frame.size.width < newminWidth {
                frame.size.width = newminWidth
            }else{
                if frame.size.width > newmaxWidth  {
                    frame.size.width = newmaxWidth
                }
            }
        }
        
        label!.frame = frame
        
        //Adjust view frame
        bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding, frame.size.height + 2 * kVerticalPadding)
        
        // Create gradient layer
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            layer.insertSublayer(gradientLayer!, atIndex: 0)
            
        }
        gradientLayer!.frame = self.bounds
        
        //Round the coreners
        let viewLayer:CALayer = self.layer
        viewLayer.masksToBounds = true
    }
    
    var font:UIFont {
        set {
            label!.font = newValue
            adjustSize()
        }
        
        get {
            return label!.font
        }
    }
    
    
    func select() {
        self.delegate?.contactViewSelected(self)
        
        let viewLayer:CALayer = self.layer
        
        if self.selectedStyle!.borderColor != nil {
        viewLayer.borderColor = self.selectedStyle!.borderColor!.CGColor
        }
        
        if self.selectedStyle!.gradientTop != nil && self.selectedStyle!.gradientTop != nil {
        gradientLayer!.colors = [self.selectedStyle!.gradientTop!.CGColor,self.selectedStyle!.gradientBottom!.CGColor]
        }
        
        label!.textColor = self.selectedStyle!.textColor
        self.layer.borderWidth = self.selectedStyle!.borderWidth
        
        if self.selectedStyle!.cornerRadiusFactor > 0  {
            self.layer.cornerRadius = self.bounds.size.height / self.selectedStyle!.cornerRadiusFactor
        } else {
            self.layer.cornerRadius = 0
        }
        
        isSelected = true
        textField!.becomeFirstResponder()
    }
    
    func unSelect() {
        
         self.delegate?.contactViewWasUnselected(self)
        
        let viewLayer:CALayer = self.layer
        
        if self.style!.borderColor != nil {
            viewLayer.borderColor = self.style!.borderColor!.CGColor
        }
        
        if self.style!.gradientTop != nil && self.style!.gradientBottom != nil {
            gradientLayer!.colors = [self.style!.gradientTop!.CGColor,self.style!.gradientBottom!.CGColor]
        }
        
        label!.textColor = self.style!.textColor
        
        
        self.layer.borderWidth = self.style!.borderWidth
        
        if self.style!.cornerRadiusFactor > 0 {
            self.layer.cornerRadius = self.bounds.size.height / self.style!.cornerRadiusFactor
        }
        else {
            self.layer.cornerRadius = 0
        }
        
         self.setNeedsDisplay()
        self.isSelected = false

        self.textField!.resignFirstResponder()
    }
    
    func handleTapGesture() {
        if self.isSelected {
            self.unSelect()
        } else {
            self.select()
        }
    }

    
    //MARK:- UITextFieldDelegate
    
    func textFieldDidHitBackspaceWithEmptyText(textField: ContactTextField) {
        
        print("textFieldDidHitBackspaceWithEmptyText For ContactView")
       
        self.textField!.hidden = false
        
        // Capture "delete" key press when cell is empty
        self.delegate?.contactViewShouldBeRemoved(self)
        
    }
    
    func textFieldDidChange(textField: ContactTextField) {
        unSelect()
        self.delegate?.contactViewWasUnselected(self)
        self.textField!.text = nil
    }
    
    
    //MARK: - UITextinputTraits

     var keyboardAppearance:UIKeyboardAppearance {
        set {
            textField!.keyboardAppearance = newValue
        }
        
        get {
            return textField!.keyboardAppearance
        }        
       
    }
    
     var returnKeyType:UIReturnKeyType {
        set {
            textField!.returnKeyType = newValue
        }
        get {
            return textField!.returnKeyType
        }
    }
   
}
