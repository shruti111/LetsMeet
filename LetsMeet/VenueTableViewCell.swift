//
//  VenueTableViewCell.swift
//  LetsMeet
//
//  Created by Shruti  on 02/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class VenueTableViewCell: UITableViewCell {

    @IBOutlet weak var venueNameLabel: UILabel!
   
    @IBOutlet weak var venueAddressLabel: UILabel!
    
    @IBOutlet weak var venueImage: UIImageView!
    
    @IBOutlet weak var imageCollectionView: VenueImagesCollectionView!
    
    var venue:Venue?
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureForSearchResult(_ searchResult: Venue) {
        // Set the location see with Venue Data Model / Entity
        venue = searchResult
        venueNameLabel.text = searchResult.name
        
        if let formattedAddress = searchResult.formattedAddress {
            venueAddressLabel.text = formattedAddress
        } else {
            venueAddressLabel.text = "No address found."
        }
            // Table view cell has collection view controller to show images
            imageCollectionView.imageUrls = searchResult.imagesURL
            imageCollectionView.locationName = searchResult.name
            imageCollectionView.dataSource = imageCollectionView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all the fields
        venueNameLabel.text = nil
        venueAddressLabel.text = nil
        imageCollectionView.imageUrls = nil
        imageCollectionView.dataSource = nil
    }

    

}
