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
        
       
            do {
                try fetchedResultsController.performFetch()
            } catch let e as NSError {
                print("Error performing initial fetch: \n\(e)\n\(fetchedResultsController)")
            }
        tableView!.tableFooterView = UIView(frame: CGRect.zero)
        tableView!.tableFooterView?.isHidden = true
    }
    
    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        let entity = NSEntityDescription.entity(forEntityName: "Meeting", in: self.sharedContext)
        fetchRequest.entity = entity
        let dateSortDescriptor = NSSortDescriptor(key: "sectionDate", ascending: false)
        let dateTimeSortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor,dateTimeSortDescriptor]
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: "sectionDate", cacheName: nil)
        
        return fetchResultController
        }()

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
       print("Sections \(self.fetchedResultsController.sections?.count)")
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
                let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
                print("Sections Objects\(sectionInfo.numberOfObjects)")
                return sectionInfo.numberOfObjects
            }
           
        }
        return 0
       
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath) as! MeetingCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
            let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo

            if sectionInfo.name != nil {
                 let meeting = self.fetchedResultsController.object(at: IndexPath(row: 0, section: section)) as! Meeting
                let stringFromDate = dateFormatterToGetOnlyDate.string(from: meeting.startTime!)
                return stringFromDate
            }
         }
        }
        
        return  nil

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: "sectionHeader")!
                let sectionHeaderLabel = headerView.viewWithTag(100) as! UILabel
                sectionHeaderLabel.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
                return headerView

            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // This method will download the image and display as soon  as the imgae is downloaded
    func configureCell(_ cell:MeetingCell, atIndexPath indexPath:IndexPath) {
        // Show the placeholder image till the time image is being downloaded
        let meeting = self.fetchedResultsController.object(at: indexPath) as! Meeting
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
                image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                // Update the model so that information gets cached
                //photo.image = image
                    
                    // update the cell later, on the main thread
                    DispatchQueue.main.async {
                        cell.meetingLocationImage.image = image
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                    
                }
            }
            cell.taskToCancelifCellIsReused = task
        
        } else if meeting.location != nil && meeting.location?.imagesURL == nil {
            cell.meetingLocationImage.image = UIImage(named: "noPhoto")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        //tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
            //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.reloadData()
            //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? MeetingCell {
                let meeting = controller.object(at: indexPath!) as! Meeting
                configureCell(cell, atIndexPath: indexPath!)
            }
            
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.reloadData()
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let meetingInfoViewController = segue.destination as! MeetingInfoViewController
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            meetingInfoViewController.meeting = self.fetchedResultsController.object(at: indexPath) as? Meeting
        }
        
    }
    
    fileprivate func showViewWithMessage(inColor labelColor: UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        messageLabel.text = "You don't have any meeting yet! \n Create hangout and invite your friends."
        messageLabel.textColor = labelColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = messageLabelFont()
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    

    

}
