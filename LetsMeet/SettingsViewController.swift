//
//  SettingsViewController.swift
//  LetsMeet
//
//  Created by Shruti on 27/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import MessageUI

// This is About view controller to give option to share Application Information and feedback 
// It also shows user the logged in detial of iCloud

class SettingsViewController: UITableViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var icloudLoginLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showuseriCloudLoginStatus()
    }
    
    func showuseriCloudLoginStatus() {
        icloudLoginLabel.text = CloudClient.sharedInstance().useriCloudLoginStatus
    }
    
    // This opens twitter application and not installed in browser
    func shareOnTwitter() {
        let tweetbot = NSURL(string: "tweetbot://current/user_profile/shrutichoksi111")!
        let twitterrific = NSURL(string: "twitterrific://current/profile?screen_name=shrutichoksi111")!
        let twitter = NSURL(string: "twitter://user?screen_name=shrutichoksi111")!
        let safari = NSURL(string: "https://twitter.com/shrutichoksi111")!
        
        if UIApplication.sharedApplication().canOpenURL(tweetbot) {
            UIApplication.sharedApplication().openURL(tweetbot)
        } else {
            if UIApplication.sharedApplication().canOpenURL(twitterrific) {
                UIApplication.sharedApplication().openURL(twitterrific)
            } else {
                if UIApplication.sharedApplication().canOpenURL(twitter) {
                    UIApplication.sharedApplication().openURL(twitter)
                } else {
                    if UIApplication.sharedApplication().canOpenURL(safari) {
                        UIApplication.sharedApplication().openURL(safari)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .Alert)
                        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        }
                        alert.addAction(ok)
                        presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }

    }
    
    // Share github link of this project from different application like LinkedIn, Facebook, WhatsApp which are installed in user's phone
    
    func share() {
        let url = NSURL(string: "https://github.com/shruti111")!
        let string = NSLocalizedString("Let's Meet", comment: "")
        let activityViewController = UIActivityViewController(activityItems: [string, url], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Send mail to the user sharing application's github link
    
    func mail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["shrutichoksi111@gmail.com"])
            mailComposeViewController.setSubject("Let's Meet!")
            
            var body = "<br><br>"
            body += "<hr>"
            body += "https://github.com/shruti111" + "<br>"
            body += "<hr>"
        
            mailComposeViewController.setMessageBody(body, isHTML: true)
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Failed to send mail", comment: ""), message: nil, preferredStyle: .Alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Open application url based on table view cell selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        var url:NSURL!
        
        if indexPath.section == 1 {
            
            if indexPath.item == 0 {
               share()
            } else if indexPath.item == 1 {
                mail()
            } else if indexPath.item == 2 {
                shareOnTwitter()
            }
        } else if indexPath.section == 2 {
            switch indexPath.item {
            case 0:
                url = NSURL(string: "https://www.udacity.com/")
            case 1:
                url = NSURL(string: "https://foursquare.com")
            case 2:
                url = NSURL(string: "http://www.appcoda.com/cloudkit-introduction-tutorial/")
            case 3:
                url = NSURL(string: "http://www.raywenderlich.com")
            case 4:
                url = NSURL(string: "https://github.com/tristanhimmelman/THContactPicker")
            case 5:
                url = NSURL(string: "https://github.com/fwhenin/Swift-NSDate-Extensions")
            default:
                break
            }
            
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .Alert)
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    

}
