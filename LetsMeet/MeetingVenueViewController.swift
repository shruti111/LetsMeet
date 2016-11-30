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
    var timer: Timer?
    var locationsArray:Array<Venue>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationService()
        cityNameTextField.delegate = self
        searchPlaceTextField.delegate = self
    }

    @IBAction func getUserCurrentLocation(_ sender: UIButton) {
        
        //Hide error label
        self.errorLabel.isHidden = true
        self.cityNameTextField.text = nil
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            
            // Disable all controls
            cityNameTextField.isEnabled = false
            searchCityOnmapButton.isEnabled = false
            getCurrentLocationButton.isEnabled = false
            nextButton.isEnabled = false
            
            startLocationManager()
        }
    }

    @IBAction func findUserEnteredLocation(_ sender: UIButton) {

       
     if !(self.cityNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0) {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "Place not entered. \n Please enter place name to search."
            return
        }
        
        //Hide error label
        self.errorLabel.isHidden = true
        
        // Find location coordinates
        var userEnteredLocation = self.cityNameTextField.text
        
        // Disable all controls
        cityNameTextField.isEnabled = false
        searchCityOnmapButton.isEnabled = false
        getCurrentLocationButton.isEnabled = false
        nextButton.isEnabled = false
        
        // activity indicator
        searchLocationActivityIndicator.startAnimating()
        
        // Find coordinates using Geocoding
        
        geocoder.geocodeAddressString(userEnteredLocation!, completionHandler: {
            placemarks, error in
            
            self.searchLocationActivityIndicator.stopAnimating()
            
            // Enable all controls
            self.cityNameTextField.isEnabled = true
            self.searchCityOnmapButton.isEnabled = true
            self.getCurrentLocationButton.isEnabled = true
            
            
            // Show geocoding error
            if let geoCodeError = error {
                // If there is a network , find out using CLError Domain
                if geoCodeError._code == CLError.Code.network.rawValue {
                     self.errorLabel.text = "Could not connect. \n Please check your internet connection and try again."
                } else {
                    self.errorLabel.text = userEnteredLocation! + " not found. \n Please re-enter place name to search."
                }
                 self.errorLabel.isHidden = false
                 self.nextButton.isEnabled = false
            }
                
            else {
                if !(placemarks?.isEmpty)! {
                    self.placemark = placemarks!.last as CLPlacemark?
                    self.locationLattitude = self.placemark?.location?.coordinate.latitude
                    self.locationLongitude = self.placemark?.location?.coordinate.longitude
                    self.createStringFromPlacemarkToGetLocationAddress()
                    self.cityNameTextField.text = self.cityName!
                    self.nextButton.isEnabled = true
                } else {
                    self.errorLabel.text = userEnteredLocation! + " not found. \n Please re-enter location to search."
                    self.errorLabel.isHidden = false
                    self.nextButton.isEnabled = false
                }
                
            }
        })

    }
    
    // Crate string from the placemark
    
    func createStringFromPlacemarkToGetLocationAddress() {
        if self.placemark!.subAdministrativeArea != nil {
            if self.placemark!.administrativeArea != nil {
                self.cityName = self.placemark!.subAdministrativeArea! + " , " + self.placemark!.administrativeArea!
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
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            searchLocationActivityIndicator.startAnimating()
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(MeetingVenueViewController.didTimeOut), userInfo: nil, repeats: false)
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
        self.nextButton.isEnabled = true
        }
        self.cityNameTextField.isEnabled = true
        self.searchCityOnmapButton.isEnabled = true
        self.getCurrentLocationButton.isEnabled = true
    }
    func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "LetsMeetErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if error._code == CLError.Code.locationUnknown.rawValue {
            return
        }
        if error._code == CLError.Code.denied.rawValue {
            errorLabel.text = "Location Services Disabled. \n Please enable location service for this app in Settings."
            errorLabel.isHidden = false
        } else {
            errorLabel.text = "There is an error finding your current location. \n Please try again later."
            errorLabel.isHidden = false
        }
        lastLocationError = error as NSError?
        stopLocationManager()
    }
    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let newLocation = locations.last as! CLLocation
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
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
                
                geocoder.reverseGeocodeLocation(location!, completionHandler: {
                    placemarks, error in
                    
                    // If there is a network , find out using CLError Domain
                    
                    self.lastGeocodingError = error as NSError?
                    
                    if error == nil && !(placemarks?.isEmpty)! {
                        self.placemark = placemarks!.last as CLPlacemark?
                        self.locationLattitude = self.placemark?.location?.coordinate.latitude
                        self.locationLongitude = self.placemark?.location?.coordinate.longitude
                        self.createStringFromPlacemarkToGetLocationAddress()
                    } else {
                        
                        if error!._code == CLError.Code.network.rawValue {
                            self.errorLabel.text = "Could not connect. \n Please check your internet connection and try again."
                            self.errorLabel.isHidden = false
                        }
                        self.placemark = nil
                        self.locationLattitude = nil
                        self.locationLongitude = nil
                        self.cityNameTextField.text = ""
                        self.nextButton.isEnabled = false
                        
                    }
                    self.performingReverseGeocoding = false
                })
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                
                self.searchLocationActivityIndicator.stopAnimating()
                stopLocationManager()
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
         dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === cityNameTextField {
        let enterString = cityNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if placemark != nil && (enterString.characters.count) > 0 {
                nextButton.isEnabled = true
            } else {
                nextButton.isEnabled = false
            }
       
       cityNameTextField.resignFirstResponder()
        } else {
       searchPlaceTextField.resignFirstResponder()
        }
       return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField === cityNameTextField {
        nextButton.isEnabled = false
        }
        return true
    }
    
    @IBAction func showCategoryView(_ sender: UIButton) {
        
        changeAlphaWithAnimations()
    }
    
    /* View animation (show post link view by changing alpha and animating with time frame) */
    
    func changeAlphaWithAnimations() {
        
       errorLabel.isHidden = true
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(locationLattitude!, locationLongitude!)
            //annotation.title = "\(location.firstName!) \(location.lastName!)"
            // Add annotation
            mapView.addAnnotation(annotation)
    }

    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        let enterString = searchPlaceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (enterString?.characters.count) == 0 {
            emptySearchMessage.text = "Please enter your interest to search."
            emptySearchMessage.isHidden = false
            return
        } else {
            emptySearchMessage.isHidden = true
        
        
        // Show activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.categoryBarButton.isEnabled = false
        self.searchLocationButton.isEnabled = false
        self.searchPlaceTextField.isEnabled = false
       
        searchActivityIndicator.startAnimating()
        
        let locationString = "\(self.locationLattitude!),\(self.locationLongitude!)"
        
        Client.sharedInstance().searchLocations(locationString, locationSearchString: searchPlaceTextField.text!, completionHandler: {
            results, error in
            
            DispatchQueue.main.async(execute: {
                if let error = error {
                    
                    // Show network error
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.categoryBarButton.isEnabled = true
                    self.searchLocationButton.isEnabled = true
                    self.searchPlaceTextField.isEnabled = true
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
                                    
                                    venueImageServiceCalls = venueImageServiceCalls + 1
                                    
                                    if (venueImageServiceCalls == self.locationsArray!.count) {
                                        
                                        DispatchQueue.main.async {
                                            self.searchActivityIndicator.stopAnimating()
                                            self.categoryBarButton.isEnabled = true
                                            self.searchLocationButton.isEnabled = true
                                            self.searchPlaceTextField.isEnabled = true
                                            self.performSegue(withIdentifier: "ShowSearchedLocations", sender: nil)
                                        }
                                        
                                    }
                                    
                                })
                            }
 
                        } else {
                            //No result
                            self.searchActivityIndicator.stopAnimating()
                            self.emptySearchMessage.text = "No search results! Try with different search input."
                            self.emptySearchMessage.isHidden = false
                            self.categoryBarButton.isEnabled = true
                            self.searchLocationButton.isEnabled = true
                            self.searchPlaceTextField.isEnabled = true
                        }
                        
                    } else {
                        //No result
                        self.searchActivityIndicator.stopAnimating()
                        self.emptySearchMessage.text = "No search results! Try with different search input."
                        self.emptySearchMessage.isHidden = false
                        self.categoryBarButton.isEnabled = true
                        self.searchLocationButton.isEnabled = true
                        self.searchPlaceTextField.isEnabled = true
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
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    func showDataFetchError(_ error:NSError) {
        let alert = UIAlertController(
            title: "Oops...",
            message: error.localizedDescription,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSearchedLocations" {
            let destinationViewController = segue.destination as! SearchLocationsViewController
            destinationViewController.locationsArray = self.locationsArray
            destinationViewController.cityName = cityName!
            destinationViewController.categoryName = searchPlaceTextField.text
        }
    }
    
    func getImageUrl (_ venueId:String, completionHandler : @escaping (_ receivedURL : [String]?) -> Void) -> Void {
        Client.sharedInstance().getVenueImageURL(venueId, completionHandler: {
            result, error in
            
            if error != nil {
                completionHandler(nil)
                
            } else {
                completionHandler(result)
            }
        })
    }
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! NestedCategoriesViewController
        let selectedCategory = controller.selectedCategory
        searchPlaceTextField.text = selectedCategory?.categoryName
    }

   
}
