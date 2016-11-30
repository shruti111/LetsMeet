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
    
    convenience init(attributes:[AnyHashable: Any]) {
        self.init()
        self.setValuesForKeys(attributes as! [String : Any])
    }
    
  required init(coder aDecoder: NSCoder) {
        recordId = aDecoder.decodeInteger(forKey: "RecordId")
        firstName = aDecoder.decodeObject(forKey: "FirstName") as? String
        lastName = aDecoder.decodeObject(forKey: "LastName") as? String
        email = aDecoder.decodeObject(forKey: "Email") as? String
        emailLabel = aDecoder.decodeObject(forKey: "EmailLabel") as? String
        selected = aDecoder.decodeBool(forKey: "Selected")
        cloudRecordId = aDecoder.decodeObject(forKey: "CloudRecordId") as? String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        if recordId != nil {
        aCoder.encode(recordId!, forKey: "RecordId")
        }
        aCoder.encode(firstName, forKey: "FirstName")
        aCoder.encode(lastName, forKey: "LastName")
        aCoder.encode(email, forKey: "Email")
        aCoder.encode(emailLabel, forKey: "EmailLabel")
        if selected != nil {
        aCoder.encode(selected!, forKey: "Selected")
        }
        aCoder.encode(cloudRecordId, forKey: "CloudRecordId")
    }
    
    //MARK:-  NSKeyValueCoding Protocol
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "id"  {
            self.recordId = (value! as AnyObject).intValue
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
    override func copy() -> Any {
        let copy = Contact()
        copy.recordId = self.recordId
        copy.firstName = self.firstName
        copy.lastName = self.lastName
        return copy
    }
    
   }
