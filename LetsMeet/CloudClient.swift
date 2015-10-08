//
//  CloudClient.swift
//  LetsMeet
//
//  Created by Shruti  on 16/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class CloudClient: NSObject {
    
    var meeting:Meeting?
    var container : CKContainer
    var userRecordID : CKRecordID!
    var loggedInusersFirstName:String?
    var loggedInusersLastName:String?
    var useriCloudLoginStatus:String
    var canSearchForAddressbookContacts = false
    var subscribed = false
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> CloudClient {
        
        struct Singleton {
            static var sharedInstance = CloudClient()
        }
        
        return Singleton.sharedInstance
    }
    
    //MARK:- Core Data Operations
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override init() {
        
        // CloudKit default container
        container = CKContainer.defaultContainer()
        
        // Set user's iCloud status as not logged in
        useriCloudLoginStatus = "Not logged in to iCloud"
        super.init()
        
        // Create shared entity
        createNewMeetingEntity()
    }
    
    // MARK:- Shared Meeting Instance
    
    func createNewMeetingEntity() {
        
        // This meeting instance will be shared and saved in core data when user fills all information
        
        let meetingEntity = NSEntityDescription.entityForName("Meeting", inManagedObjectContext: sharedContext)
        meeting = NSManagedObject(entity: meetingEntity!, insertIntoManagedObjectContext: nil) as? Meeting
    }
    
    //MARK:- iCloud User Information
    
    func askUserToEnteriCloudLogin(completionHandler :(success:Bool, error:NSError?) -> Void)  {
        container.accountStatusWithCompletionHandler({
        
            accountStatus, error in
           
            if error != nil {
                if error!.code == CKErrorCode.NetworkFailure.rawValue || error!.code == CKErrorCode.NetworkUnavailable.rawValue {
                
                    completionHandler(success: false, error: NSError(domain: "LetsMeet iCloudNetworkError", code: 10, userInfo: nil))
                
                } else {
                    
                    completionHandler(success: false, error: NSError(domain: "LetsMeet iCloudInternalError", code: 20, userInfo: [NSLocalizedDescriptionKey : "iCloud service unavailable to set up meeting. Please try again later."]))
                }
                
            } else if accountStatus == CKAccountStatus.NoAccount {
                
                // User has no account in Settings in iCloud
                completionHandler(success: false, error:nil)
                
            } else if accountStatus == CKAccountStatus.Available {
                
                self.useriCloudLoginStatus = "Logged in to iCloud"
                
                // Logged in to iCloud
                self.userInfo({
                    receiveduserInfo, error in
                    
                    if error != nil {
                        
                        if error!.code == CKErrorCode.NetworkFailure.rawValue || error!.code == CKErrorCode.NetworkUnavailable.rawValue {
                            
                            completionHandler(success: false, error: NSError(domain: "LetsMeet iCloudNetworkError", code: 10, userInfo: nil))
                            
                        } else {
                            
                            completionHandler(success: false, error: NSError(domain: "LetsMeet iCloudInternalError", code: 20, userInfo: [NSLocalizedDescriptionKey : "iCloud service unavailable to set up meeting. Please try again later."]))
                        }
                        
                    } else if receiveduserInfo != nil {
                       
                        // Get logged in user's information
                        self.loggedInusersFirstName = receiveduserInfo.firstName
                        self.loggedInusersLastName = receiveduserInfo.lastName
                        
                        CloudClient.sharedInstance().meeting?.meetingOwner = CloudClient.sharedInstance().meeting?.getFullName(self.loggedInusersFirstName, lastName: self.loggedInusersLastName)
                        self.useriCloudLoginStatus = "Logged in as \(CloudClient.sharedInstance().meeting!.meetingOwner!)"

                        // Add subscription so when the meeting having this user as particiapnt created, he will get the Push notification
                        self.addNewSubscriptions()
                        
                        // Once the logged in user is discoverbale, we will get contacts from addressbook and CloudKit
                        self.canSearchForAddressbookContacts = true
                        
                        // Retrieve all user's contacts who has installed this app and have iCloud Account
                        AddressBookClient.sharedInstance().getAddressbookContacts()
                        
                        completionHandler(success: true, error:nil)

                    } else {
                         completionHandler(success: true, error:nil)
                    }
                })
            }
        })
    }
    func userInfo(completion: (userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        
        // Request user to find out by his iCloud Account
        requestDiscoverability() { discoverable in
            self.userID() { recordID, error in
                if error != nil {
                    completion(userInfo: nil, error: error)
                } else {
                    self.userInfoRecord(recordID, completion: completion)
                }
            }
        }
    }
    func requestDiscoverability(completion: (discoverable: Bool) -> ()) {
        container.statusForApplicationPermission(
            .PermissionUserDiscoverability) {
                status, error in
                if error != nil || status == CKApplicationPermissionStatus.Denied {
                    completion(discoverable: false)
                } else {
                    self.container.requestApplicationPermission(.PermissionUserDiscoverability) { status, error in
                        self.container.discoverAllContactUserInfosWithCompletionHandler({
                            data, error in
                        })
                        
                        completion(discoverable: status == .Granted)
                    }
                }
        }
    }
    
    // This function retrieves user's iCloud Account ID
    func userID(completion: (userRecordID: CKRecordID!, error: NSError!)->()) {
        if userRecordID != nil {
            completion(userRecordID: userRecordID, error: nil)
        } else {
            self.container.fetchUserRecordIDWithCompletionHandler() {
                recordID, error in
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(userRecordID: recordID, error: error)
            }
        }
    }
    
    func userInfoRecord(recordID: CKRecordID!,completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
            container.discoverUserInfoWithUserRecordID(recordID,
                completionHandler:completion)
    }
    
    // This Function tells us that the user's contact's Email Address is iCloud Account or not
    func userInfoEmail(emailId:String,completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        container.discoverUserInfoWithEmailAddress(emailId, completionHandler: completion)
    }
   
    //MARK:- Create Meeting in iCloud and Core Data
    
    // Meeting instance is created in iCloud - This sends notification to all the participants
    // Meeting is saved in Core data which has logged in user's information like Reminder
    
    func createMeeting(completion:(isRecordSaved:Bool, error: NSError?)->()) {
        CloudClient.sharedInstance().meeting?.meetingOwner = CloudClient.sharedInstance().meeting?.getFullName(self.loggedInusersFirstName, lastName: self.loggedInusersLastName)
        if let cloudMeeting = CloudClient.sharedInstance().meeting {
           
            let meetingRecord = CKRecord(recordType: "CloudMeeting")
            meetingRecord.setObject(cloudMeeting.title, forKey: "title")
            meetingRecord.setObject(cloudMeeting.details, forKey: "details")
            meetingRecord.setObject(cloudMeeting.startTime, forKey: "startTime")
            meetingRecord.setObject(cloudMeeting.endTime, forKey: "endTime")
            meetingRecord.setObject(cloudMeeting.meetingOwner, forKey: "meetingOwner")
            
            //Venue
            let venueRecord = CKRecord(recordType: "Venue")
            venueRecord.setObject(cloudMeeting.location?.venueId, forKey: "venueId")
            venueRecord.setObject(cloudMeeting.location?.name, forKey: "venueName")
            venueRecord.setObject(CLLocation(latitude: cloudMeeting.location!.coordinate!.latitude, longitude: cloudMeeting.location!.coordinate!.longitude), forKey: "coordinate")
             venueRecord.setObject(cloudMeeting.location?.formattedAddress, forKey: "formattedAddress")
            venueRecord.setObject(cloudMeeting.location?.imagesURL, forKey: "imagesURL")
            
            
            var inviteesReferences = Array<CKReference>()
            
            //Invitees Reference
            for contact in cloudMeeting.invitees! {
                let inviteeReference = CKReference(recordID: CKRecordID(recordName: contact.cloudRecordId!), action: CKReferenceAction.None)
                println(contact.cloudRecordId!)
                inviteesReferences.append(inviteeReference)
            }
            meetingRecord.setObject(inviteesReferences, forKey: "Users")
           
        let publicDatabase: CKDatabase  = container.publicCloudDatabase
            //Save record
            publicDatabase.saveRecord(venueRecord!, completionHandler: {
                record, error in
                if error != nil {
                    println(error)
                    completion(isRecordSaved: false, error: error)
                } else {
                    println(record)
                    
                    let venueReference = CKReference(record: record, action: CKReferenceAction.None)
                     meetingRecord.setObject(venueReference, forKey: "Venue")
                
                    publicDatabase.saveRecord(meetingRecord, completionHandler: {
                        savedRecord, savOperationerror in
                        if savOperationerror != nil {
                             println(savOperationerror)
                             completion(isRecordSaved: false, error: savOperationerror)
                        } else {
                           println(savedRecord)
                           CloudClient.sharedInstance().meeting?.meetingID = savedRecord!.recordID.recordName
                            self.sharedContext.insertObject(CloudClient.sharedInstance().meeting!)
                            if CoreDataStackManager.sharedInstance().saveContext() {
                                CloudClient.sharedInstance().meeting!.scheduleNotification()
                                CloudClient.sharedInstance().createNewMeetingEntity()
                                completion(isRecordSaved: true, error: nil)
                            } else {
                                completion(isRecordSaved: false, error: nil)
                            }
                        }
                    })
 
                }
            })
        }
        
    }
    func saveMeetingInCoreData(record:CKRecord) {
        
        self.fetchVenueRecord(record, completion: {
            venueRecord in
            if venueRecord != nil {
                
                // Venue
                let venueId = venueRecord!.objectForKey("venueId") as? String
                let venueName = venueRecord!.objectForKey("venueName") as? String
                let formattedAddress = venueRecord!.objectForKey("formattedAddress") as? String
                let imagesURL = venueRecord!.objectForKey("imagesURL") as? Array<String>
                let venueLocation = venueRecord!.objectForKey("coordinate") as? CLLocation
                
                let venue = Venue(venueId: venueId, name: venueName, coordinate: CLLocationCoordinate2D(latitude: venueLocation!.coordinate.latitude, longitude: venueLocation!.coordinate.longitude), formattedAddress: formattedAddress, imagesURL: imagesURL)
                
                let entity = NSEntityDescription.entityForName("Meeting", inManagedObjectContext: self.sharedContext)!
                
                // Meeting Entity
                var meetingRecord = Meeting(entity: entity, insertIntoManagedObjectContext: self.sharedContext)
                meetingRecord.meetingID = record.recordID.recordName
                meetingRecord.details = record.objectForKey("details") as? String
                meetingRecord.title = record.objectForKey("title") as? String
                meetingRecord.startTime = record.objectForKey("startTime") as? NSDate
                meetingRecord.endTime = record.objectForKey("endTime") as? NSDate
                meetingRecord.sectionDate = meetingRecord.startTime!.dateAtStartOfDay()
                
                meetingRecord.meetingOwner = record.objectForKey("meetingOwner") as? String
                meetingRecord.location = venue
                meetingRecord.attending = false
                
                //Save in core data
                CoreDataStackManager.sharedInstance().saveContext()
            }
        })
    }
    func fetchVenueRecord(record:CKRecord, completion:(CKRecord? -> ())) {
        
        // Venue is saved as reference from Meeting Entity
        let venueReference = record.objectForKey("Venue") as? CKReference
        let venueRecordId  = venueReference?.recordID
        
        let publicDatabase:CKDatabase = CKContainer.defaultContainer().publicCloudDatabase
        
        publicDatabase.fetchRecordWithID(venueRecordId, completionHandler: {
            fetchedVenueRecord, error in
            if error != nil {
                println("Error in fetching data \(error)")
                completion(nil)
            } else {
                println("Fetechedrecord is \(fetchedVenueRecord)")
                completion(fetchedVenueRecord)
            }
        })
    }
    

    //MARK:- iCloud Subscription
    
    // If user has subscribed to iCloud Notification, Dont add it again
    // This is saved as part of Persistent Data Storage - NSKeyedArchiver
    func insertIsSubscribedToiCloudNotification() -> Bool {
        
        var insertInfoDictionary:[String:AnyObject]? = nil
        if let infoDic = NSKeyedUnarchiver.unarchiveObjectWithFile(letsMeetFilePath) as? [String:AnyObject] {
            insertInfoDictionary = infoDic
            let iscategoriesInserted = infoDic["isSubscribedToiCloudNotification"] as? Bool
            if iscategoriesInserted == false  {
                insertInfoDictionary!["isSubscribedToiCloudNotification"] = true
                NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
            } else {
             return true
            }
            
        } else {
            // We dont have this dictionary,so insert data and set Archive dictionary
            insertInfoDictionary = ["isSubscribedToiCloudNotification" : true]
            NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
            
        }
        
        return false
    }
    func addNewSubscriptions() {
        
        if subscribed {
            return
        } else if insertIsSubscribedToiCloudNotification() {
            return
        }
        let userRef:CKReference = CKReference(recordID: self.userRecordID, action: .None)
        
        let predicate:NSPredicate = NSPredicate(format: "Users CONTAINS %@", userRef)
        
        // Create a subscription
        let sub: CKSubscription = CKSubscription(recordType: "CloudMeeting", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        // Create a notificaion object
        let notificationInfo:CKNotificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "You've a new meeting! Check it now!"
        notificationInfo.shouldBadge = true
        sub.notificationInfo = notificationInfo
        
        // Save to the database
        let publicDatabase:CKDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.saveSubscription(sub, completionHandler: {
            subscription, error in
            if error != nil {
                println("Error in Sub \(error)")
            } else {
                self.subscribed = true
                self.insertIsSubscribedToiCloudNotification()
                self.listenForBecomeActive()
            }
        })
    }
    func handleNotification(meetingNotification: CKQueryNotification) {
        
        let recordID = meetingNotification.recordID
        
        if meetingNotification.queryNotificationReason == CKQueryNotificationReason.RecordCreated {
        
            //First save this record in core data and then mark as read for iCloud notification
            fetchMeetingRecordbyIdentifier(recordID)
        }
        markNotificationAsRead([meetingNotification.notificationID])
    }
    func markNotificationAsRead(meetings:[CKNotificationID]) {
        let markOp = CKMarkNotificationsReadOperation(
            notificationIDsToMarkRead: meetings)
        CKContainer.defaultContainer().addOperation(markOp)
    }
    
    //MARK:- iCloud Notification
    
    func fetchMeetingRecordbyIdentifier(recordId:CKRecordID) {
        
        let publicDatabase:CKDatabase = container.publicCloudDatabase
        
        publicDatabase.fetchRecordWithID(recordId, completionHandler: {
            fetchedRecord, error in
            if error != nil {
                println("Error in fetching data \(error)")
            } else {
                println("Fetechedrecord is \(fetchedRecord)")
                self.saveMeetingInCoreData(fetchedRecord)
            }
        })
    }
    func getOutstandingNotifications() {
        
        let changeOperation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
        
        changeOperation.notificationChangedBlock = {
            notification in
                if let ckNotification = notification as? CKQueryNotification {
                    self.handleNotification(ckNotification)
                }
        }
        
        changeOperation.fetchNotificationChangesCompletionBlock = {
            serverChangeToken, error in
                if error != nil {
                    println("error fetching notifications \(error)")
                }
                println(serverChangeToken)
        }
        
        CKContainer.defaultContainer().addOperation(changeOperation)
        //changeOperation.start()
    }
    func listenForBecomeActive() {
            NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification,object: nil, queue: NSOperationQueue.mainQueue()) {
                        notification in
                        self.getOutstandingNotifications()
            }
    }
    

}
