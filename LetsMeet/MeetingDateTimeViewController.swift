//
//  MeetingDateTimeViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 25/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

let dateFormatterToGetOnlyDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateFormat = "EEEE, MMMM d"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
    }()

let meetingdateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
    }()

let noTimedateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
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
    var startDate:Date?
    var endDate:Date?
    var isPopUp = true
    
    // This View controller uses same presentation style as MeetingDataTitleViewController
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
      
        // Set the border and corner radius for UI elements
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = applicationThemeColor().cgColor
        popupView.layer.cornerRadius = 5
        
        startTimeLabel.layer.borderWidth = 0.5
        startTimeLabel.layer.borderColor = applicationThemeColor().cgColor
        
        endTimeLabel.layer.borderWidth = 0.5
        endTimeLabel.layer.borderColor = applicationThemeColor().cgColor
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = applicationThemeColor().cgColor
        cancelButton.layer.cornerRadius = doneButton.frame.size.height / 2
        
        // Dismiss view controller when tapped outside the view
        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingDateTimeViewController.close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            view.backgroundColor = landingScreenButtonColor()
        }
        
        // Start time and end time labels tap to change the datepicker control's cate
        let startLabelgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingDateTimeViewController.startDateTimeLabelTapped))
        startTimeLabel.addGestureRecognizer(startLabelgestureRecognizer)
        
        let endLabelgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingDateTimeViewController.endDateTimeLabelTapped))
        endTimeLabel.addGestureRecognizer(endLabelgestureRecognizer)
        
        updateUI()
    }
    
    // Change the date time label and date picker control's date when startDateTimelabel is tapped
    func startDateTimeLabelTapped() {
        startTimeLabel.backgroundColor = dateTimeLabelBackgroundColor()
        endTimeLabel.backgroundColor = landingScreenButtonColor()
        datePicker.date = startDate!
        datetimeLabelInFocus = startTimeLabel
        errroLabel.isHidden = true
    }
    
    // Change the date time label and date picker control's date when endDateTimelabel is tapped
    func endDateTimeLabelTapped() {
        endTimeLabel.backgroundColor = dateTimeLabelBackgroundColor()
        startTimeLabel.backgroundColor = landingScreenButtonColor()
        datePicker.date = endDate!
        datetimeLabelInFocus = endTimeLabel
        errroLabel.isHidden = true
    }
    
    
    func updateUI() {
        
        popupView.isHidden = false
       
        // We will not allow user to select past date - this will prevent validation check for past date
        datePicker.minimumDate = Date()
        
        // Set the start and end time date label based on user selection
        if CloudClient.sharedInstance().meeting?.startTime != nil {
            startDate = CloudClient.sharedInstance().meeting?.startTime! as Date?
        } else {
            startDate = Date()
            
        }
        startTimeLabel.text = "Start " + formatDate(startDate!)
        
        if CloudClient.sharedInstance().meeting?.endTime != nil {
            endDate = CloudClient.sharedInstance().meeting?.endTime! as Date?
        } else {
            endDate = (Date() as NSDate).dateByAddingHours(dHours: 1) as Date
        }
         endTimeLabel.text = "End " + formatDate(endDate!)
         datePicker.date = startDate!
         datetimeLabelInFocus = startTimeLabel

    }
    
    // Format date to show date in specific style
    func formatDate(_ date: Date) -> String {
        return meetingdateFormatter.string(from: date)
    }
    
    @IBAction func close() {
       
        // Update properties of Meeting Object
        if !isMeetingTimeValid() {
            errroLabel.isHidden = false
            
        } else {
            
            CloudClient.sharedInstance().meeting?.startTime = startDate
            CloudClient.sharedInstance().meeting?.endTime = endDate
            let onlyStringDate = noTimedateFormatter.string(from: startDate!)
            let dateOnly = noTimedateFormatter.date(from: onlyStringDate)
            let timeZoneSeconds = NSTimeZone.local.secondsFromGMT()
            let  dateInLocalTimezone = dateOnly!.addingTimeInterval(TimeInterval(timeZoneSeconds))
            CloudClient.sharedInstance().meeting?.sectionDate = dateInLocalTimezone
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        
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
                if (startDate as NSDate).isLaterThanDate(aDate: endDate as NSDate) {
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
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController??, source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationViewController(presentedViewController: presented, presenting: presenting!)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === view)
    }
}
