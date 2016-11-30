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
            case atTime = 0, before5Minutes, before15Minutes, before30Minutes, before1Hour, before2Hours, before1Day, before2Days, before1Week
        
        var reminderName: String {
            switch self {
            case .atTime: return "At time of event"
            case .before5Minutes: return "5 minutes before"
            case .before15Minutes: return "15 minutes before"
            case .before30Minutes: return "30 minutes before"
            case .before1Hour: return "1 hour before"
            case .before2Hours: return "2 hour before"
            case .before1Day: return "1 day before"
            case .before2Days: return "2 days before"
            case .before1Week: return "1 week before"
            }
        }
        
        // Get count of Swift Enum 
        static var count: Int {
            var max: Int = 0
            while let _ = self.init(rawValue: max + 1)
            {
                
            }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return section == 1 ? RemindersList.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reminderCell")!
        cell.textLabel?.font = tableViewCellLabelFont()
        
        if (indexPath as NSIndexPath).section == 1 {
            if let reminder = RemindersList(rawValue: (indexPath as NSIndexPath).row) {
               cell.textLabel?.text = reminder.reminderName
            }
        } else {
           cell.textLabel?.text = "None"
        }
        if cell.textLabel?.text == meetingReminderName {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
        
    }
    
    // Set the reminder for Meeting Instance
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  CloudClient.sharedInstance().meeting?.startTime != nil {
            
            if (indexPath as NSIndexPath).section == 1 {
                if let reminder = RemindersList(rawValue: (indexPath as NSIndexPath).row) {
                    let reminderDate = getRemiderTime(reminder)
                    print(reminderDate)
                    CloudClient.sharedInstance().meeting?.reminder = reminderDate
                    CloudClient.sharedInstance().meeting?.reminderDuration = reminder.reminderName
                }
            } else {
                CloudClient.sharedInstance().meeting?.reminder = nil
                CloudClient.sharedInstance().meeting?.reminderDuration = "None"
            }
            
            if let cell = tableView.cellForRow(at: indexPath) as UITableViewCell? {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            CloudClient.sharedInstance().meeting?.isReminderSeen = true
            dismiss(animated: true, completion: nil)
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // Get Meeting Reminder time to schedule local Notification
    
    func getRemiderTime(_ reminder:RemindersList) -> Date {
     let eventDate = (CloudClient.sharedInstance().meeting?.startTime)!
        switch reminder {
        case .atTime:
            return eventDate as Date
        case .before5Minutes:
            return (eventDate as NSDate).dateBySubtractingMinutes(dMinutes: 5) as Date
        case .before15Minutes:
            return (eventDate as NSDate).dateBySubtractingMinutes(dMinutes:15) as Date
        case .before30Minutes:
            return (eventDate as NSDate).dateBySubtractingMinutes(dMinutes:30) as Date
        case .before1Hour:
            return (eventDate as NSDate).dateBySubtractingHours(dHours:1) as Date
        case .before2Hours:
             return (eventDate as NSDate).dateBySubtractingHours(dHours:2) as Date
        case .before1Day:
             return (eventDate as NSDate).dateBySubtractingDays(dDays:1) as Date
        case .before2Days:
            return (eventDate as NSDate).dateBySubtractingDays(dDays:2) as Date
        case .before1Week:
            return (eventDate as NSDate).dateBySubtractingDays(dDays:7) as Date
        }
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  

}
