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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showuseriCloudLoginStatus()
    }
    
    func showuseriCloudLoginStatus() {
        icloudLoginLabel.text = CloudClient.sharedInstance().useriCloudLoginStatus
    }
    
    // This opens twitter application and not installed in browser
    func shareOnTwitter() {
        let tweetbot = URL(string: "tweetbot://current/user_profile/shrutichoksi111")!
        let twitterrific = URL(string: "twitterrific://current/profile?screen_name=shrutichoksi111")!
        let twitter = URL(string: "twitter://user?screen_name=shrutichoksi111")!
        let safari = URL(string: "https://twitter.com/shrutichoksi111")!
        
        if UIApplication.shared.canOpenURL(tweetbot) {
            UIApplication.shared.openURL(tweetbot)
        } else {
            if UIApplication.shared.canOpenURL(twitterrific) {
                UIApplication.shared.openURL(twitterrific)
            } else {
                if UIApplication.shared.canOpenURL(twitter) {
                    UIApplication.shared.openURL(twitter)
                } else {
                    if UIApplication.shared.canOpenURL(safari) {
                        UIApplication.shared.openURL(safari)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
        }

    }
    
    // Share github link of this project from different application like LinkedIn, Facebook, WhatsApp which are installed in user's phone
    
    func share() {
        let url = URL(string: "https://github.com/shruti111")!
        let string = NSLocalizedString("Let's Meet", comment: "")
        let activityViewController = UIActivityViewController(activityItems: [string, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
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
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Failed to send mail", comment: ""), message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }

    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController!, didFinishWith result: MFMailComposeResult, error: Error!) {
        dismiss(animated: true, completion: nil)
    }
    
    // Open application url based on table view cell selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var url:URL!
        
        if (indexPath as NSIndexPath).section == 1 {
            
            if (indexPath as NSIndexPath).item == 0 {
               share()
            } else if (indexPath as NSIndexPath).item == 1 {
                mail()
            } else if (indexPath as NSIndexPath).item == 2 {
                shareOnTwitter()
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            switch (indexPath as NSIndexPath).item {
            case 0:
                url = URL(string: "https://www.udacity.com/")
            case 1:
                url = URL(string: "https://foursquare.com")
            case 2:
                url = URL(string: "http://www.appcoda.com/cloudkit-introduction-tutorial/")
            case 3:
                url = URL(string: "http://www.raywenderlich.com")
            case 4:
                url = URL(string: "https://github.com/tristanhimmelman/THContactPicker")
            case 5:
                url = URL(string: "https://github.com/fwhenin/Swift-NSDate-Extensions")
            default:
                break
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    

}
