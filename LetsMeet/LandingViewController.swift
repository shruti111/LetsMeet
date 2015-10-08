//
//  LandingViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 15/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CloudKit

// NSArchiverFile Path
var letsMeetFilePath: String {
    let manager = NSFileManager.defaultManager()
    let url = manager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
    return url.URLByAppendingPathComponent("letsMeetArchive").path!
}

class LandingViewController: UIViewController {

    @IBOutlet weak var participantsButton: UIButton!
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var remindersButton: UIButton!
    
    var savingMeetingActivityIndicator:UIActivityIndicatorView?
    var createMeetingButton: UIBarButtonItem!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Show meeting Create button and activity indicator view in title bar
        createMeetingButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("createMeeting:"))
        savingMeetingActivityIndicator  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
       let activityIndicatorbarbuttonItem = UIBarButtonItem(customView: savingMeetingActivityIndicator!)
        navigationItem.rightBarButtonItems = [createMeetingButton, activityIndicatorbarbuttonItem]
        
        customizeUI()
        
        // First, retrieve the user's iCloud Information, like name and contact list
        askUserToEnteriCloudLogin()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonsState()
    }
    
   
    func updateButtonsState() {
        
        // Update UI states based on the data entered by the user
        if let cloudeMeeting = CloudClient.sharedInstance().meeting  {
            
            if cloudeMeeting.title != nil {
                 titleButton.layer.backgroundColor = landingScreenFilledButtonColor().CGColor
                 titleButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.startTime != nil && cloudeMeeting.endTime != nil {
                timeButton.layer.backgroundColor = landingScreenFilledButtonColor().CGColor
                timeButton.tintColor = landingScreenFilledButtonTintColor()
                
                if cloudeMeeting.isReminderSeen {
                    remindersButton.layer.backgroundColor = landingScreenFilledButtonColor().CGColor
                    remindersButton.tintColor = landingScreenFilledButtonTintColor()
                }
            }
            
            if cloudeMeeting.invitees != nil  {
                participantsButton.layer.backgroundColor = landingScreenFilledButtonColor().CGColor
                participantsButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.location != nil {
                locationButton.layer.backgroundColor = landingScreenFilledButtonColor().CGColor
                locationButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.title != nil && cloudeMeeting.invitees != nil && cloudeMeeting.startTime != nil && cloudeMeeting.endTime != nil && cloudeMeeting.location != nil {
                createMeetingButton.enabled = true
                
            } else {
                createMeetingButton.enabled = false
            }
        }
    }
    
    func resetAllButtons() {
        
        // During, data base and iCloud processing, disable all buttons to prevent un-necessary call
        
        UIView.animateWithDuration(0.5, animations: {
        self.titleButton.layer.backgroundColor = landingScreenButtonColor().CGColor
        self.titleButton.tintColor = applicationThemeColor()
        
        self.timeButton.layer.backgroundColor = landingScreenButtonColor().CGColor
        self.timeButton.tintColor = applicationThemeColor()
        
        self.participantsButton.layer.backgroundColor = landingScreenButtonColor().CGColor
        self.participantsButton.tintColor = applicationThemeColor()
        
        self.locationButton.layer.backgroundColor = landingScreenButtonColor().CGColor
        self.locationButton.tintColor = applicationThemeColor()
        
        self.remindersButton.layer.backgroundColor = landingScreenButtonColor().CGColor
        self.remindersButton.tintColor = applicationThemeColor()
        
        self.createMeetingButton.enabled = false
        self.titleButton.enabled = true
        self.participantsButton.enabled = true
        self.timeButton.enabled = true
        self.locationButton.enabled = true
        self.remindersButton.enabled = true
        })
    }
    
    func disableAllButtons() {
        titleButton.enabled = false
        participantsButton.enabled = false
        timeButton.enabled = false
        locationButton.enabled = false
        remindersButton.enabled = false
        createMeetingButton.enabled = false
    }
    
    func askUserToEnteriCloudLogin() {
        CloudClient.sharedInstance().askUserToEnteriCloudLogin({
            success, error in
            if error != nil {
                
                if error?.domain == "LetsMeet iCloudNetworkError" {
                    let alert = UIAlertController(title: "Could not connect", message: "Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                } else {
                let alert = UIAlertController(title: "iCloud service error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
            if !success {
                let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to create meetings. On the Home screen, launch Settings,tap iCloud, and ente your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            }
        })
    }
    
    func customizeUI() {
      
       // Set UI for border and round button appearance
        
        savingMeetingActivityIndicator?.color =  landingScreenFilledButtonTintColor()

       participantsButton.layer.borderWidth = 0.5
       participantsButton.layer.borderColor = applicationThemeColor().CGColor
       participantsButton.layer.cornerRadius = participantsButton.frame.size.height / 2
       participantsButton.clipsToBounds = true
       participantsButton.tintColor = applicationThemeColor()
        
        titleButton.layer.borderWidth = 0.5
        titleButton.layer.borderColor = applicationThemeColor().CGColor
        titleButton.layer.cornerRadius = titleButton.frame.size.height / 2
        titleButton.clipsToBounds = true
        titleButton.tintColor = applicationThemeColor()
        
        locationButton.layer.borderWidth = 0.5
        locationButton.layer.borderColor = applicationThemeColor().CGColor
        locationButton.layer.cornerRadius = locationButton.frame.size.height / 2
        locationButton.clipsToBounds = true
        locationButton.tintColor = applicationThemeColor()
        
        timeButton.layer.borderWidth = 0.5
        timeButton.layer.borderColor = applicationThemeColor().CGColor
        timeButton.layer.cornerRadius = timeButton.frame.size.height / 2
        timeButton.clipsToBounds = true
        timeButton.tintColor = applicationThemeColor()
        
        remindersButton.layer.borderWidth = 0.5
        remindersButton.layer.borderColor = applicationThemeColor().CGColor
        remindersButton.layer.cornerRadius = remindersButton.frame.size.height / 2
        remindersButton.clipsToBounds = true
        remindersButton.tintColor = applicationThemeColor()
        
    }
       
    @IBAction func addLocation(sender: UIButton) {
        
        // Insert categories from Foursquare to core data
        insertCategoriesInCoreData()
    }
    
    // Categories are inserted only once and its flag is set the NSArchiver
    func insertCategories() {
        let insertCategoriesInfoDictionary = [
            "isInserted" : true,
            "lastInsertedDate" : NSDate()
        ]
        Client.sharedInstance().getFoursquareCategories({
            results, error in
            println(error)
            
            if error == nil {
                NSKeyedArchiver.archiveRootObject(insertCategoriesInfoDictionary, toFile: letsMeetFilePath)
            }
        })
    }
    
    func insertCategoriesInCoreData() {
        
        var insertInfoDictionary:[String:AnyObject]? = nil
        if let infoDic = NSKeyedUnarchiver.unarchiveObjectWithFile(letsMeetFilePath) as? [String:AnyObject] {
            
            insertInfoDictionary = infoDic
            
            let iscategoriesInserted = insertInfoDictionary!["isInserted"] as? Bool
            let lastInsertDate = insertInfoDictionary!["lastInsertedDate"] as? NSDate

           
            if iscategoriesInserted == false || lastInsertDate == nil {
                Client.sharedInstance().getFoursquareCategories({
                    results, error in
                    println(error)
                    
                    if error == nil {
                        insertInfoDictionary!["isInserted"] = true
                        insertInfoDictionary!["lastInsertedDate"] = NSDate()
                        NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
                    }
                })
                
            }
            
        } else {
            // We dont have this dictionary,so insert data and set Archive dictionary
            Client.sharedInstance().getFoursquareCategories({
                results, error in
                println(error)
                
                if error == nil {
                    insertInfoDictionary = [
                        "isInserted" : true,
                        "lastInsertedDate" : NSDate()]

                    NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
                }
            })
            
        }
    }

    // Create meeting in iCloud
    //Send Notification to the paricipants
    // Save meeting to core data
    // If user has set reminder, set the local notification
    
    @IBAction func createMeeting(sender: UIBarButtonItem) {
    
        // This will create meeting in the cloud
        
        savingMeetingActivityIndicator?.startAnimating()
        
        disableAllButtons()
        
        CloudClient.sharedInstance().createMeeting({
            isRecordSaved, error in
             dispatch_async(dispatch_get_main_queue(), {
                if error == nil  && isRecordSaved {
                    
                    // Data saved successfully message
                    let alert = UIAlertController(title: "Success", message: "Meeting created successfully", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Create Meeting Error", message: "We could not save meeting. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                self.resetAllButtons()
                self.savingMeetingActivityIndicator?.stopAnimating()
             })
        })
        
    }
    
    

}
