//
//  Constants.swift
//  LetsMeet
//
//  Created by Shruti  on 22/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation

extension Client {
    
    // MARK: - Constants
    struct Constants {
        
        //Foursquare
        static let FoursquareURL: String = "https://api.foursquare.com/v2"
        static let limitLocations: String = "100"
        static let clientId: String = "Q2RBLKSLZVR3SSS02LJKMT33JDO5OXKMZ0JM3K0AWIMCAM2Q"
        static let clientSecrent: String = "NESNBXAF3MSLMWTSPH41VNEUZ3WATQ4SDFONQ3CJZHSXVQKJ"
        static let versionTillDateSupportsFourSquare = "20150823"
    }
    
        // MARK: - Methods
        
        struct Methods {
            
            //Foursquare Methods
            static let searchLocations = "/venues/search"
            static let getImageForLocation = "/venues/{venueId}/photos"
            static let getCategories = "/venues/categories"
        }
        
        // MARK: - URL Keys
        struct URLKeys {
            
            //Foursquare Image search for venue
             static let VenueId = "venueId"
        }
        
        // MARK: - Parameter Keys
        struct ParameterKeys {
            
            // Foursquare Venues search
            static let LimitNumberofLocations = "limit"
            static let ClientId = "client_id"
            static let ClientSecret = "client_secret"
            static let VersionDate = "v"
            static let locationCoordinates = "ll"
            static let searchString = "query"
        }
        
        // MARK: - JSON Response Keys
        struct JSONResponseKeys {
            
            //FourSquare venues
            static let VeueResponse = "response"
            static let Venues = "venues"
            static let VenueId = "id"
            static let VenueName = "name"
            static let VenueLocation = "location"
            static let Venueaddressline1 = "address"
            static let Venueaddressline2 = "crossStreet"
            static let VenueLattitude = "lat"
            static let VenueLongitude = "lng"
            
            //FourSquare photos
            static let Venuephotos = "photos"
            static let VenuePhotoCount = "count"
            static let VenuePhotoItems = "items"
            
            //Foursquare categories
            static let CategoriesResponse = "response"
            static let Categories = "categories"
            
        }
    
    
    
    
}
