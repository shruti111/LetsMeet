//
//  AllMeetingsViewController.swift
//  LetsMeet
//
//  Created by Shruti on 26/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CoreData

class AllMeetingsViewController: UITableViewController,NSFetchedResultsControllerDelegate {

var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CloudClient.sharedInstance().getOutstandingNotifications()
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        tableView!.tableFooterView = UIView(frame: CGRectZero)
        tableView!.tableFooterView?.hidden = true
    }
    
    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Meeting", inManagedObjectContext: self.sharedContext)
        fetchRequest.entity = entity
        let dateSortDescriptor = NSSortDescriptor(key: "sectionDate", ascending: false)
        let dateTimeSortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor,dateTimeSortDescriptor]
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: "sectionDate", cacheName: nil)
        
        return fetchResultController
        }()

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
       println("Sections \(self.fetchedResultsController.sections?.count)")
       if let sections = fetchedResultsController.sections {
        if sections.count > 0 {
            return self.fetchedResultsController.sections!.count
        } else {
            showViewWithMessage(inColor: emptyDatamessageColor())
            return 1
        }
       } else {
        return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
                let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
                println("Sections Objects\(sectionInfo.numberOfObjects)")
                return sectionInfo.numberOfObjects
            }
           
        }
        return 0
       
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("meetingCell", forIndexPath: indexPath) as! MeetingCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
            let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo

            if sectionInfo.name != nil {
                 let meeting = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: section)) as! Meeting
                let stringFromDate = dateFormatterToGetOnlyDate.stringFromDate(meeting.startTime!)
                return stringFromDate
            }
         }
        }
        
        return  nil

    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
                let headerView = tableView.dequeueReusableCellWithIdentifier("sectionHeader") as! UITableViewCell
                let sectionHeaderLabel = headerView.viewWithTag(100) as! UILabel
                sectionHeaderLabel.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
                return headerView

            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // This method will download the image and display as soon  as the imgae is downloaded
    func configureCell(cell:MeetingCell, atIndexPath indexPath:NSIndexPath) {
        // Show the placeholder image till the time image is being downloaded
        let meeting = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Meeting
        cell.meetingTitle.text = meeting.title
        cell.meetingTime.text = meeting.meetingHours
        
    
        if meeting.location != nil && meeting.location!.imagesURL != nil {
            
        
            let venueImageUrl = meeting.location!.imagesURL![0]
            
            let task = FourSquareClient.sharedInstance().taskForImage(venueImageUrl) {
                data, error in
                if let downloaderror = error {
                    print("LetsMeet image download error: \(downloaderror.localizedDescription)")
                   
                }
                if let imageData = data {
                    
                // Create the image
                var image = UIImage(data: imageData)
                image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                // Update the model so that information gets cached
                //photo.image = image
                    
                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.meetingLocationImage.image = image
                    }
                } else {
                    println("Data is not convertible to Image Data.")
                    
                }
            }
            cell.taskToCancelifCellIsReused = task
        
        } else if meeting.location != nil && meeting.location?.imagesURL == nil {
            cell.meetingLocationImage.image = UIImage(named: "noPhoto")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        //tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
            tableView.reloadData()
            //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (object)")
            tableView.reloadData()
            //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? MeetingCell {
                let meeting = controller.objectAtIndexPath(indexPath!) as! Meeting
                configureCell(cell, atIndexPath: indexPath!)
            }
            
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (section)")
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
            tableView.reloadData()
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (section)")
            tableView.reloadData()
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (section)")
            
        case .Move:
            println("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let meetingInfoViewController = segue.destinationViewController as! MeetingInfoViewController
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            meetingInfoViewController.meeting = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Meeting
        }
        
    }
    
    private func showViewWithMessage(inColor labelColor: UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        messageLabel.text = "You don't have any meeting yet! \n Create hangout and invite your friends."
        messageLabel.textColor = labelColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = messageLabelFont()
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .None
    }
    

    

}
