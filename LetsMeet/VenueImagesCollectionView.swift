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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

         return imageUrls != nil ? imageUrls!.count : 1
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        // Set collection view cell
        if imageUrls == nil {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "venueImageCell", for: indexPath) 
            let venueImageView =  cell.viewWithTag(500) as! UIImageView
            venueImageView.image = UIImage(named: "noPhoto")
            return cell
        }
        
        var downloadTask: URLSessionTask? = nil
        downloadTask?.cancel()
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "venueImageCell", for: indexPath) 
        let venueImageView =  cell.viewWithTag(500) as! UIImageView
        var cellImage = UIImage(named: "imagePlaceholder")
        venueImageView.image = nil
        let downloadActivityIndicatorView = cell.viewWithTag(600) as! UIActivityIndicatorView
        
        let venueImageUrl = imageUrls![(indexPath as NSIndexPath).row]
                    
        
        //Start the task that will eventually download the image
        downloadActivityIndicatorView.startAnimating()
        
        downloadTask = FourSquareClient.sharedInstance().taskForImage(venueImageUrl) {
                data, error in
              DispatchQueue.main.async {
                if let downloaderror = error {
                    print("LetsMeet image download error: \(downloaderror.localizedDescription)")
                    downloadActivityIndicatorView.stopAnimating()
                } else if let imageData = data {
                    
                    if  imageData.count != 0 {
                    // Create the image
                    var image = UIImage(data: imageData)
                    image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                    venueImageView.image = image
                    downloadActivityIndicatorView.stopAnimating()
                    
                    } else {
                            downloadActivityIndicatorView.stopAnimating()
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                    downloadActivityIndicatorView.stopAnimating()
                }
            }
            
        }
        
        venueImageView.image = cellImage
            
        
      return cell
    }
    
    
    

    
}
