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
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
  override  init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactTextField.textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Delete contact handle
    func keyboardInputShouldDelete(_ textField: UITextField) -> Bool {
       var shouldDelete = true
        print("ShouldDelete value is \(shouldDelete)")
        if (textField.text!.characters.count) == 0 {
            deleteBackward()
        }
       return shouldDelete
    }
    
    override func deleteBackward() -> Void {
       
        let  isTextFieldEmpty = (text?.characters.count) == 0
        
        if isTextFieldEmpty {
            if self.contactTextFieldDelegate != nil && self.contactTextFieldDelegate!.responds(to: Selector("textFieldDidHitBackspaceWithEmptyText:")) {
                print("Delete backward called for isTextFieldEmpty")
                self.contactTextFieldDelegate!.textFieldDidHitBackspaceWithEmptyText(self)
            }
        }
        print("Delete backward called")
        super.deleteBackward()
    }
    
    func textFieldTextDidChange(_ notification:Notification) {
        if (notification.object as! AnyObject ) === self  {
            //Since ContactView.textView is a ContactTextField
            if self.contactTextFieldDelegate != nil &&
                self.contactTextFieldDelegate!.responds(to: Selector("textFieldDidChange:")) {
                    self.contactTextFieldDelegate!.textFieldDidChange(self)
            }
        }
    }

}

protocol ContactTextFieldDelegate :UITextFieldDelegate {

func textFieldDidChange(_ textField:ContactTextField)
func textFieldDidHitBackspaceWithEmptyText(_ textField: ContactTextField)

}
