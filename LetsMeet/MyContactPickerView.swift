//
//  MyContactPickerView.swift
//  LetsMeet
//
//  Created by Shruti  on 18/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit


protocol MyContactPickerDelegate : NSObjectProtocol {
    
    func contactPickerTextViewDidChange(textViewText:String)
    func contactPickerDidRemoveContact(contact:Contact)
    func contactPickerDidResize(contactView:MyContactPickerView)
    func contactPickerTextFieldShouldReturn(textField:UITextField) -> Bool
    
}

class MyContactPickerView: UIView, UITextViewDelegate, ContactViewDelegate,UIScrollViewDelegate, UITextInputTraits, ContactTextFieldDelegate {
   
    
    //MARK:- Constants
    
    let kVerticalViewPadding:CGFloat	=	5   // the amount of padding on top and bottom of the view
    let kHorizontalPadding:CGFloat		=	0   // the amount of padding to the left and right of each contact view
    let kHorizontalSidePadding:CGFloat	=	10  // the amount of padding on the left and right of the view
    let kVerticalPadding:CGFloat		=	2   // amount of padding above and below each contact view
    let kTextViewMinWidth:CGFloat		=	20  // minimum width of trailing text view
    let KMaxNumberOfLinesDefault =	4

    
    var selectedContactView: ContactView?
    weak var delegate:MyContactPickerDelegate?
    
    var limitToOne = false// only allow the ContactPicker to add one contact
    // amount of padding above and below each contact view
    var verticalPadding:CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    
    var  maxNumberOfLines:Int = 2	// maximum number of lines the view will display before scrolling
  //  var font:UIFont?
    
    private var shouldSelectTextView = false
    private var lineCount = 1
    private var frameOfLastView:CGRect?
    
    var scrollView:UIScrollView?
    var contacts = [Contact: ContactView]()   // Dictionary to store ContactViews for each contacts
    var contactKeys = [Contact]()  //// an ordered set of the keys placed in the contacts dictionary
    var placeholderLabel:UILabel?
    var promptLabel:UILabel?
    var lineHeight:CGFloat = 0
    var textField:ContactTextField?
    var contactViewStyle:ContactBubbleStyle?
    var contactViewSelectedStyle:ContactBubbleStyle?

  required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        verticalPadding = kVerticalViewPadding
        maxNumberOfLines = KMaxNumberOfLinesDefault
        
        // Create a contact view to determine the height of a line
        scrollView = UIScrollView(frame: self.bounds)
        scrollView!.scrollsToTop = false
        scrollView!.delegate = self
        scrollView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(scrollView!)
        
        // Add placeholder label
        placeholderLabel = UILabel()
        placeholderLabel!.textColor = UIColor.grayColor()
        placeholderLabel!.backgroundColor = UIColor.clearColor()
        scrollView!.addSubview(placeholderLabel!)
        
        promptLabel = UILabel()
        promptLabel!.backgroundColor = UIColor.clearColor()
        promptLabel!.text = nil
        promptLabel!.sizeToFit()
        scrollView!.addSubview(promptLabel!)
        
        // Create TextView
        textField = ContactTextField()
        textField!.contactTextFieldDelegate = self
        textField!.autocorrectionType = UITextAutocorrectionType.No
        
        backgroundColor = UIColor.whiteColor()
        
        // Create a tapgesture
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
        
