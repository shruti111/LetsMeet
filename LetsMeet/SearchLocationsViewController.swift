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
       cityName!.replaceRange(cityName!.startIndex...cityName!.startIndex, with: String(cityName![cityName!.startIndex]).capitalizedString)
        
       categoryName!.replaceRange(categoryName!.startIndex...categoryName!.startIndex, with: String(categoryName![categoryName!.startIndex]).capitalizedString)
        
        title = "\(categoryName!) in \(cityName!)"
    }
    //MARK:- UITableViewDataSource Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationsArray != nil ? locationsArray!.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultVenueCell", forIndexPath: indexPath) as! VenueTableViewCell
        let searchedvenue = locationsArray![indexPath.row]
        cell.configureForSearchResult(searchedvenue)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let searchedvenue = locationsArray![indexPath.row]
        var currenttableHeight = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        //For title
        
        let titleLabelHeight = getLabelHeight(searchedvenue.name!, font: tableViewCellLabelMediumLocationFont(), paddingSpace: 24)
        
        if titleLabelHeight > 24 {
            currenttableHeight = currenttableHeight + 24
        }
        
        // Address set the table height based on value
        if searchedvenue.formattedAddress != nil {
            let addresslabelHeight = getLabelHeight(searchedvenue.formattedAddress!, font: tableViewCellSmallLabelFont(), paddingSpace: 24)
        
        if addresslabelHeight > 20 {
            currenttableHeight = currenttableHeight + 20
            }
        }
        
         return currenttableHeight
        
    }
    
    // Calculate label Height dynamically based on Text
    func getLabelHeight(labelText:NSString, font:UIFont, paddingSpace:CGFloat ) -> CGFloat {
        var attributesDictionary = [NSFontAttributeName: font]
        let labelTextString = labelText
        let labelSize = labelTextString.boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.size.width - paddingSpace, height: 10000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributesDictionary, context: nil).size
        return labelSize.height
    }
    
    @IBAction func selectLocation(sender: UIButton) {
        let venueTableViewCell = sender.superview?.superview  as! VenueTableViewCell
        let selectedVenue = venueTableViewCell.venue
        CloudClient.sharedInstance().meeting?.location = selectedVenue
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Show Image in Entire ViewController - User can scroll and Zoom the same
        if segue.identifier == "ShowImage" {
            let navigationController = segue.destinationViewController as! UINavigationController
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
            let mapViewController = segue.destinationViewController as! MapViewController
            mapViewController.venueForMap = venueTableViewCell.venue
        }
    }

}
