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
    @NSManaged var reminder: Date?
    @NSManaged var startTime: Date?
    @NSManaged var endTime: Date?
    @NSManaged var title: String? 
    @NSManaged var invitees: [Contact]?
    @NSManaged var sectionDate: Date?
    @NSManaged var meetingOwner:String?
    @NSManaged var attending:Bool
    @NSManaged var reminderDuration:String?
    var isReminderSeen = false

    // Format Meeting time
    var meetingHours:String {
        let dateFormatterStart = DateFormatter()
        dateFormatterStart.dateFormat = "h:mm a"
        
        let dateFormatterEnd = DateFormatter()
        dateFormatterEnd.dateFormat = "h:mm a"
        print(startTime)
        print(endTime)
        if startTime != nil && endTime != nil {
        print("\(dateFormatterStart.string(from: startTime!)) to \(dateFormatterEnd.string(from: endTime!))")
        return "\(dateFormatterStart.string(from: startTime!)) to \(dateFormatterEnd.string(from: endTime!))"
        }
        return ""
        
    }
    
    //Init method to insert object in core data
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Found an existing notification \(notification)")
            UIApplication.shared.cancelLocalNotification(notification)
        }
        
        if reminder != nil && reminder!.compare(Date()) != ComparisonResult.orderedAscending {
            
            // Set up notification with Sound and message
            let localNotification = UILocalNotification()
            localNotification.fireDate = reminder!
            localNotification.timeZone = TimeZone.current
            localNotification.alertBody = title!
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["MeetingID": meetingID!]
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
            print("Scheduled notification \(localNotification) for itemID \(meetingID)")
        }
    }
    
    // Find if notification exists
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.shared.scheduledLocalNotifications as! [UILocalNotification]!
        for notification in allNotifications! {
            if let meetingId = notification.userInfo?["MeetingID"] as? String {
                if meetingId == meetingID {
                    return notification
                }
            }
        }
        return nil
    }
    
    func getFullName(_ firstName:String?,lastName:String?) -> String? {
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
