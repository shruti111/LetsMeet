//
//  MeetingInfoViewController.swift
//  LetsMeet
//
//  Created by Shruti on 27/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import MapKit

// This view controller shows information about meeting in detail

class MeetingInfoViewController: UITableViewController {

    var meeting:Meeting?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageCollectionView: VenueImagesCollectionView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var imageCollectionTableViewCell: UITableViewCell!
    @IBOutlet weak var addressTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meeting Details"
        
        // This is static table view , so set the all UI element properties
        
        if meeting?.location?.imagesURL == nil {
          imageCollectionTableViewCell.isHidden = true
        } else {
            imageCollectionView!.imageUrls = meeting!.location!.imagesURL
            imageCollectionView!.dataSource = imageCollectionView!
        }
        
    
        if meeting?.location?.formattedAddress == nil {
            addressTableViewCell.isHidden = true
        } else {
            addressLabel.text = meeting!.location!.formattedAddress
        }
        
        titleLabel.text = meeting!.title
        organizerLabel.text =  meeting!.meetingOwner
    
        descriptionLabel.text = meeting!.details  ?? nil
        dateLabel.text = dateFormatterToGetOnlyDate.string(from: meeting!.startTime!)
        timeLabel.text = meeting!.meetingHours
        
        locationName.text = meeting!.location!.name
        
        //Set location coordinates in the map
        let longitude = meeting!.location!.coordinate!.longitude
        let latitude = meeting!.location!.coordinate!.latitude
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let longitudeDelta = 10.0
        let latitudeDelta = 10.0
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //Based on the data filled by user, set the each table view row's height
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
        
        if (indexPath as NSIndexPath).row == 0 {
            return  getLabelHeight(meeting!.title! as NSString, font: tableViewCellLabelBigFont(), paddingSpace:16)
          
        } else if (indexPath as NSIndexPath).row ==  2 {
            if meeting?.details != nil {
             return  getLabelHeight(meeting!.details! as NSString, font: tableViewCellLabelMediumFont(), paddingSpace:133)
            }
        }else if (indexPath as NSIndexPath).row ==  5 {
            return  getLabelHeight(meeting!.location!.name! as NSString, font: tableViewCellLabelMediumFont(), paddingSpace:133)
        }
        if meeting?.location?.formattedAddress == nil {
            if cell === addressTableViewCell {
                return 0
            }
        } else {
            if (indexPath as NSIndexPath).row == 6 {
                return  getLabelHeight(meeting!.location!.formattedAddress! as NSString, font: tableViewCellLabelMediumFont(), paddingSpace:133)
            }
        }
        if meeting?.location?.imagesURL == nil {
            if cell === imageCollectionTableViewCell {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    // Calculate label height from the text
    
    func getLabelHeight(_ labelText:NSString, font:UIFont, paddingSpace:CGFloat ) -> CGFloat {
        
        let attributesDictionary = [NSFontAttributeName: font]
        let labelTextString = labelText
        let labelSize = labelTextString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - paddingSpace, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesDictionary, context: nil).size
        return labelSize.height + 16
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let navigationController = segue.destination as! UINavigationController
            let photoViewerViewController = navigationController.topViewController as? PhotoViewerViewController
            let venueImageCollectionView = sender as? UICollectionViewCell
            let venueImageView =  venueImageCollectionView!.viewWithTag(500) as! UIImageView
            photoViewerViewController!.sourceImage = venueImageView.image
            photoViewerViewController!.locationName = meeting!.location!.name

        } else if segue.identifier == "showLocationinMap" {
            let mapViewController = segue.destination as! MapViewController
             mapViewController.venueForMap = meeting!.location
        }
    }
    
    @IBAction func showLocationInMap(_ sender: UIButton) {
         performSegue(withIdentifier: "showLocationinMap", sender: nil)
    }

}
