//
//  Contact.swift
//  LetsMeet
//
//  Created by Shruti  on 01/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

//Contact data model object
class Contact:NSObject, NSCoding {
    
    var recordId:Int?
    var firstName:String?
    var lastName: String?
    var email:String?
    var emailLabel:String?
    var  selected:Bool?
    var cloudRecordId:String?
   
    override init() {
        super.init()
    }
    
    convenience init(attributes:[NSObject : AnyObject]) {
        self.init()
        self.setValuesForKeysWithDictionary(attributes)
    }
    
  required init(coder aDecoder: NSCoder) {
        recordId = aDecoder.decodeIntegerForKey("RecordId")
        firstName = aDecoder.decodeObjectForKey("FirstName") as? String
        lastName = aDecoder.decodeObjectForKey("LastName") as? String
        email = aDecoder.decodeObjectForKey("Email") as? String
        emailLabel = aDecoder.decodeObjectForKey("EmailLabel") as? String
        selected = aDecoder.decodeBoolForKey("Selected")
        cloudRecordId = aDecoder.decodeObjectForKey("CloudRecordId") as? String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        if recordId != nil {
        aCoder.encodeInteger(recordId!, forKey: "RecordId")
        }
        aCoder.encodeObject(firstName, forKey: "FirstName")
        aCoder.encodeObject(lastName, forKey: "LastName")
        aCoder.encodeObject(email, forKey: "Email")
        aCoder.encodeObject(emailLabel, forKey: "EmailLabel")
        if selected != nil {
        aCoder.encodeBool(selected!, forKey: "Selected")
        }
        aCoder.encodeObject(cloudRecordId, forKey: "CloudRecordId")
    }
    
    //MARK:-  NSKeyValueCoding Protocol
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "id"  {
            self.recordId = value!.integerValue
        } else if key == "firstName"  {
            self.firstName = value as? String
        } else if key == "lastName"  {
            self.lastName = value as? String
        } else if key == "email" {
            self.email = value as? String
        }else if key == "emailLabel"  {
            self.emailLabel = value as? String
        }else if key == "isSelected" {
            self.selected = value as? Bool
        }else if key == "cloudRecordId" {
            self.cloudRecordId = value as? String
        }
    }
   
    var fullName:String {
        if self.firstName != nil && self.lastName != nil {
            return "\(self.firstName!) \(self.lastName!)"
        } else if self.firstName != nil {
            return self.firstName!
        } else if self.lastName != nil {
            return self.lastName!
        } else {
            return ""
        }
    }
    
    // Copy contact when we have multiple email addresses
    override func copy() -> AnyObject {
        var copy = Contact()
        copy.recordId = self.recordId
        copy.firstName = self.firstName
        copy.lastName = self.lastName
        return copy
    }
    
   }
