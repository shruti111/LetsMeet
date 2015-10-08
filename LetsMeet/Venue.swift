//
//  Venue.swift
//  LetsMeet
//
//  Created by Shruti  on 02/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import MapKit

class Venue: NSObject, NSCoding{
   
    var venueId: String?
    var name: String?
    var coordinate: CLLocationCoordinate2D?
    var formattedAddress:String?
    var imagesURL: Array<String>?
    
    required init(coder aDecoder: NSCoder) {
        venueId = aDecoder.decodeObjectForKey("VenueId") as? String
        name = aDecoder.decodeObjectForKey("Name") as? String
        formattedAddress = aDecoder.decodeObjectForKey("FormattedAddress") as? String
        imagesURL = aDecoder.decodeObjectForKey("ImagesURL") as? Array<String>
       
        let lattitude =  aDecoder.decodeDoubleForKey("Lattitude")
        let longitude =  aDecoder.decodeDoubleForKey("Longitude")
        coordinate = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(venueId, forKey: "VenueId")
        aCoder.encodeObject(name, forKey: "Name")
        if coordinate != nil {
            aCoder.encodeDouble(coordinate!.latitude, forKey: "Lattitude")
            aCoder.encodeDouble(coordinate!.longitude, forKey: "Longitude")
        }
        aCoder.encodeObject(formattedAddress, forKey: "FormattedAddress")
        aCoder.encodeObject(imagesURL, forKey: "ImagesURL")
    }
   
   // * Construct a Venue from a available fields */
    init(venueId: String?, name: String?,coordinate:CLLocationCoordinate2D?, formattedAddress:String?,imagesURL:Array<String>?  ) {
        
        self.venueId = venueId
        self.name = name
        self.coordinate = coordinate
        self.formattedAddress = formattedAddress
        self.imagesURL = imagesURL
        super.init()
    }
    
    /* Construct a Venue from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        venueId = dictionary[Client.JSONResponseKeys.VenueId] as? String
        name = dictionary[Client.JSONResponseKeys.VenueName] as? String
        
        if let locationDictionary = dictionary[Client.JSONResponseKeys.VenueLocation] as? [String:AnyObject] {
            
            let lattitude = locationDictionary[Client.JSONResponseKeys.VenueLattitude] as? Double
            let longitude = locationDictionary[Client.JSONResponseKeys.VenueLongitude] as? Double
            
            if lattitude != nil && longitude != nil {
                coordinate = CLLocationCoordinate2D(latitude: lattitude!, longitude: longitude!)
            }
            
            let addressLine1 = locationDictionary[Client.JSONResponseKeys.Venueaddressline1] as? String
            let addressLine2 = locationDictionary[Client.JSONResponseKeys.Venueaddressline2] as? String
            self.formattedAddress = (addressLine1 != nil ? "\(addressLine1!)" : "" ) + (addressLine2 != nil ? " , \(addressLine2!)" : "" )
            
            if self.formattedAddress != nil {
            self.formattedAddress = count(self.formattedAddress!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) > 0 ? self.formattedAddress! : nil
            }
            
        }
        
        super.init()
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func venuesFromResults(results: [[String : AnyObject]]) -> [Venue] {
        var venues = [Venue]()
        
        for result in results {
            venues.append(Venue(dictionary: result))
        }
        
        return venues
    }

    
}
