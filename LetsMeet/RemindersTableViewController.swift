//
//  RemindersTableViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 02/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class RemindersTableViewController: UITableViewController {

    var meetingReminderName:String = ""
    
    // Enum to show Reminder options
    enum RemindersList: Int {
            case AtTime = 0, Before5Minutes, Before15Minutes, Before30Minutes, Before1Hour, Before2Hours, Before1Day, Before2Days, Before1Week
        
        var reminderName: String {
            switch self {
            case .AtTime: return "At time of event"
            case .Before5Minutes: return "5 minutes before"
            case .Before15Minutes: return "15 minutes before"
            case .Before30Minutes: return "30 minutes before"
            case .Before1Hour: return "1 hour before"
            case .Before2Hours: return "2 hour before"
            case .Before1Day: return "1 day before"
            case .Before2Days: return "2 days before"
            case .Before1Week: return "1 week before"
            }
        }
        
        // Get count of Swift Enum 
        static var count: Int {
            var max: Int = 0
            while let _ = self.init(rawValue: ++max) {}
            return max
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CloudClient.sharedInstance().meeting?.startTime == nil {
            navigationItem.prompt = "Select Meeting time first"
        }
        if let savedReminder = CloudClient.sharedInstance().meeting?.reminderDuration {
            meetingReminderName = savedReminder
        }
    }

      // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return section == 1 ? RemindersList.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("reminderCell") as! UITableViewCell
        cell.textLabel?.font = tableViewCellLabelFont()
        
        if indexPath.section == 1 {
            if let reminder = RemindersList(rawValue: indexPath.row) {
               cell.textLabel?.text = reminder.reminderName
            }
        } else {
           cell.textLabel?.text = "None"
        }
        if cell.textLabel?.text == meetingReminderName {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
        
    }
    
    // Set the reminder for Meeting Instance
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if  CloudClient.sharedInstance().meeting?.startTime != nil {
            
            if indexPath.section == 1 {
                if let reminder = RemindersList(rawValue: indexPath.row) {
                    let reminderDate = getRemiderTime(reminder)
                    print(reminderDate)
                    CloudClient.sharedInstance().meeting?.reminder = reminderDate
                    CloudClient.sharedInstance().meeting?.reminderDuration = reminder.reminderName
                }
            } else {
                CloudClient.sharedInstance().meeting?.reminder = nil
                CloudClient.sharedInstance().meeting?.reminderDuration = "None"
            }
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell? {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            CloudClient.sharedInstance().meeting?.isReminderSeen = true
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // Get Meeting Reminder time to schedule local Notification
    
    func getRemiderTime(reminder:RemindersList) -> NSDate {
     let eventDate = (CloudClient.sharedInstance().meeting?.startTime)!
        switch reminder {
        case .AtTime:
            return eventDate
        case .Before5Minutes:
            return eventDate.dateBySubtractingMinutes(5)
        case .Before15Minutes:
            return eventDate.dateBySubtractingMinutes(15)
        case .Before30Minutes:
            return eventDate.dateBySubtractingMinutes(30)
        case .Before1Hour:
            return eventDate.dateBySubtractingHours(1)
        case .Before2Hours:
             return eventDate.dateBySubtractingHours(2)
        case .Before1Day:
             return eventDate.dateBySubtractingDays(1)
        case .Before2Days:
            return eventDate.dateBySubtractingDays(2)
        case .Before1Week:
            return eventDate.dateBySubtractingDays(7)
        }
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  

}
