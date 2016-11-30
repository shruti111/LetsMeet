//
//  SearchLocationsViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 26/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class SearchLocationsViewController: UITableViewController {
    
    var locationsArray:Array<Venue>?
    var cityName:String?
    var categoryName:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title with combination of cityname and category
       cityName!.replaceSubrange(cityName!.startIndex...cityName!.startIndex, with: String(cityName![cityName!.startIndex]).capitalized)
        
       categoryName!.replaceSubrange(categoryName!.startIndex...categoryName!.startIndex, with: String(categoryName![categoryName!.startIndex]).capitalized)
        
        title = "\(categoryName!) in \(cityName!)"
    }
    //MARK:- UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationsArray != nil ? locationsArray!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultVenueCell", for: indexPath) as! VenueTableViewCell
        let searchedvenue = locationsArray![(indexPath as NSIndexPath).row]
        cell.configureForSearchResult(searchedvenue)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let searchedvenue = locationsArray![(indexPath as NSIndexPath).row]
        var currenttableHeight = super.tableView(tableView, heightForRowAt: indexPath)
        
        //For title
        
        let titleLabelHeight = getLabelHeight(searchedvenue.name! as NSString, font: tableViewCellLabelMediumLocationFont(), paddingSpace: 24)
        
        if titleLabelHeight > 24 {
            currenttableHeight = currenttableHeight + 24
        }
        
        // Address set the table height based on value
        if searchedvenue.formattedAddress != nil {
            let addresslabelHeight = getLabelHeight(searchedvenue.formattedAddress! as NSString, font: tableViewCellSmallLabelFont(), paddingSpace: 24)
        
        if addresslabelHeight > 20 {
            currenttableHeight = currenttableHeight + 20
            }
        }
        
         return currenttableHeight
        
    }
    
    // Calculate label Height dynamically based on Text
    func getLabelHeight(_ labelText:NSString, font:UIFont, paddingSpace:CGFloat ) -> CGFloat {
        let attributesDictionary = [NSFontAttributeName: font]
        let labelTextString = labelText
        let labelSize = labelTextString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - paddingSpace, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesDictionary, context: nil).size
        return labelSize.height
    }
    
    @IBAction func selectLocation(_ sender: UIButton) {
        let venueTableViewCell = sender.superview?.superview  as! VenueTableViewCell
        let selectedVenue = venueTableViewCell.venue
        CloudClient.sharedInstance().meeting?.location = selectedVenue
         dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Show Image in Entire ViewController - User can scroll and Zoom the same
        if segue.identifier == "ShowImage" {
            let navigationController = segue.destination as! UINavigationController
            let photoViewerViewController = navigationController.topViewController as? PhotoViewerViewController
            let venueImageCollectionViewCell = sender as? UICollectionViewCell
            let venueImageView =  venueImageCollectionViewCell!.viewWithTag(500) as! UIImageView
            photoViewerViewController!.sourceImage = venueImageView.image
            let venueImageCollectionView = venueImageCollectionViewCell!.superview  as! VenueImagesCollectionView
            let locaitonName = venueImageCollectionView.locationName
            photoViewerViewController?.locationName = locaitonName

        } else if segue.identifier == "showSearchedLocationInMap" {
            
            //Show location in the mapview 
            let pinButton = sender as? UIButton
            let venueTableViewCell = pinButton!.superview?.superview  as! VenueTableViewCell
            let mapViewController = segue.destination as! MapViewController
            mapViewController.venueForMap = venueTableViewCell.venue
        }
    }

}
