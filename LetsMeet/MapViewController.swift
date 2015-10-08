//
//  MapViewController.swift
//  LetsMeet
//
//  Created by Shruti on 04/10/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// Show location in Mapkit's mapview
class MapViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    
    var venueForMap:Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = venueForMap?.name
        setMap()
    }
    
    func setMap() {
        let longitude = venueForMap!.coordinate!.longitude
        let latitude = venueForMap!.coordinate!.latitude
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let longitudeDelta = 10.0
        let latitudeDelta = 10.0
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapview.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = venueForMap!.name!
        if let address = venueForMap!.formattedAddress {
            annotation.subtitle = address
        }
        mapview.addAnnotation(annotation)
    }
}
