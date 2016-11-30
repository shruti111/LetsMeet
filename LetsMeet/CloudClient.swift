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
        container = CKContainer.default()
        
        // Set user's iCloud status as not logged in
        useriCloudLoginStatus = "Not logged in to iCloud"
        super.init()
        
        // Create shared entity
        createNewMeetingEntity()
    }
    
    // MARK:- Shared Meeting Instance
    
    func createNewMeetingEntity() {
        
        // This meeting instance will be shared and saved in core data when user fills all information
        
        let meetingEntity = NSEntityDescription.entity(forEntityName: "Meeting", in: sharedContext)
        meeting = NSManagedObject(entity: meetingEntity!, insertInto: nil) as? Meeting
    }
    
    //MARK:- iCloud User Information
    
    func askUserToEnteriCloudLogin(_ completionHandler :@escaping (_ success:Bool, _ error:NSError?) -> Void)  {
        container.accountStatus(completionHandler: {
        
            accountStatus, error in
           
            if error != nil {
                if error!._code == CKError.networkFailure.rawValue || error!._code == CKError.networkUnavailable.rawValue {
                
                    completionHandler(false, NSError(domain: "LetsMeet iCloudNetworkError", code: 10, userInfo: nil))
                
                } else {
                    
                    completionHandler(false, NSError(domain: "LetsMeet iCloudInternalError", code: 20, userInfo: [NSLocalizedDescriptionKey : "iCloud service unavailable to set up meeting. Please try again later."]))
                }
                
            } else if accountStatus == CKAccountStatus.noAccount {
                
                // User has no account in Settings in iCloud
                completionHandler(false, nil)
                
            } else if accountStatus == CKAccountStatus.available {
                
                self.useriCloudLoginStatus = "Logged in to iCloud"
                
                // Logged in to iCloud
                self.userInfo({
                    receiveduserInfo, error in
                    
                    if error != nil {
                        
                        if error!.code == CKError.networkFailure.rawValue || error!.code == CKError.networkUnavailable.rawValue {
                            
                            completionHandler(false, NSError(domain: "LetsMeet iCloudNetworkError", code: 10, userInfo: nil))
                            
                        } else {
                            
                            completionHandler(false, NSError(domain: "LetsMeet iCloudInternalError", code: 20, userInfo: [NSLocalizedDescriptionKey : "iCloud service unavailable to set up meeting. Please try again later."]))
                        }
                        
                    } else if receiveduserInfo != nil {
                       
                        // Get logged in user's information
                        self.loggedInusersFirstName = receiveduserInfo?.firstName
                        self.loggedInusersLastName = receiveduserInfo?.lastName
                        
                        CloudClient.sharedInstance().meeting?.meetingOwner = CloudClient.sharedInstance().meeting?.getFullName(self.loggedInusersFirstName, lastName: self.loggedInusersLastName)
                        self.useriCloudLoginStatus = "Logged in as \(CloudClient.sharedInstance().meeting!.meetingOwner!)"

                        // Add subscription so when the meeting having this user as particiapnt created, he will get the Push notification
                        self.addNewSubscriptions()
                        
                        // Once the logged in user is discoverbale, we will get contacts from addressbook and CloudKit
                        self.canSearchForAddressbookContacts = true
                        
                        // Retrieve all user's contacts who has installed this app and have iCloud Account
                        AddressBookClient.sharedInstance().getAddressbookContacts()
                        
                        completionHandler(true, nil)

                    } else {
                         completionHandler(true, nil)
                    }
                })
            }
        })
    }
    func userInfo(_ completion: @escaping (_ userInfo: CKDiscoveredUserInfo?, _ error: NSError?)->()) {
        
        // Request user to find out by his iCloud Account
        requestDiscoverability() { discoverable in
            self.userID() { recordID, error in
                if error != nil {
                    completion(nil, error)
                } else {
                    self.userInfoRecord(recordID, completion: completion)
                }
            }
        }
    }
    func requestDiscoverability(_ completion: @escaping (_ discoverable: Bool) -> ()) {
       
        container.status(forApplicationPermission:
            .userDiscoverability) {
                status, error in
                if error != nil || status == CKApplicationPermissionStatus.denied {
                    completion(false)
                } else {
                 self.container.requestApplicationPermission(.userDiscoverability) { status, error in
                        self.container.discoverAllContactUserInfos(completionHandler: {
                            data, error in
                        })
                        
                        completion(status == .granted)
                    }
                }
        }
    }
    
    // This function retrieves user's iCloud Account ID
    func userID(_ completion: @escaping (_ userRecordID: CKRecordID?, _ error: NSError?)->()) {
        if userRecordID != nil {
            completion(userRecordID, nil)
        } else {
            self.container.fetchUserRecordID() {
                recordID, error in
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(recordID, error as NSError?)
            }
        }
    }
    
    func userInfoRecord(_ recordID: CKRecordID!,completion:@escaping (_ userInfo: CKDiscoveredUserInfo?, _ error: NSError?)->()) {
            container.discoverUserInfo(withUserRecordID: recordID,
                completionHandler:completion as! (CKDiscoveredUserInfo?, Error?) -> Void)
    }
    
    // This Function tells us that the user's contact's Email Address is iCloud Account or not
    func userInfoEmail(_ emailId:String,completion:@escaping (_ userInfo: CKDiscoveredUserInfo?, _ error: NSError?)->()) {
        container.discoverUserInfo(withEmailAddress: emailId, completionHandler: completion as! (CKDiscoveredUserInfo?, Error?) -> Void)
    }
   
    //MARK:- Create Meeting in iCloud and Core Data
    
    // Meeting instance is created in iCloud - This sends notification to all the participants
    // Meeting is saved in Core data which has logged in user's information like Reminder
    
    func createMeeting(_ completion:@escaping (_ isRecordSaved:Bool, _ error: NSError?)->()) {
        CloudClient.sharedInstance().meeting?.meetingOwner = CloudClient.sharedInstance().meeting?.getFullName(self.loggedInusersFirstName, lastName: self.loggedInusersLastName)
        if let cloudMeeting = CloudClient.sharedInstance().meeting {
           
            let meetingRecord = CKRecord(recordType: "CloudMeeting")
            meetingRecord.setObject(cloudMeeting.title as CKRecordValue?, forKey: "title")
            meetingRecord.setObject(cloudMeeting.details as CKRecordValue?, forKey: "details")
            meetingRecord.setObject(cloudMeeting.startTime as CKRecordValue?, forKey: "startTime")
            meetingRecord.setObject(cloudMeeting.endTime as CKRecordValue?, forKey: "endTime")
            meetingRecord.setObject(cloudMeeting.meetingOwner as CKRecordValue?, forKey: "meetingOwner")
            
            //Venue
            let venueRecord = CKRecord(recordType: "Venue")
            venueRecord.setObject(cloudMeeting.location?.venueId as CKRecordValue?, forKey: "venueId")
            venueRecord.setObject(cloudMeeting.location?.name as CKRecordValue?, forKey: "venueName")
            venueRecord.setObject(CLLocation(latitude: cloudMeeting.location!.coordinate!.latitude, longitude: cloudMeeting.location!.coordinate!.longitude), forKey: "coordinate")
             venueRecord.setObject(cloudMeeting.location?.formattedAddress as CKRecordValue?, forKey: "formattedAddress")
            venueRecord.setObject(cloudMeeting.location?.imagesURL as CKRecordValue?, forKey: "imagesURL")
            
            
            var inviteesReferences = Array<CKReference>()
            
            //Invitees Reference
            for contact in cloudMeeting.invitees! {
                let inviteeReference = CKReference(recordID: CKRecordID(recordName: contact.cloudRecordId!), action: CKReferenceAction.none)
                print(contact.cloudRecordId!)
                inviteesReferences.append(inviteeReference)
            }
            meetingRecord.setObject(inviteesReferences as CKRecordValue?, forKey: "Users")
           
        let publicDatabase: CKDatabase  = container.publicCloudDatabase
            //Save record
            publicDatabase.save(venueRecord, completionHandler: {
                record, error in
                if error != nil {
                    print(error)
                    completion(false, error as NSError?)
                } else {
                    print(record)
                    
                    let venueReference = CKReference(record: record!, action: CKReferenceAction.none)
                     meetingRecord.setObject(venueReference, forKey: "Venue")
                
                    publicDatabase.save(meetingRecord, completionHandler: {
                        savedRecord, savOperationerror in
                        if savOperationerror != nil {
                             print(savOperationerror)
                             completion(false, savOperationerror as NSError?)
                        } else {
                           print(savedRecord)
                           CloudClient.sharedInstance().meeting?.meetingID = savedRecord!.recordID.recordName
                            self.sharedContext.insert(CloudClient.sharedInstance().meeting!)
                            
                            do {
                                try CoreDataStackManager.sharedInstance().saveContext()
                                CloudClient.sharedInstance().meeting!.scheduleNotification()
                                CloudClient.sharedInstance().createNewMeetingEntity()
                                completion(true, nil)

                            } catch {
                                print("Error while saving.")
                                completion(false, nil)

                            }
                            
//                            if CoreDataStackManager.sharedInstance().saveContext() {
//                                CloudClient.sharedInstance().meeting!.scheduleNotification()
//                                CloudClient.sharedInstance().createNewMeetingEntity()
//                                completion(true, nil)
//                            } else {
//                                completion(false, nil)
//                            }
                        }
                    })
 
                }
            })
        }
        
    }
    func saveMeetingInCoreData(_ record:CKRecord) {
        
        self.fetchVenueRecord(record, completion: {
            venueRecord in
            if venueRecord != nil {
                
                // Venue
                let venueId = venueRecord!.object(forKey: "venueId") as? String
                let venueName = venueRecord!.object(forKey: "venueName") as? String
                let formattedAddress = venueRecord!.object(forKey: "formattedAddress") as? String
                let imagesURL = venueRecord!.object(forKey: "imagesURL") as? Array<String>
                let venueLocation = venueRecord!.object(forKey: "coordinate") as? CLLocation
                
                let venue = Venue(venueId: venueId, name: venueName, coordinate: CLLocationCoordinate2D(latitude: venueLocation!.coordinate.latitude, longitude: venueLocation!.coordinate.longitude), formattedAddress: formattedAddress, imagesURL: imagesURL)
                
                let entity = NSEntityDescription.entity(forEntityName: "Meeting", in: self.sharedContext)!
                
                // Meeting Entity
                let meetingRecord = Meeting(entity: entity, insertInto: self.sharedContext)
                meetingRecord.meetingID = record.recordID.recordName
                meetingRecord.details = record.object(forKey: "details") as? String
                meetingRecord.title = record.object(forKey: "title") as? String
                meetingRecord.startTime = record.object(forKey: "startTime") as? Date
                meetingRecord.endTime = record.object(forKey: "endTime") as? Date
                meetingRecord.sectionDate = (meetingRecord.startTime! as NSDate).dateAtStartOfDay() as Date
                
                meetingRecord.meetingOwner = record.object(forKey: "meetingOwner") as? String
                meetingRecord.location = venue
                meetingRecord.attending = false
                
                //Save in core data
                do {
                    try CoreDataStackManager.sharedInstance().saveContext()
                } catch {
                    print("Error while saving.")
                }
            }
        })
    }
    func fetchVenueRecord(_ record:CKRecord, completion:@escaping ((CKRecord?) -> ())) {
        
        // Venue is saved as reference from Meeting Entity
        let venueReference = record.object(forKey: "Venue") as? CKReference
        let venueRecordId  = venueReference?.recordID
        
        let publicDatabase:CKDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.fetch(withRecordID: venueRecordId!, completionHandler: {
            fetchedVenueRecord, error in
            if error != nil {
                print("Error in fetching data \(error)")
                completion(nil)
            } else {
                print("Fetechedrecord is \(fetchedVenueRecord)")
                completion(fetchedVenueRecord)
            }
        })
    }
    

    //MARK:- iCloud Subscription
    
    // If user has subscribed to iCloud Notification, Dont add it again
    // This is saved as part of Persistent Data Storage - NSKeyedArchiver
    func insertIsSubscribedToiCloudNotification() -> Bool {
        
        var insertInfoDictionary:[String:AnyObject]? = nil
        if let infoDic = NSKeyedUnarchiver.unarchiveObject(withFile: letsMeetFilePath) as? [String:AnyObject] {
            insertInfoDictionary = infoDic
            let iscategoriesInserted = infoDic["isSubscribedToiCloudNotification"] as? Bool
            if iscategoriesInserted == false  {
                insertInfoDictionary!["isSubscribedToiCloudNotification"] = true as AnyObject?
                NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
            } else {
             return true
            }
            
        } else {
            // We dont have this dictionary,so insert data and set Archive dictionary
            insertInfoDictionary = ["isSubscribedToiCloudNotification" : true as AnyObject]
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
        let userRef:CKReference = CKReference(recordID: self.userRecordID, action: .none)
        
        let predicate:NSPredicate = NSPredicate(format: "Users CONTAINS %@", userRef)
        
        // Create a subscription
        let sub: CKSubscription = CKSubscription(recordType: "CloudMeeting", predicate: predicate, options: CKSubscriptionOptions.firesOnRecordCreation)
        
        // Create a notificaion object
        let notificationInfo:CKNotificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "You've a new meeting! Check it now!"
        notificationInfo.shouldBadge = true
        sub.notificationInfo = notificationInfo
        
        // Save to the database
        let publicDatabase:CKDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(sub, completionHandler: {
            subscription, error in
            if error != nil {
                print("Error in Sub \(error)")
            } else {
                self.subscribed = true
                self.insertIsSubscribedToiCloudNotification()
                self.listenForBecomeActive()
            }
        })
    }
    func handleNotification(_ meetingNotification: CKQueryNotification) {
        
        let recordID = meetingNotification.recordID
        
        if meetingNotification.queryNotificationReason == CKQueryNotificationReason.recordCreated {
        
            //First save this record in core data and then mark as read for iCloud notification
            fetchMeetingRecordbyIdentifier(recordID!)
        }
        markNotificationAsRead([meetingNotification.notificationID!])
    }
    func markNotificationAsRead(_ meetings:[CKNotificationID]) {
        let markOp = CKMarkNotificationsReadOperation(
            notificationIDsToMarkRead: meetings)
        CKContainer.default().add(markOp)
    }
    
    //MARK:- iCloud Notification
    
    func fetchMeetingRecordbyIdentifier(_ recordId:CKRecordID) {
        
        let publicDatabase:CKDatabase = container.publicCloudDatabase
        
        publicDatabase.fetch(withRecordID: recordId, completionHandler: {
            fetchedRecord, error in
            if error != nil {
                print("Error in fetching data \(error)")
            } else {
                print("Fetechedrecord is \(fetchedRecord)")
                self.saveMeetingInCoreData(fetchedRecord!)
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
                    print("error fetching notifications \(error)")
                }
                print(serverChangeToken)
        }
        
        CKContainer.default().add(changeOperation)
        //changeOperation.start()
    }
    func listenForBecomeActive() {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive,object: nil, queue: OperationQueue.main) {
                        notification in
                        self.getOutstandingNotifications()
            }
    }
    

}
