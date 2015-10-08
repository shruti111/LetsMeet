//
//  MeetingsCoreDataStackManager.swift
//  LetsMeet
//
//  Created by Shruti Pawar on 05/09/15.
//  Copyright (c) 2015 ShapeMyApp Software Solutions Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreData

extension Client {
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func getFoursquareCatgegoriesAndSaveToCoreData() {
        
    }
}