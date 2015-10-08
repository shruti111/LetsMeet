//
//  VenueImagesCollectionView.swift
//  LetsMeet
//
//  Created by Shruti on 06/09/15.
//  Copyright (c) 2015 Shruti. All rights reserved.
//

import UIKit

class VenueImagesCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    // Image URL to show images in collection view cell
    var imageUrls:Array<String>?
    
    // Location for which images are shown
    var locationName:String?
    
    //MARK: UICollectionViewDataSource Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

         return imageUrls != nil ? imageUrls!.count : 1
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        // Set collection view cell
        if imageUrls == nil {
            let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("venueImageCell", forIndexPath: indexPath) as! UICollectionViewCell
            let venueImageView =  cell.viewWithTag(500) as! UIImageView
            venueImageView.image = UIImage(named: "noPhoto")
            return cell
        }
        
        var downloadTask: NSURLSessionTask? = nil
        downloadTask?.cancel()
        
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("venueImageCell", forIndexPath: indexPath) as! UICollectionViewCell
        let venueImageView =  cell.viewWithTag(500) as! UIImageView
        var cellImage = UIImage(named: "imagePlaceholder")
        venueImageView.image = nil
        let downloadActivityIndicatorView = cell.viewWithTag(600) as! UIActivityIndicatorView
        
        let venueImageUrl = imageUrls![indexPath.row]
                    
        
        //Start the task that will eventually download the image
        downloadActivityIndicatorView.startAnimating()
        
        downloadTask = FourSquareClient.sharedInstance().taskForImage(venueImageUrl) {
                data, error in
              dispatch_async(dispatch_get_main_queue()) {
                if let downloaderror = error {
                    print("LetsMeet image download error: \(downloaderror.localizedDescription)")
                    downloadActivityIndicatorView.stopAnimating()
                } else if let imageData = data {
                    
                    if  imageData.length != 0 {
                    // Create the image
                    var image = UIImage(data: imageData)
                    image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    venueImageView.image = image
                    downloadActivityIndicatorView.stopAnimating()
                    
                    } else {
                            downloadActivityIndicatorView.stopAnimating()
                    }
                } else {
                    println("Data is not convertible to Image Data.")
                    downloadActivityIndicatorView.stopAnimating()
                }
            }
            
        }
        
        venueImageView.image = cellImage
            
        
      return cell
    }
    
    
    

    
}
