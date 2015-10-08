//
//  ContactTextField.swift
//  LetsMeet
//
//  Created by Shruti  on 17/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class ContactTextField: UITextField {
    
    //Delegate is named with contacttextFieldDelegate
     weak var contactTextFieldDelegate:ContactTextFieldDelegate?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
  override  init(frame: CGRect) {
        super.init(frame: frame)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldTextDidChange:"), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Delete contact handle
    func keyboardInputShouldDelete(textField: UITextField) -> Bool {
       var shouldDelete = true
        println("ShouldDelete value is \(shouldDelete)")
        if count(textField.text) == 0 {
            deleteBackward()
        }
       return shouldDelete
    }
    
    override func deleteBackward() -> Void {
       
        let  isTextFieldEmpty = count(text) == 0
        
        if isTextFieldEmpty {
            if self.contactTextFieldDelegate != nil && self.contactTextFieldDelegate!.respondsToSelector(Selector("textFieldDidHitBackspaceWithEmptyText:")) {
                println("Delete backward called for isTextFieldEmpty")
                self.contactTextFieldDelegate!.textFieldDidHitBackspaceWithEmptyText(self)
            }
        }
        println("Delete backward called")
        super.deleteBackward()
    }
    
    func textFieldTextDidChange(notification:NSNotification) {
        if notification.object === self  {
            //Since ContactView.textView is a ContactTextField
            if self.contactTextFieldDelegate != nil &&
                self.contactTextFieldDelegate!.respondsToSelector(Selector("textFieldDidChange:")) {
                    self.contactTextFieldDelegate!.textFieldDidChange(self)
            }
        }
    }

}

protocol ContactTextFieldDelegate :UITextFieldDelegate {

func textFieldDidChange(textField:ContactTextField)
func textFieldDidHitBackspaceWithEmptyText(textField: ContactTextField)

}
