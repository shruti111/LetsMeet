//
//  AddressBookClient.swift
//  LetsMeet
//
//  Created by Shruti on 17/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import AddressBook

// This class retrieves the user's contact which  1.  Have installed LetsMeet Application 2. Have iCloud Account

// As per CloudKit, we will get the user's contact information which confirm to the above rules

class AddressBookClient: NSObject {
 
     var addressBook:ABAddressBook?
     var addressBookContactsHavingEmailAddresses = [Contact]()
     var  contacts = [Contact]()
     var contactsRetrieved:Bool = false
    
    // Notification when we have fetched user's contacts from CloudKit and Addressbook
    let CONTACTSADDEDNOTIFICATION  = "contactsFromiCloudAdded"
    
    override init() {
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> AddressBookClient {
        
        struct Singleton {
            static var sharedInstance = AddressBookClient()
        }
        return Singleton.sharedInstance
    }

    func getAddressbookContacts() {
        
        // make sure user hadn't previously denied access
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .denied || status == .restricted {
            return
        }
        
        // Open it
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if addressBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        
        // request permission to use it
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            
            if !granted {
                return
            }
            
            if let people = ABAddressBookCopyArrayOfAllPeople(self.addressBook!)?.takeRetainedValue() as? NSArray {
                self.getEmailAddressFromContacts(people)
            }
        }
    }
    
    func getEmailAddressFromContacts(_ allPeople:NSArray) {
        
        let nPeople:CFIndex = ABAddressBookGetPersonCount(addressBook!)
        
        for ref1 in allPeople{
            let ref = ref1 as ABRecord

            //For Email ids
            var eMail: ABMutableMultiValue  = ABRecordCopyValue(ref, kABPersonEmailProperty).takeRetainedValue() as ABMutableMultiValue
            
            if(ABMultiValueGetCount(eMail) > 0) {
                
                var contact:Contact = Contact()
                
                //Get contactId
                contact.recordId = Int(ABRecordGetRecordID(ref))
                
                //For username and surname
                contact.firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
                contact.lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty)?.takeRetainedValue() as? String
                for idx:CFIndex in 0 ..< ABMultiValueGetCount(eMail) {
                //for(var idx:CFIndex = 0; idx < ABMultiValueGetCount(eMail); idx = idx + 1) {
                    
                    let emailTypeString = ABMultiValueCopyLabelAtIndex(eMail, idx)?.takeRetainedValue() as? String //Work,home
                    //print(emailTypeString)
                    let emailconvertedtypeString = ABAddressBookCopyLocalizedLabel(emailTypeString as CFString!)?.takeRetainedValue() as? String
                    //print(emailconvertedtypeString)
                    let emailString = ABMultiValueCopyValueAtIndex(eMail, idx)?.takeRetainedValue() as? String // sss@ss.com
                    
                    if contact.emailLabel != nil {
                        if emailconvertedtypeString != nil && emailString != nil {
                            let newContactForNewEmailType: Contact = contact.copy() as! Contact
                            newContactForNewEmailType.emailLabel = emailconvertedtypeString!
                            newContactForNewEmailType.email = emailString!
                            self.addressBookContactsHavingEmailAddresses.append(newContactForNewEmailType)
                        }
                        
                    } else {
                        // The first email object
                        if emailconvertedtypeString != nil && emailString != nil {
                            contact.emailLabel = emailconvertedtypeString!
                            contact.email = emailString!
                            self.addressBookContactsHavingEmailAddresses.append(contact)
                        }
                    }
                    
                }
                
            }
        }
        
        // Filter users with Cloudkit contacts
        
        var totalContactsCount = 0
        
        print("addressBookContactsHavingEmailAddresses : \(self.addressBookContactsHavingEmailAddresses.count)")
        
        for emailContact in self.addressBookContactsHavingEmailAddresses {
            CloudClient.sharedInstance().userInfoEmail(emailContact.email!, completion: {
                userInfo, error in
                
                if userInfo != nil && error == nil {
                    print(userInfo)
                    emailContact.cloudRecordId = userInfo!.userRecordID?.recordName
                    self.contacts.append(emailContact)
                    print(userInfo!.userRecordID?.recordName)
                }
                
                totalContactsCount = totalContactsCount + 1
                
                if totalContactsCount == self.addressBookContactsHavingEmailAddresses.count {
                    self.contactsRetrieved = true
                    print("contactsRetrieved \(self.contactsRetrieved)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.CONTACTSADDEDNOTIFICATION), object: self.contactsRetrieved)
                }
            })
        }
      
        
       
        
        
     }
}
