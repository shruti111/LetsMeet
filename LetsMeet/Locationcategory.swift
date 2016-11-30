//
//  Locationcategory.swift
//  LetsMeet
//
//  Created by Shruti  on 28/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import CoreData

class Locationcategory : NSManagedObject {
    
    // Core data object attributes
    @NSManaged var categoryId: String
    @NSManaged var categoryName: String
    @NSManaged var iconLink: String
    @NSManaged var parentId:String
    
    // As per Foursquare, icon size is selected
    let iconSize: String = "64"
    var chidLocationCategory:Locationcategory?
       
    // Keys to convert dictionary into object
    struct Keys {
        static let CategoryId = "id"
        static let CategoryName = "name"
        static let Icon = "icon"
        static let childLocationCategory = "categories"
    }
    
    // Init method to insert object in core data
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Init method that will convert  dictionary into managed object and insert in core data 
    
    init(dictionary:[String:AnyObject], context:NSManagedObjectContext) {
       
        let entity = NSEntityDescription.entity(forEntityName: "Locationcategory", in: context)!
        super.init(entity: entity, insertInto: context)
        
        categoryId = dictionary[Keys.CategoryId] as! String
        categoryName = dictionary[Keys.CategoryName] as! String
        let icon = dictionary[Keys.Icon] as! NSDictionary
        let prefix = icon["prefix"] as! String
        let suffix = icon["suffix"] as! String
        iconLink = prefix + iconSize + suffix
    
        if let dic = (dictionary[Keys.childLocationCategory] as? [[String:AnyObject]]) {
         
            var categories = dic.map() {
                (dictionary : [String:AnyObject]) -> Locationcategory in
                let newDictionary = dictionary
                
                let tempCategoryId = self.categoryId
                let categoryTobeAdded = Locationcategory(dictionary: newDictionary, context:context)
                categoryTobeAdded.parentId = tempCategoryId
                return categoryTobeAdded
            }
            
        }
    
    }

}
