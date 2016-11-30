//
//  FoursquareClient.swift
//  LetsMeet
//
//  Created by Shruti  on 28/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import CoreData

class FourSquareClient: NSObject {
    
    /* Shared session */
    var session: URLSession
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FourSquareClient {
        
        struct Singleton {
            static var sharedInstance = FourSquareClient()
        }
        return Singleton.sharedInstance
    }
    
        
    /// Data task to download  image
    func taskForImage(_ filePath:String, completionHandler :@escaping (_ imageDate:Data?, _ error:NSError?) -> Void)-> URLSessionTask {
        
        let url = URL(string: filePath)!
        let request = URLRequest(url: url)
        
        // Make the request
        let task = session.dataTask(with: request, completionHandler: {
            data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(data, error as NSError?)
            } else {
                completionHandler(data, nil)
            }
        }) 
        task.resume()
        return task
        
    }
    

}
