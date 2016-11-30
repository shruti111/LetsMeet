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
        tableView!.tableFooterView = UIView(frame: CGRect.zero)
        tableView!.tableFooterView?.isHidden = true
    }
    
    func performFetch() {
        
            do {
                try fetchedResultsController.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCategoryCell", for: indexPath) as! ParentlocationCategoryTableViewCell
        configureCell(cell, atIndexPath:indexPath)
        return cell
    }
    
    func configureCell(_ cell:ParentlocationCategoryTableViewCell, atIndexPath indexPath:IndexPath) {
        
        // Show the placeholder image till the time image is being downloaded
        let locationcategory = fetchedResultsController.object(at: indexPath) as! Locationcategory
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
                   image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

                    // update the cell later, on the main thread
                    DispatchQueue.main.async {
                        cell.parentCategoryIcon.image = image
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                }
            }
            cell.taskToCancelifCellIsReused = task
        
        
        cell.parentCategoryIcon.image = cellImage
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let locationcategory = fetchedResultsController.object(at: indexPath) as! Locationcategory
        performSegue(withIdentifier: "showNestedCategory", sender: locationcategory)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! NestedCategoriesViewController
        let cateogry = sender as! Locationcategory
        destinationViewController.parentCategory = cateogry
    }
    
    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Locationcategory")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "parentId == nil")
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        return fetchResultController
        }()

}