        //default settings
        let contactView = ContactView(name: "")
        contactViewStyle = contactView.style
        contactViewSelectedStyle = contactView.selectedStyle
        self.font = contactView.label!.font

    }
    
    var font:UIFont {
        set {
            
            // Create a contact view to determine the height of a line
            let contactView:ContactView = ContactView(name: "Sample")
            contactView.font = newValue
           
            lineHeight = contactView.frame.size.height + 2 * kVerticalPadding
            
            textField!.font = newValue
            textField!.sizeToFit()
            
            promptLabel!.font = newValue
            placeholderLabel!.font = newValue
            updateLabelFrames()
            
            setNeedsLayout()
 
        }
        get {
            return textField!.font
            
        }
    }
    
    
    func setPromptLabelText(text:String) {
        promptLabel!.text = text
        updateLabelFrames()
        setNeedsLayout()
    }
    
    func setPromptLabelAttributedText(text:NSAttributedString) {
        promptLabel!.attributedText = text
        updateLabelFrames()
        setNeedsLayout()
    }
    
    func setPlaceholderLabelTextColor(color:UIColor) {
        placeholderLabel!.textColor = color
    }
    
    func setPlaceholderLabelText(text:String) {
        placeholderLabel!.text = text
        setNeedsLayout()
    }

    
    func setPromptLabelTextColor(color:UIColor) {
        promptLabel!.textColor = color
    }
    
    override var backgroundColor:UIColor? {
        didSet {
            scrollView!.backgroundColor = self.backgroundColor
            //return super.backgroundColor
        }
       
    }
    
    func addContact(contact:Contact) {
        
        if contains(contactKeys, contact) {
            println("Can not contain the same object twice to MycontactPicker view")
            return
        }
        
        
        if contactKeys.count == 1 && limitToOne {
            let toBeRemovedcontactView = contacts[contactKeys.first!]
            removeContactView(toBeRemovedcontactView!)
        }
        
        textField!.text = ""
        
        var contactView = ContactView(name: contact.fullName, style: contactViewStyle, selectedStyle:contactViewSelectedStyle , showComma: !limitToOne)
        
        contactView.maxWidth = self.frame.size.width - self.promptLabel!.frame.origin.x - 2 * kHorizontalPadding - 2 * kHorizontalSidePadding
        contactView.minWidth = kTextViewMinWidth + 2 * kHorizontalPadding
        contactView.keyboardAppearance = keyboardAppearance
        contactView.returnKeyType = self.returnKeyType
        contactView.delegate = self
        contactView.font = self.font
        
        contacts[contact] = contactView
        contactKeys.append(contact)
        
        if selectedContactView != nil {
            // if there is a selected contact, deselect it
            selectedContactView!.unSelect()
            selectedContactView = nil
            selectTextView()
        }
        
        // update the position of the contacts
        layoutContactViews()
        
        // update size of the scrollView
        UIView.animateWithDuration(0.2, animations: {
            self.layoutScrollView()
            }, completion: {
                finished in
                 // scroll to bottom
                self.shouldSelectTextView = self.isFirstResponder()
                self.scrollToBottomWithAnimation(true)
                 // after scroll animation [self selectTextView] will be called
        })
        
    }
    
    func selectTextView() {
        textField!.hidden = false
        textField!.becomeFirstResponder()
    }
    
    func removeAllContacts() {
        
        for (key,value) in contacts {
            value.removeFromSuperview()
        }
        
        contacts.removeAll(keepCapacity: false)
        contactKeys.removeAll(keepCapacity: false)
        setNeedsLayout()
        
        textField!.hidden = false
        textField!.text = ""
    }
    
    func removeContact(contactToBeRemoved:Contact) {
        removeContactByKey(contactToBeRemoved)
    }
    
    override func resignFirstResponder() -> Bool {
        if textField!.isFirstResponder() {
            textField!.resignFirstResponder()
        }
        return super.resignFirstResponder()
    }
    
    override func isFirstResponder() -> Bool {
        if textField!.isFirstResponder() {
            return true
        } else if selectedContactView != nil {
            return true
        }
        return false
    }
    
    func setContactViewStyle(style:ContactBubbleStyle, selectedStyle:ContactBubbleStyle) {
        contactViewStyle = style
        textField!.textColor = style.textColor
        contactViewSelectedStyle = selectedStyle
        
        for (key,value) in contacts {
            value.style = style
            value.selectedStyle = selectedStyle
            
            if value.isSelected {
                value.select()
            } else {
                value.unSelect()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField!.becomeFirstResponder()
    }
    
    func scrollToBottomWithAnimation(animated:Bool) {
        if (animated){
            let size = scrollView!.contentSize
            let frame = CGRectMake(0, size.height - scrollView!.frame.size.height, size.width, scrollView!.frame.size.height)
            scrollView!.scrollRectToVisible(frame, animated: animated)
        } else {
            // this block is here because scrollRectToVisible with animated NO causes crashes on when the user tries to delete many contacts really quickly
            var offset = scrollView!.contentOffset
            offset.y = scrollView!.contentSize.height - scrollView!.frame.size.height
            scrollView!.contentOffset = offset
        }
    }
    
    func removeContactView(contactView:ContactView) {
        var contactToBeRemoved = contactForContactView(contactView)
        
        if contactToBeRemoved == nil {
            return
        }
        
        delegate?.contactPickerDidRemoveContact(contactToBeRemoved!)
        removeContactByKey(contactToBeRemoved!)
        selectTextView()
        if selectedContactView === contactView {
            selectedContactView = nil
        }
    
    }
    
    
    func removeContactByKey(contactToBeRemoved:Contact) {
        
        //Remove contact view from view
        let contactViewToBeremoved = contacts[contactToBeRemoved]
        if  contactViewToBeremoved != nil {
            contactViewToBeremoved!.removeFromSuperview()
            
            //Remove contact from memory
            contacts.removeValueForKey(contactToBeRemoved)
            contactKeys =  contactKeys.filter({
                $0 != contactToBeRemoved
            })
            textField!.text = ""
            layoutContactViews()
        }
        
        // update size of the scrollView
        UIView.animateWithDuration(0.2, animations: {
            self.layoutScrollView()
            }, completion: {
                finished in
                // scroll to bottom
                self.shouldSelectTextView = self.isFirstResponder()
                self.scrollToBottomWithAnimation(true)
                // after scroll animation [self selectTextView] will be called
        })

    }
    
    func contactForContactView(contactView:ContactView) -> Contact? {
        for (key,value) in contacts {
            if value === contactView {
                return key
            }
        }
        return nil
    }
    
    func updateLabelFrames() {
    promptLabel!.sizeToFit()
    promptLabel!.frame = CGRectMake(kHorizontalSidePadding, verticalPadding, promptLabel!.frame.size.width, lineHeight)
    placeholderLabel!.frame = CGRectMake(firstLineXOffset() + 3, verticalPadding, self.frame.size.width, lineHeight)
    }
    
    func firstLineXOffset() -> CGFloat {
        if promptLabel != nil {
            if promptLabel!.text == nil {
               return kHorizontalSidePadding
            }
        }
        return promptLabel!.frame.origin.x + promptLabel!.frame.size.width + 1
    }
    
    func layoutContactViews() {
        
        frameOfLastView = CGRectNull
        lineCount = 0
        
        // Loop through contacts and position/add them to the view
        
        for contactKey in contactKeys {
            var contactView = contacts[contactKey]
            var contactViewFrame = contactView!.frame
            
            if  CGRectIsNull(frameOfLastView!) {
                // First contact view
                contactViewFrame.origin.x = firstLineXOffset()
                contactViewFrame.origin.y = kVerticalPadding + self.verticalPadding
            } else {
                // Check if contact view will fit on the current line
                var width = contactViewFrame.size.width + 2 * kHorizontalPadding
                if self.frame.size.width - kHorizontalSidePadding - frameOfLastView!.origin.x - frameOfLastView!.size.width - width >= 0 {
                   
                    // add to the same line
                    // Place contact view just after last contact view on the same line
                    contactViewFrame.origin.x = frameOfLastView!.origin.x + frameOfLastView!.size.width + kHorizontalPadding * 2
                    contactViewFrame.origin.y = frameOfLastView!.origin.y
                } else {
                    // No space on current line, jump to next line
                    lineCount++
                    contactViewFrame.origin.x = kHorizontalSidePadding
                    contactViewFrame.origin.y = (CGFloat(lineCount) * lineHeight) + kVerticalPadding + verticalPadding
                }
            }
            frameOfLastView = contactViewFrame
            contactView!.frame = contactViewFrame
            
            // Add contact view if it hasn't been added
            if contactView!.superview == nil {
                scrollView!.addSubview(contactView!)
            }
        }
        
        // Now add the textView after the contact views
        let minWidth = kTextViewMinWidth + 2 * kHorizontalPadding
        let textViewHeight = self.lineHeight - 2 * kVerticalPadding
        var textViewFrame = CGRectMake(0, 0, textField!.frame.size.width, textViewHeight)
        
        // Check if we can add the text field on the same line as the last contact view
        if (self.frame.size.width - kHorizontalSidePadding - frameOfLastView!.origin.x - frameOfLastView!.size.width - minWidth >= 0) {
            // add to the same line
            textViewFrame.origin.x = frameOfLastView!.origin.x + frameOfLastView!.size.width + kHorizontalPadding
            textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x
        } else {
            // place text view on the next line
            lineCount++
            
            textViewFrame.origin.x = kHorizontalSidePadding
            textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding
            
            if (contacts.count == 0){
                lineCount = 0;
                textViewFrame.origin.x = firstLineXOffset()
                textViewFrame.size.width = self.bounds.size.width - textViewFrame.origin.x
            }
        }
        
        textViewFrame.origin.y = CGFloat(lineCount) * lineHeight + kVerticalPadding + verticalPadding
        textField!.frame = textViewFrame
        
        // Add text view if it hasn't been added
        textField!.center = CGPointMake(textField!.center.x, CGFloat(lineCount) * lineHeight + textViewHeight / 2 + kVerticalPadding + verticalPadding)
        
        if (textField!.superview == nil){
            scrollView!.addSubview(textField!)
        }
        
        // Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
        if (limitToOne && contacts.count >= 1){
            textField!.hidden = true
            lineCount = 0
        }
        
        // Show placeholder if no there are no contacts
        if textField!.text ==  "" && contacts.count == 0 {
            placeholderLabel!.hidden = false
        } else {
            self.placeholderLabel!.hidden = true
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContactViews()
        layoutScrollView()
    }
    
    func layoutScrollView() {
        // Adjust scroll view content size
        var frame = self.bounds
        let maxFrameHeight = CGFloat(maxNumberOfLines) * lineHeight + 2 * verticalPadding // limit frame to two lines of content
        
        var newHeight = (CGFloat(lineCount) + 1) * lineHeight + 2 * verticalPadding
        
        scrollView!.contentSize = CGSizeMake(scrollView!.frame.size.width, newHeight)
    
        // Adjust frame of view if necessary
        newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight
        if self.frame.size.height != newHeight {
            // Adjust self height
            var selfFrame = self.frame
            selfFrame.size.height = newHeight
            self.frame = selfFrame
    
            // Adjust scroll view height
            frame.size.height = newHeight
            scrollView!.frame = frame
            delegate?.contactPickerDidResize(self)
       }
    }

    
    //MARK:- ContactTextFieldDelegate
    func textFieldDidHitBackspaceWithEmptyText(textField: ContactTextField) {
        
         println("textFieldDidHitBackspaceWithEmptyText For ContactPickerView")
        
        self.textField!.hidden = false
        
        if (contacts.count > 0) {
            // Capture "delete" key press when cell is empty
            selectedContactView = contacts[contactKeys.last!]
            selectedContactView!.select()
        } else {
            delegate?.contactPickerTextViewDidChange(textField.text)
        }
    }
    
    func textFieldDidChange(textField: ContactTextField) {
       
        if self.textField?.markedTextRange == nil {
            delegate?.contactPickerTextViewDidChange(textField.text)
        }
        
        if  textField.text ==  "" && contacts.count == 0 {
            placeholderLabel!.hidden = false
        } else {
            placeholderLabel!.hidden = true
        }
        
        var offset = scrollView!.contentOffset
        offset.y = scrollView!.contentSize.height - scrollView!.frame.size.height
        if offset.y > scrollView!.contentOffset.y {
            scrollToBottomWithAnimation(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let delegate = delegate {
         delegate.contactPickerTextFieldShouldReturn(textField)
        }
        
        return true
    }
    
    
    //MARK:- ContactViewDelegate 
    
    func contactViewSelected(contactView: ContactView) {
        if selectedContactView != nil {
            selectedContactView!.unSelect()
        }
        
        selectedContactView = contactView
        textField!.resignFirstResponder()
        textField!.text = ""
        textField!.hidden = true
    }
    
    func contactViewWasUnselected(contactView: ContactView) {
        if selectedContactView === contactView {
            selectedContactView = nil
        }
        
        selectTextView()
        // transfer the text fromt he textField within the ContactView if there was any
        // ***This is important if the user starts to type when a contact view is selected
        textField!.text = contactView.textField!.text
        
        // trigger textFieldDidChange if there is text in the textField
        if count(textField!.text) > 0 {
            self.textFieldDidChange(textField!)
        }
    }
    
    func contactViewShouldBeRemoved(contactView: ContactView) {
        removeContactView(contactView)
    }
    
    //MARK:- Gesture Recognizer
    
    func handleTapGesture() {
        if limitToOne && contactKeys.count == 1{
            return
        }
        scrollToBottomWithAnimation(true)
    
        // Show textField
        selectTextView()
    
        // Unselect contact view
        if selectedContactView != nil {
            selectedContactView!.unSelect()
            selectedContactView = nil
        }
    }
    
    //MARK:- UIScrollviewDelegate
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if shouldSelectTextView {
            shouldSelectTextView = false
            selectTextView()
        }
    }
    
    //MARK:- UITextInputTraits
    var keyboardAppearance:UIKeyboardAppearance {
        set {
            textField!.keyboardAppearance = newValue
            for (key,value) in contacts {
                value.keyboardAppearance = newValue
            }
        }
        
        get {
            return textField!.keyboardAppearance
        }
    }
    
    var returnKeyType:UIReturnKeyType {
        set {
            textField!.returnKeyType = newValue
            for (key,value) in contacts {
                value.returnKeyType = newValue
            }
        }
        get {
            return textField!.returnKeyType
        }
    }
    
    
}
