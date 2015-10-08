//
//  Meeting.swift
//  LetsMeet
//
//  Created by Shruti  on 16/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Meeting core data entity
class Meeting: NSManagedObject {

    @NSManaged var meetingID: String?
    @NSManaged var details: String?
    @NSManaged var location: Venue?
    @NSManaged var reminder: NSDate?
    @NSManaged var startTime: NSDate?
    @NSManaged var endTime: NSDate?
    @NSManaged var title: String? 
    @NSManaged var invitees: [Contact]?
    @NSManaged var sectionDate: NSDate?
    @NSManaged var meetingOwner:String?
    @NSManaged var attending:Bool
    @NSManaged var reminderDuration:String?
    var isReminderSeen = false

    // Format Meeting time
    var meetingHours:String {
        let dateFormatterStart = NSDateFormatter()
        dateFormatterStart.dateFormat = "h:mm a"
        
        let dateFormatterEnd = NSDateFormatter()
        dateFormatterEnd.dateFormat = "h:mm a"
        print(startTime)
        print(endTime)
        if startTime != nil && endTime != nil {
        println("\(dateFormatterStart.stringFromDate(startTime!)) to \(dateFormatterEnd.stringFromDate(endTime!))")
        return "\(dateFormatterStart.stringFromDate(startTime!)) to \(dateFormatterEnd.stringFromDate(endTime!))"
        }
        return ""
        
    }
    
    //Init method to insert object in core data
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            println("Found an existing notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
        if reminder != nil && reminder!.compare(NSDate()) != NSComparisonResult.OrderedAscending {
            
            // Set up notification with Sound and message
            let localNotification = UILocalNotification()
            localNotification.fireDate = reminder!
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = title!
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["MeetingID": meetingID!]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            println("Scheduled notification \(localNotification) for itemID \(meetingID)")
        }
    }
    
    // Find if notification exists
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        for notification in allNotifications {
            if let meetingId = notification.userInfo?["MeetingID"] as? String {
                if meetingId == meetingID {
                    return notification
                }
            }
        }
        return nil
    }
    
    func getFullName(firstName:String?,lastName:String?) -> String? {
        if firstName != nil && lastName != nil {
            return "\(firstName!) \(lastName!)"
        } else if firstName != nil {
            return firstName!
        } else if lastName != nil {
            return lastName!
        } else {
            return nil
        }
    }
}
