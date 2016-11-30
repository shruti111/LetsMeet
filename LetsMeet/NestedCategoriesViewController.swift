//
//  NestedCategoriesViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 30/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CoreData


class NestedCategoriesViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    var parentCategory:Locationcategory?
    var selectedCategory:Locationcategory?
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = parentCategory?.categoryName
        performFetch()
        
    }

    func performFetch() {
            do {
                try fetchedResultsController.performFetch()
            } catch let e as NSError {
                print("Error performing initial fetch: \n\(e)\n\(fetchedResultsController)")
            }
        
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView!.frame.size.width / 2) - 5, height: 48)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
       return self.fetchedResultsController.sections?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nestedCategoryCell", for: indexPath) as! NestedlocationCategoryCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell:NestedlocationCategoryCollectionViewCell, atIndexPath indexPath:IndexPath) {
        
        // Show the placeholder image till the time image is being downloaded
        let locationcategory = fetchedResultsController.object(at: indexPath) as! Locationcategory
        cell.categoryName.text = locationcategory.categoryName
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.categoryIcon.image = cellImage
            
            //If image is not available, download the flickr image
            //Start the task that will eventually download the image
            
            let task = FourSquareClient.sharedInstance().taskForImage(locationcategory.iconLink) {
                data, error in
                if let downloaderror = error {
                    print("Flick image download error: \(downloaderror.localizedDescription)")
                    
                }
                if let imageData = data {
                    
                    // Create the image
                    var image = UIImage(data: imageData)
                    image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    
                    // update the cell later, on the main thread
                    DispatchQueue.main.async {
                        cell.categoryIcon.image = image
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                }
            }
            cell.taskToCancelifCellIsReused = task
        
        
        cell.categoryIcon.image = cellImage
    }
    
    
    // Reverse segue to set the category on Location Screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UICollectionViewCell
            if let indexPath = collectionView?.indexPath(for: cell) {
                let locationcategory = fetchedResultsController.object(at: indexPath) as! Locationcategory
                selectedCategory = locationcategory
            }
        }
    }
    
    

    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Locationcategory")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "parentId == %@", self.parentCategory!.categoryId)
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        return fetchResultController
        }()

}
