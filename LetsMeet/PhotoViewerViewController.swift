//
//  PhotoViewerViewController.swift
//  LetsMeet
//
//  Created by Shruti on 03/10/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

// This shows photo in Scroll view which gives capability to zoom and scroll

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var sourceImage:UIImage?
    var locationName:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = locationName
        imageView = UIImageView(image: sourceImage!)
        let height = view.bounds.size.height -  (navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height)
        let ycoordiate =  (navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height)
        scrollView = UIScrollView(frame: CGRect(x: view.bounds.origin.x, y: ycoordiate, width: view.bounds.size.width, height: height))
        scrollView.autoresizingMask = [.flexibleWidth , .flexibleHeight ]
        scrollView.backgroundColor = landingScreenFilledButtonTintColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        setZoomParametersForSize(scrollView.bounds.size)
        scrollView.zoomScale = scrollView.minimumZoomScale
        recenterImage()
    }

    // Set zoom scale to make photo 3 times bigger
    func setZoomParametersForSize(_ scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minimimScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minimimScale
        scrollView.maximumZoomScale = 3.0
    }
    
    // Center image everytime view controller is shown
    func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
    
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        if  scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        recenterImage()
    }
    
    //MARK: - ScrollViewDelegate Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

   

}
