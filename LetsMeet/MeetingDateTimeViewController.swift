//
//  MeetingDateTimeViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 25/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

let dateFormatterToGetOnlyDate: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "EEEE, MMMM d"
    formatter.timeZone = NSTimeZone.localTimeZone()
    return formatter
    }()

let meetingdateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
    }()

let noTimedateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .NoStyle
    return formatter
    }()

class MeetingDateTimeViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var errroLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var datetimeLabelInFocus:UILabel?
    var startDate:NSDate?
    var endDate:NSDate?
    var isPopUp = true
    
    // This View controller uses same presentation style as MeetingDataTitleViewController
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
      
        // Set the border and corner radius for UI elements
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = applicationThemeColor().CGColor
        popupView.layer.cornerRadius = 5
        
        startTimeLabel.layer.borderWidth = 0.5
        startTimeLabel.layer.borderColor = applicationThemeColor().CGColor
        
        endTimeLabel.layer.borderWidth = 0.5
        endTimeLabel.layer.borderColor = applicationThemeColor().CGColor
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = applicationThemeColor().CGColor
        cancelButton.layer.cornerRadius = doneButton.frame.size.height / 2
        
        // Dismiss view controller when tapped outside the view
        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            view.backgroundColor = landingScreenButtonColor()
        }
        
        // Start time and end time labels tap to change the datepicker control's cate
        let startLabelgestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("startDateTimeLabelTapped"))
        startTimeLabel.addGestureRecognizer(startLabelgestureRecognizer)
        
        let endLabelgestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("endDateTimeLabelTapped"))
        endTimeLabel.addGestureRecognizer(endLabelgestureRecognizer)
        
        updateUI()
    }
    
    // Change the date time label and date picker control's date when startDateTimelabel is tapped
    func startDateTimeLabelTapped() {
        startTimeLabel.backgroundColor = dateTimeLabelBackgroundColor()
        endTimeLabel.backgroundColor = landingScreenButtonColor()
        datePicker.date = startDate!
        datetimeLabelInFocus = startTimeLabel
        errroLabel.hidden = true
    }
    
    // Change the date time label and date picker control's date when endDateTimelabel is tapped
    func endDateTimeLabelTapped() {
        endTimeLabel.backgroundColor = dateTimeLabelBackgroundColor()
        startTimeLabel.backgroundColor = landingScreenButtonColor()
        datePicker.date = endDate!
        datetimeLabelInFocus = endTimeLabel
        errroLabel.hidden = true
    }
    
    
    func updateUI() {
        
        popupView.hidden = false
       
        // We will not allow user to select past date - this will prevent validation check for past date
        datePicker.minimumDate = NSDate()
        
        // Set the start and end time date label based on user selection
        if CloudClient.sharedInstance().meeting?.startTime != nil {
            startDate = CloudClient.sharedInstance().meeting?.startTime!
        } else {
            startDate = NSDate()
            
        }
        startTimeLabel.text = "Start " + formatDate(startDate!)
        
        if CloudClient.sharedInstance().meeting?.endTime != nil {
            endDate = CloudClient.sharedInstance().meeting?.endTime!
        } else {
            endDate = NSDate().dateByAddingHours(1)
        }
         endTimeLabel.text = "End " + formatDate(endDate!)
         datePicker.date = startDate!
         datetimeLabelInFocus = startTimeLabel

    }
    
    // Format date to show date in specific style
    func formatDate(date: NSDate) -> String {
        return meetingdateFormatter.stringFromDate(date)
    }
    
    @IBAction func close() {
       
        // Update properties of Meeting Object
        if !isMeetingTimeValid() {
            errroLabel.hidden = false
            
        } else {
            
            CloudClient.sharedInstance().meeting?.startTime = startDate
            CloudClient.sharedInstance().meeting?.endTime = endDate
            let onlyStringDate = noTimedateFormatter.stringFromDate(startDate!)
            let dateOnly = noTimedateFormatter.dateFromString(onlyStringDate)
            let timeZoneSeconds = NSTimeZone.localTimeZone().secondsFromGMT
            let  dateInLocalTimezone = dateOnly!.dateByAddingTimeInterval(NSTimeInterval(timeZoneSeconds))
            CloudClient.sharedInstance().meeting?.sectionDate = dateInLocalTimezone
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        
        if datetimeLabelInFocus === startTimeLabel {
            startTimeLabel.text = "Start " + formatDate(sender.date)
            startDate = sender.date

        } else if datetimeLabelInFocus === endTimeLabel {
            endTimeLabel.text = "End " + formatDate(sender.date)
            endDate = sender.date
        }
    }
    
    // Validation - Start time should be before end time 
    func isMeetingTimeValid() -> Bool {
       
        if  let startDate = startDate {
            if let endDate = endDate {
                if startDate.isLaterThanDate(endDate) {
                    errroLabel.text = "Start date must be before end date"
                    return false
                }
            } else {
                errroLabel.text = "Select end date"
                return false
            }
            
        } else {
            errroLabel.text = "Select start date"
            return false
        }
        
        return true
    }
}


extension MeetingDateTimeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationViewController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let tabbarController = dismissed.presentingViewController as! UITabBarController
        
        if let tabbarViewControllers = tabbarController.viewControllers {
            let landingnavigationController = tabbarViewControllers[0] as! UINavigationController
            let landingViewController = landingnavigationController.topViewController as! LandingViewController
            landingViewController.updateButtonsState()
        }
        
        return SlideOutAnimationController()
    }
}

extension MeetingDateTimeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === view)
    }
}
