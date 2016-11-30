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
    let manager = FileManager.default
    let url = manager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first as URL!
    return url!.appendingPathComponent("letsMeetArchive").path
    //return url.URLByAppendingPathComponent("letsMeetArchive").path!
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
        createMeetingButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LandingViewController.createMeeting(_:)))
        savingMeetingActivityIndicator  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
       let activityIndicatorbarbuttonItem = UIBarButtonItem(customView: savingMeetingActivityIndicator!)
        navigationItem.rightBarButtonItems = [createMeetingButton, activityIndicatorbarbuttonItem]
        
        customizeUI()
        
        // First, retrieve the user's iCloud Information, like name and contact list
        //TODO: - REMOVE
        //askUserToEnteriCloudLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: - REMOVE
       // updateButtonsState()
    }
    
   
    func updateButtonsState() {
        
        // Update UI states based on the data entered by the user
        if let cloudeMeeting = CloudClient.sharedInstance().meeting  {
            
            if cloudeMeeting.title != nil {
                 titleButton.layer.backgroundColor = landingScreenFilledButtonColor().cgColor
                 titleButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.startTime != nil && cloudeMeeting.endTime != nil {
                timeButton.layer.backgroundColor = landingScreenFilledButtonColor().cgColor
                timeButton.tintColor = landingScreenFilledButtonTintColor()
                
                if cloudeMeeting.isReminderSeen {
                    remindersButton.layer.backgroundColor = landingScreenFilledButtonColor().cgColor
                    remindersButton.tintColor = landingScreenFilledButtonTintColor()
                }
            }
            
            if cloudeMeeting.invitees != nil  {
                participantsButton.layer.backgroundColor = landingScreenFilledButtonColor().cgColor
                participantsButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.location != nil {
                locationButton.layer.backgroundColor = landingScreenFilledButtonColor().cgColor
                locationButton.tintColor = landingScreenFilledButtonTintColor()
            }
            
            if cloudeMeeting.title != nil && cloudeMeeting.invitees != nil && cloudeMeeting.startTime != nil && cloudeMeeting.endTime != nil && cloudeMeeting.location != nil {
                createMeetingButton.isEnabled = true
                
            } else {
                createMeetingButton.isEnabled = false
            }
        }
    }
    
    func resetAllButtons() {
        
        // During, data base and iCloud processing, disable all buttons to prevent un-necessary call
        
        UIView.animate(withDuration: 0.5, animations: {
        self.titleButton.layer.backgroundColor = landingScreenButtonColor().cgColor
        self.titleButton.tintColor = applicationThemeColor()
        
        self.timeButton.layer.backgroundColor = landingScreenButtonColor().cgColor
        self.timeButton.tintColor = applicationThemeColor()
        
        self.participantsButton.layer.backgroundColor = landingScreenButtonColor().cgColor
        self.participantsButton.tintColor = applicationThemeColor()
        
        self.locationButton.layer.backgroundColor = landingScreenButtonColor().cgColor
        self.locationButton.tintColor = applicationThemeColor()
        
        self.remindersButton.layer.backgroundColor = landingScreenButtonColor().cgColor
        self.remindersButton.tintColor = applicationThemeColor()
        
        self.createMeetingButton.isEnabled = false
        self.titleButton.isEnabled = true
        self.participantsButton.isEnabled = true
        self.timeButton.isEnabled = true
        self.locationButton.isEnabled = true
        self.remindersButton.isEnabled = true
        })
    }
    
    func disableAllButtons() {
        titleButton.isEnabled = false
        participantsButton.isEnabled = false
        timeButton.isEnabled = false
        locationButton.isEnabled = false
        remindersButton.isEnabled = false
        createMeetingButton.isEnabled = false
    }
    
    func askUserToEnteriCloudLogin() {
        CloudClient.sharedInstance().askUserToEnteriCloudLogin({
            success, error in
            if error != nil {
                
                if error?.domain == "LetsMeet iCloudNetworkError" {
                    let alert = UIAlertController(title: "Could not connect", message: "Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                } else {
                let alert = UIAlertController(title: "iCloud service error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                }
            } else {
            if !success {
                let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to create meetings. On the Home screen, launch Settings,tap iCloud, and ente your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            }
        })
    }
    
    func customizeUI() {
      
       // Set UI for border and round button appearance
        
        savingMeetingActivityIndicator?.color =  landingScreenFilledButtonTintColor()

//       participantsButton.layer.borderWidth = 0.5
//       participantsButton.layer.borderColor = applicationThemeColor().cgColor
//       participantsButton.layer.cornerRadius = participantsButton.frame.size.height / 2
//       participantsButton.clipsToBounds = true
//       participantsButton.tintColor = applicationThemeColor()
        
        
        participantsButton.layer.borderWidth = 0.5
        participantsButton.layer.borderColor = applicationThemeColor().cgColor
        participantsButton.layer.cornerRadius = titleButton.frame.size.height / 2
        participantsButton.clipsToBounds = true
        participantsButton.tintColor = applicationThemeColor()
        
        titleButton.layer.borderWidth = 0.5
        titleButton.layer.borderColor = applicationThemeColor().cgColor
        titleButton.layer.cornerRadius = titleButton.frame.size.height / 2
        titleButton.clipsToBounds = true
        titleButton.tintColor = applicationThemeColor()
        
        locationButton.layer.borderWidth = 0.5
        locationButton.layer.borderColor = applicationThemeColor().cgColor
        locationButton.layer.cornerRadius = locationButton.frame.size.height / 2
        locationButton.clipsToBounds = true
        locationButton.tintColor = applicationThemeColor()
        
        timeButton.layer.borderWidth = 0.5
        timeButton.layer.borderColor = applicationThemeColor().cgColor
        timeButton.layer.cornerRadius = timeButton.frame.size.height / 2
        timeButton.clipsToBounds = true
        timeButton.tintColor = applicationThemeColor()
        
        remindersButton.layer.borderWidth = 0.5
        remindersButton.layer.borderColor = applicationThemeColor().cgColor
        remindersButton.layer.cornerRadius = remindersButton.frame.size.height / 2
        remindersButton.clipsToBounds = true
        remindersButton.tintColor = applicationThemeColor()
        
    }
       
    @IBAction func addLocation(_ sender: UIButton) {
        
        // Insert categories from Foursquare to core data
        insertCategoriesInCoreData()
    }
    
    // Categories are inserted only once and its flag is set the NSArchiver
    func insertCategories() {
        let insertCategoriesInfoDictionary = [
            "isInserted" : true,
            "lastInsertedDate" : Date()
        ] as [String : Any]
        Client.sharedInstance().getFoursquareCategories({
            results, error in
            print(error)
            
            if error == nil {
                NSKeyedArchiver.archiveRootObject(insertCategoriesInfoDictionary, toFile: letsMeetFilePath)
            }
        })
    }
    
    func insertCategoriesInCoreData() {
        
        var insertInfoDictionary:[String:AnyObject]? = nil
        if let infoDic = NSKeyedUnarchiver.unarchiveObject(withFile: letsMeetFilePath) as? [String:AnyObject] {
            
            insertInfoDictionary = infoDic
            
            let iscategoriesInserted = insertInfoDictionary!["isInserted"] as? Bool
            let lastInsertDate = insertInfoDictionary!["lastInsertedDate"] as? Date

           
            if iscategoriesInserted == false || lastInsertDate == nil {
                Client.sharedInstance().getFoursquareCategories({
                    results, error in
                    print(error)
                    
                    if error == nil {
                        insertInfoDictionary!["isInserted"] = true as AnyObject?
                        insertInfoDictionary!["lastInsertedDate"] = Date() as AnyObject?
                        NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
                    }
                })
                
            }
            
        } else {
            // We dont have this dictionary,so insert data and set Archive dictionary
            Client.sharedInstance().getFoursquareCategories({
                results, error in
                print(error)
                
                if error == nil {
                    insertInfoDictionary = [
                        "isInserted" : true as AnyObject,
                        "lastInsertedDate" : Date() as AnyObject]

                    NSKeyedArchiver.archiveRootObject(insertInfoDictionary!, toFile: letsMeetFilePath)
                }
            })
            
        }
    }

    // Create meeting in iCloud
    //Send Notification to the paricipants
    // Save meeting to core data
    // If user has set reminder, set the local notification
    
    @IBAction func createMeeting(_ sender: UIBarButtonItem) {
    
        // This will create meeting in the cloud
        
        savingMeetingActivityIndicator?.startAnimating()
        
        disableAllButtons()
        
        CloudClient.sharedInstance().createMeeting({
            isRecordSaved, error in
             DispatchQueue.main.async(execute: {
                if error == nil  && isRecordSaved {
                    
                    // Data saved successfully message
                    let alert = UIAlertController(title: "Success", message: "Meeting created successfully", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Create Meeting Error", message: "We could not save meeting. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                self.resetAllButtons()
                self.savingMeetingActivityIndicator?.stopAnimating()
             })
        })
        
    }
    
    

}
