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
    var session: NSURLSession
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override init() {
        session = NSURLSession.sharedSession()
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
    func taskForImage(filePath:String, completionHandler :(imageDate:NSData?, error:NSError?) -> Void)-> NSURLSessionTask {
        
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        
        // Make the request
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageDate: data, error: error)
            } else {
                completionHandler(imageDate: data, error: nil)
            }
        }
        task.resume()
        return task
        
    }
    

}
