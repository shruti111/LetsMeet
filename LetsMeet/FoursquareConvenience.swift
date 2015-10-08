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
    
    func searchLocations(locationCoordinates:String, locationSearchString:String,  completionHandler: (result: [Venue]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
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
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                if let venueResponse = JSONResult.valueForKey(Client.JSONResponseKeys.VeueResponse) as? [String : AnyObject] {
                    
                    if let venues  = venueResponse[Client.JSONResponseKeys.Venues] as? [[String:AnyObject]] {
                       var searchedVenues = Venue.venuesFromResults(venues)
                       completionHandler(result: searchedVenues, error: nil)
                    } else {
                        let dataerror = NSError(domain: "LetsMeet NoDataFound", code: 20, userInfo: [NSLocalizedDescriptionKey : "No location found."])
                        completionHandler(result: nil, error: dataerror)
                        
                    }
                    
                } else {
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 30, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(result: nil, error: dataerror)
                }
            }
        }
        
        return task
        
    }
    
    // Get Images for locations searched from Foursquare
    
    func getVenueImageURL(venueId:String,   completionHandler: (result: [String]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
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
                
                completionHandler(result: nil, error: error)
                
            } else {
               
                if let venueResponse = JSONResult.valueForKey(Client.JSONResponseKeys.VeueResponse) as? [String : AnyObject] {
                    
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
                    
                     completionHandler(result: imageUrl, error: nil)
                    
                } else {
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 20, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(result: nil, error: dataerror)
                }
            }
        }
        
        return task

    }
    
    // Get Foursquare categories
    func getFoursquareCategories(completionHandler: (result: [Locationcategory]?, error: NSError?) -> Void) {
        
        /* Specify parameters */
        let parameters = [Client.ParameterKeys.ClientId : Client.Constants.clientId,
            Client.ParameterKeys.ClientSecret : Client.Constants.clientSecrent,
            Client.ParameterKeys.VersionDate : Client.Constants.versionTillDateSupportsFourSquare]
        
         /* Make the request */
        
        let task = taskForGETMethod(Client.Methods.getCategories, parameters: parameters,headerParameters:nil) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            
            if let error = error {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                if let categoriesResponse = JSONResult.valueForKey(Client.JSONResponseKeys.CategoriesResponse) as? [String : AnyObject] {
                    
                    /* Get the cathegories and sub categories */
                    
                    if let categories  = categoriesResponse[Client.JSONResponseKeys.Categories] as? [[String:AnyObject]] {
                        var categories = categories.map() {
                            (dictionary : [String:AnyObject]) -> Locationcategory in
                            var newDictionary = dictionary
                            let categoryTobeAdded = Locationcategory(dictionary: newDictionary, context: self.sharedContext)
                            
                            return categoryTobeAdded
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            /* Save these in core data so everytime, categories are not fetched */
                            
                            if (CoreDataStackManager.sharedInstance().saveContext()) {
                                 completionHandler(result: categories, error: nil)
                            } else {
                                completionHandler(result: nil, error: NSError(domain: "LetsMeetError", code: 100, userInfo: nil))
                            }
                        }
                    }
                    
                } else {
                    
                    /* Parsing Error */
                    
                    let dataerror = NSError(domain: "LetsMeet DataError", code: 20, userInfo: [NSLocalizedDescriptionKey : "Internal Error getting locations. Please try again later."])
                    completionHandler(result: nil, error: dataerror)
                }
            }
        }
        
       
    }
    
}
