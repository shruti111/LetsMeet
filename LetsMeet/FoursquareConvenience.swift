//
//  FoursquareConvenience.swift
//  LetsMeet
//
//  Created by Shruti  on 22/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import CoreData

extension Client {

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // Get locations based on search string and city / place user has selected
    
    func searchLocations(_ locationCoordinates:String, locationSearchString:String,  completionHandler: @escaping (_ result: [Venue]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* Specify parameters */
        
        let parameters = [Client.ParameterKeys.ClientId : Client.Constants.clientId,
            Client.ParameterKeys.ClientSecret : Client.Constants.clientSecrent,
            Client.ParameterKeys.VersionDate : Client.Constants.versionTillDateSupportsFourSquare,
            Client.ParameterKeys.locationCoordinates : locationCoordinates,
            Client.ParameterKeys.searchString : locationSearchString]
        
        /* Make the request */
        
        let task = taskForGETMethod(Client.Methods.searchLocations, parameters: parameters,headerParameters:nil) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            
            if let error = error {
                
                completionHandler(nil, error)
                
            } else {
                
                if let venueResponse = JSONResult!.value(forKey: Client.JSONResponseKeys.VeueResponse) as? [String : AnyObject] {
                    
                    if let venues  = venueResponse[Client.JSONResponseKeys.Venues] as? [[String:AnyObject]] {
                        var searchedVenues:[Venue] = Venue.venuesFromResults(venues)
                        completionHandler(searchedVenues, nil)
                    } else {
                        let dataerror = NSError(domain: "LetsMeet NoDataFound", code: 20, userInfo: [NSLocalizedDescriptionKey : "No location found."])
                        completionHandler(nil, dataerror)
                        
                    }
                    
                } else {
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 30, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(nil, dataerror)
                }
            }
        }
        
        return task
        
    }
    
    // Get Images for locations searched from Foursquare
    
    func getVenueImageURL(_ venueId:String,   completionHandler: @escaping (_ result: [String]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* Specify parameters */
        
        let parameters = [Client.ParameterKeys.ClientId : Client.Constants.clientId,
            Client.ParameterKeys.ClientSecret : Client.Constants.clientSecrent,
            Client.ParameterKeys.VersionDate : Client.Constants.versionTillDateSupportsFourSquare]
        
        var mutableMethod : String = Client.Methods.getImageForLocation
        
        mutableMethod = Client.subtituteKeyInMethod(mutableMethod, key: Client.URLKeys.VenueId, value: venueId)!
        
        /* Make the request */
        
        let task = taskForGETMethod(mutableMethod, parameters: parameters,headerParameters:nil) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            
            if let error = error {
                
                completionHandler(nil, error)
                
            } else {
               
                if let venueResponse = JSONResult!.value(forKey: Client.JSONResponseKeys.VeueResponse) as? [String : AnyObject] {
                    
                    var imageUrl: Array<String>?
                    
                    if let photos  = venueResponse[Client.JSONResponseKeys.Venuephotos] as? [String:AnyObject] {
                
                        if let photoCount = photos[Client.JSONResponseKeys.VenuePhotoCount] as? Int {
                    
                            if photoCount > 0 {
                                
                                if let photoItems = photos[Client.JSONResponseKeys.VenuePhotoItems] as? [[String:AnyObject]] {
                                    
                                    
                                    //Get the image URL - Foursqaure returns Prefix and suffix, which are then combined with size to get complete URL
                                    
                                    imageUrl = photoItems.map() {
                                        (dictionary : [String:AnyObject]) -> String in
                                        var newDictionary = dictionary
                                        let prefix = newDictionary["prefix"] as! String
                                        let suffix = newDictionary["suffix"] as! String
                                        let iconLink = prefix + "300x500" + suffix
                                        return iconLink
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                     completionHandler(imageUrl, nil)
                    
                } else {
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 20, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(nil, dataerror)
                }
            }
        }
        
        return task

    }
    
    // Get Foursquare categories
    func getFoursquareCategories(_ completionHandler: @escaping (_ result: [Locationcategory]?, _ error: NSError?) -> Void) {
        
        /* Specify parameters */
        let parameters = [Client.ParameterKeys.ClientId : Client.Constants.clientId,
            Client.ParameterKeys.ClientSecret : Client.Constants.clientSecrent,
            Client.ParameterKeys.VersionDate : Client.Constants.versionTillDateSupportsFourSquare]
        
         /* Make the request */
        
        let task = taskForGETMethod(Client.Methods.getCategories, parameters: parameters,headerParameters:nil) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            
            if let error = error {
                
                completionHandler(nil, error)
                
            } else {
                
                if let categoriesResponse = JSONResult!.value(forKey: Client.JSONResponseKeys.CategoriesResponse) as? [String : AnyObject] {
                    
                    /* Get the cathegories and sub categories */
                    
                    if let categories  = categoriesResponse[Client.JSONResponseKeys.Categories] as? [[String:AnyObject]] {
                        var categories = categories.map() {
                            (dictionary : [String:AnyObject]) -> Locationcategory in
                            var newDictionary = dictionary
                            let categoryTobeAdded = Locationcategory(dictionary: newDictionary, context: self.sharedContext)
                            
                            return categoryTobeAdded
                        }
                        DispatchQueue.main.async {
                            
                            /* Save these in core data so everytime, categories are not fetched */
                            //Save in core data
                            do {
                                try CoreDataStackManager.sharedInstance().saveContext()
                                 completionHandler(categories, nil)
                            } catch {
                               
                                  completionHandler(nil, NSError(domain: "LetsMeetError", code: 100, userInfo: nil))
                            }
//                            if (CoreDataStackManager.sharedInstance().saveContext()) {
//                                 completionHandler(categories, nil)
//                            } else {
//                                completionHandler(nil, NSError(domain: "LetsMeetError", code: 100, userInfo: nil))
//                            }
                        }
                    }
                    
                } else {
                    
                    /* Parsing Error */
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 20, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(nil, dataerror)
                }
            }
        }
        
       
    }
    
}
