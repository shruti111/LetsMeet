//
//  CoreDataStackManager.swift
//  LetsMeet
//
//  Created by Shruti  on 28/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private let SQLITE_FILE_NAME = "LetsMeet.sqlite"

class CoreDataStackManager {
    
    //MARK:- SharedInstance
    class func sharedInstance()-> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        return Static.instance
    }
    
    //MARK:- The Core Data Stack
    
    // Documents Directory URL - the path the sqlite file
    lazy var applicationDocumentsDirectory:URL? = {
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
        if urls.count > 0 {
            if let url = urls[urls.count-1] as? URL {
                print(url)
                return url
            }
        }
        return nil
        }()
    
    // The managed object property for the application
    lazy var managedObjectModel: NSManagedObjectModel? = {
        
        if  let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") {
            if let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) {
                return managedObjectModel
            }
        }
        return nil
        }()
    
    //Persistent Store Coordinator - context uses this object to interact with underlying file system
    // It will use - the path to sqlite file and  a configured Managed Object Model
    
    lazy var pesistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = nil
        
        if let objectModel = self.managedObjectModel {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel )
            
            if let appURL = self.applicationDocumentsDirectory {
                
                let url = appURL.appendingPathComponent(SQLITE_FILE_NAME)
                do {
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                } catch {
                    print("unable to add store at \(url)")

                }
            }
        }
        return coordinator
        }()
    
    
    //Managedobject context which is bound to persisten store coordinator
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.pesistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    //MARK:- Save Core Data Objects
    func saveContext() throws {
        if managedObjectContext!.hasChanges {
            try managedObjectContext!.save()
        }
    }
    
}
