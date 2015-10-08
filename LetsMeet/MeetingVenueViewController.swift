//
//  MeetingVenueViewController.swift
//  LetsMeet
//
//  Created by Shruti on 02/10/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MeetingVenueViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var searchCityOnmapButton: UIButton!
    @IBOutlet weak var getCurrentLocationButton: UIButton!
    @IBOutlet weak var searchLocationActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchPlaceTextField: UITextField!
    @IBOutlet weak var emptySearchMessage: UILabel!
    
    @IBOutlet var categoryBarButton: UIBarButtonItem!
    
    @IBOutlet weak var searchLocationButton: UIButton!
    
    // Geocoder for reverse geocoding
    let geocoder = CLGeocoder()
    
    //Get Current Location
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var performingReverseGeocoding = false
    var locationLattitude:Double?
    var locationLongitude:Double?
    var placemark: CLPlacemark?
    var cityName:String?
    var lastLocationError: NSError?
    var lastGeocodingError: NSError?
    var timer: NSTimer?
    var locationsArray:Array<Venue>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationService()
        cityNameTextField.delegate = self
        searchPlaceTextField.delegate = self
    }

    @IBAction func getUserCurrentLocation(sender: UIButton) {
        
        //Hide error label
        self.errorLabel.hidden = true
        self.cityNameTextField.text = nil
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            
            // Disable all controls
            cityNameTextField.enabled = false
            searchCityOnmapButton.enabled = false
            getCurrentLocationButton.enabled = false
            nextButton.enabled = false
            
            startLocationManager()
        }
    }

    @IBAction func findUserEnteredLocation(sender: UIButton) {
        
        if !(count(self.cityNameTextField!.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) > 0) {
            self.errorLabel.hidden = false
            self.errorLabel.text = "Place not entered. \n Please enter place name to search."
            return
        }
        
        //Hide error label
        self.errorLabel.hidden = true
        
        // Find location coordinates
        var userEnteredLocation = self.cityNameTextField.text
        
        // Disable all controls
        cityNameTextField.enabled = false
        searchCityOnmapButton.enabled = false
        getCurrentLocationButton.enabled = false
        nextButton.enabled = false
        
        // activity indicator
        searchLocationActivityIndicator.startAnimating()
        
        // Find coordinates using Geocoding
        
        geocoder.geocodeAddressString(userEnteredLocation, completionHandler: {
            placemarks, error in
            
            self.searchLocationActivityIndicator.stopAnimating()
            
            // Enable all controls
            self.cityNameTextField.enabled = true
            self.searchCityOnmapButton.enabled = true
            self.getCurrentLocationButton.enabled = true
            
            
            // Show geocoding error
            if let geoCodeError = error {
                // If there is a network , find out using CLError Domain
                if geoCodeError.code == CLError.Network.rawValue {
                     self.errorLabel.text = "Could not connect. \n Please check your internet connection and try again."
                } else {
                    self.errorLabel.text = userEnteredLocation + " not found. \n Please re-enter place name to search."
                }
                 self.errorLabel.hidden = false
                 self.nextButton.enabled = false
            }
                
            else {
                if !placemarks.isEmpty {
                    self.placemark = placemarks.last as? CLPlacemark
                    self.locationLattitude = self.placemark?.location.coordinate.latitude
                    self.locationLongitude = self.placemark?.location.coordinate.longitude
                    self.createStringFromPlacemarkToGetLocationAddress()
                    self.cityNameTextField.text = self.cityName!
                    self.nextButton.enabled = true
                } else {
                    self.errorLabel.text = userEnteredLocation + " not found. \n Please re-enter location to search."
                    self.errorLabel.hidden = false
                    self.nextButton.enabled = false
                }
                
            }
        })

    }
    
    // Crate string from the placemark
    
    func createStringFromPlacemarkToGetLocationAddress() {
        if self.placemark!.subAdministrativeArea != nil {
            if self.placemark!.administrativeArea != nil {
                self.cityName = self.placemark!.subAdministrativeArea + " , " + self.placemark!.administrativeArea
            } else {
                 self.cityName = self.placemark!.subAdministrativeArea
            }
        } else if self.placemark!.administrativeArea != nil {
            self.cityName =  self.placemark!.administrativeArea
        } else {
            self.cityName = self.cityNameTextField.text
        }
    }
    
    
    
    //Ask for user's consent and find current location
    func requestLocationService() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            searchLocationActivityIndicator.startAnimating()
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
        searchLocationActivityIndicator.stopAnimating()
        
        // Enable all controls
        if placemark != nil {
        self.cityNameTextField.text = self.cityName!
        self.nextButton.enabled = true
        }
        self.cityNameTextField.enabled = true
        self.searchCityOnmapButton.enabled = true
        self.getCurrentLocationButton.enabled = true
    }
    func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "LetsMeetErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        if error.code == CLError.Denied.rawValue {
            errorLabel.text = "Location Services Disabled. \n Please enable location service for this app in Settings."
            errorLabel.hidden = false
        } else {
            errorLabel.text = "There is an error finding your current location. \n Please try again later."
            errorLabel.hidden = false
        }
        lastLocationError = error
        stopLocationManager()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let newLocation = locations.last as! CLLocation
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(location, completionHandler: {
                    placemarks, error in
                    
                    // If there is a network , find out using CLError Domain
                    
                    self.lastGeocodingError = error
                    
                    if error == nil && !placemarks.isEmpty {
                        self.placemark = placemarks.last as? CLPlacemark
                        self.locationLattitude = self.placemark?.location.coordinate.latitude
                        self.locationLongitude = self.placemark?.location.coordinate.longitude
                        self.createStringFromPlacemarkToGetLocationAddress()
                    } else {
                        
                        if error.code == CLError.Network.rawValue {
                            self.errorLabel.text = "Could not connect. \n Please check your internet connection and try again."
                            self.errorLabel.hidden = false
                        }
                        self.placemark = nil
                        self.locationLattitude = nil
                        self.locationLongitude = nil
                        self.cityNameTextField.text = ""
                        self.nextButton.enabled = false
                        
                    }
                    self.performingReverseGeocoding = false
                })
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                
                self.searchLocationActivityIndicator.stopAnimating()
                stopLocationManager()
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === cityNameTextField {
        let enterString = cityNameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if placemark != nil && count(enterString) > 0 {
                nextButton.enabled = true
            } else {
                nextButton.enabled = false
            }
       
       cityNameTextField.resignFirstResponder()
        } else {
       searchPlaceTextField.resignFirstResponder()
        }
       return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField === cityNameTextField {
        nextButton.enabled = false
        }
        return true
    }
    
    @IBAction func showCategoryView(sender: UIButton) {
        
        changeAlphaWithAnimations()
    }
    
    /* View animation (show post link view by changing alpha and animating with time frame) */
    
    func changeAlphaWithAnimations() {
        
       errorLabel.hidden = true
        
        UIView.animateWithDuration(2.0, delay: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.navigationItem.rightBarButtonItem = self.categoryBarButton
            self.categoryView.alpha = 1.0
            }, completion: {
                finished in
                if finished {
                    self.title = "Select Place"
                    // Update the Map
                    self.updateMapView()
                }
        })
        
    }
    
    /* Show mapview with the location */
    
    func updateMapView() -> Void {
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
            // Set map view region
        
            let center = CLLocationCoordinate2D(latitude: locationLattitude!, longitude: locationLongitude!)
            
            let longitudeDelta = 10.0
            let latitudeDelta = 10.0
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            
            // Show annotaion on map with the user's location
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(locationLattitude!, locationLongitude!)
            //annotation.title = "\(location.firstName!) \(location.lastName!)"
            // Add annotation
            mapView.addAnnotation(annotation)
    }

    
    @IBAction func searchButtonTapped(sender: UIButton) {
        
        let enterString = searchPlaceTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if count(enterString) == 0 {
            emptySearchMessage.text = "Please enter your interest to search."
            emptySearchMessage.hidden = false
            return
        } else {
            emptySearchMessage.hidden = true
        
        
        // Show activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.categoryBarButton.enabled = false
        self.searchLocationButton.enabled = false
        self.searchPlaceTextField.enabled = false
       
        searchActivityIndicator.startAnimating()
        
        let locationString = "\(self.locationLattitude!),\(self.locationLongitude!)"
        
        Client.sharedInstance().searchLocations(locationString, locationSearchString: searchPlaceTextField.text, completionHandler: {
            results, error in
            
            dispatch_async(dispatch_get_main_queue(), {
                if let error = error {
                    
                    // Show network error
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.categoryBarButton.enabled = true
                    self.searchLocationButton.enabled = true
                    self.searchPlaceTextField.enabled = true
                    self.searchActivityIndicator.stopAnimating()
                    if error.domain == "LetsMeet NetworkError" {
                        self.showNetworkError()
                        
                    } else {
                        self.showDataFetchError(error)
                    }
                    
                } else {
                    if let searchedVenues = results  {
                        
                        // Show searched venues
                        if searchedVenues.count > 0 {
                            self.locationsArray = searchedVenues as [Venue]
                            
                            var venueImageServiceCalls = 0
                            
                            for objVenue in self.locationsArray! {
                                
                                self.getImageUrl(objVenue.venueId!, completionHandler: {
                                    receivedUrl in
                                    
                                    objVenue.imagesURL = receivedUrl
                                    
                                    venueImageServiceCalls++
                                    
                                    if (venueImageServiceCalls == self.locationsArray!.count) {
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.searchActivityIndicator.stopAnimating()
                                            self.categoryBarButton.enabled = true
                                            self.searchLocationButton.enabled = true
                                            self.searchPlaceTextField.enabled = true
                                            self.performSegueWithIdentifier("ShowSearchedLocations", sender: nil)
                                        })
                                        
                                    }
                                    
                                })
                            }
 
                        } else {
                            //No result
                            self.searchActivityIndicator.stopAnimating()
                            self.emptySearchMessage.text = "No search results! Try with different search input."
                            self.emptySearchMessage.hidden = false
                            self.categoryBarButton.enabled = true
                            self.searchLocationButton.enabled = true
                            self.searchPlaceTextField.enabled = true
                        }
                        
                    } else {
                        //No result
                        self.searchActivityIndicator.stopAnimating()
                        self.emptySearchMessage.text = "No search results! Try with different search input."
                        self.emptySearchMessage.hidden = false
                        self.categoryBarButton.enabled = true
                        self.searchLocationButton.enabled = true
                        self.searchPlaceTextField.enabled = true
                    }
                }
            })
        })
        }
    }
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Could not connect",
            message: "Please check your internet connection and try again.",
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    func showDataFetchError(error:NSError) {
        let alert = UIAlertController(
            title: "Oops...",
            message: error.localizedDescription,
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSearchedLocations" {
            let destinationViewController = segue.destinationViewController as! SearchLocationsViewController
            destinationViewController.locationsArray = self.locationsArray
            destinationViewController.cityName = cityName!
            destinationViewController.categoryName = searchPlaceTextField.text
        }
    }
    
    func getImageUrl (venueId:String, completionHandler : (receivedURL : [String]?) -> Void) -> Void {
        Client.sharedInstance().getVenueImageURL(venueId, completionHandler: {
            result, error in
            
            if error != nil {
                completionHandler(receivedURL: nil)
                
            } else {
                completionHandler(receivedURL: result)
            }
        })
    }
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! NestedCategoriesViewController
        let selectedCategory = controller.selectedCategory
        searchPlaceTextField.text = selectedCategory?.categoryName
    }

   
}
