//
//  LcationCategoriesViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 28/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CoreData

class LcationCategoriesViewController: UITableViewController, NSFetchedResultsControllerDelegate{

    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSFetchedResultsController shows Categores from Core Data Entity
        performFetch()
        tableView!.tableFooterView = UIView(frame: CGRectZero)
        tableView!.tableFooterView?.hidden = true
    }
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
              println("Error performing initial fetch: \(error)")
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
   
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCategoryCell", forIndexPath: indexPath) as! ParentlocationCategoryTableViewCell
        configureCell(cell, atIndexPath:indexPath)
        return cell
    }
    
    func configureCell(cell:ParentlocationCategoryTableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        // Show the placeholder image till the time image is being downloaded
        let locationcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Locationcategory
        cell.parentCategoryName.text = locationcategory.categoryName
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.parentCategoryIcon.image = nil
        
        //Start the task that will eventually download the image
            
            let task = FourSquareClient.sharedInstance().taskForImage(locationcategory.iconLink) {
                data, error in
                if let downloaderror = error {
                    print("Flick image download error: \(downloaderror.localizedDescription)")

                }
                if let imageData = data {

                    // Create the image
                    var image = UIImage(data: imageData)
                   image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.parentCategoryIcon.image = image
                    }
                } else {
                    println("Data is not convertible to Image Data.")
                }
            }
            cell.taskToCancelifCellIsReused = task
        
        
        cell.parentCategoryIcon.image = cellImage
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          let locationcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Locationcategory
        performSegueWithIdentifier("showNestedCategory", sender: locationcategory)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! NestedCategoriesViewController
        let cateogry = sender as! Locationcategory
        destinationViewController.parentCategory = cateogry
    }
    
    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Locationcategory")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "parentId == nil")
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        return fetchResultController
        }()

}
