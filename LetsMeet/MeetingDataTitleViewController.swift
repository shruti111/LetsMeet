//
//  MeetingDataTitleViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 22/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

// This View Controller is modally presented, with Custom Presentation style.
// This presentation style is defined in DimmingPresentationViewController and when presented it is layered by BounceAnimationController
// The dismiss style is defined in SlideOutAnimationController

class MeetingDataTitleViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var descriptiontextView: UITextView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var isCancelButtonTapped:Bool = true
    var viewcontrollerTitle:String = "title"
    var isPopUp = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Define presentation style while shwoing controller modally
        modalPresentationStyle = .custom
        
        // To provide trainsiton
        transitioningDelegate = self
    }
    override func viewDidLoad() {
       super.viewDidLoad()
       self.title = viewcontrollerTitle
        
        // Layer border and style for viewcontroller's view , and text field
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = applicationThemeColor().cgColor
        popupView.layer.cornerRadius = 5
        
        titleTextView.layer.borderWidth = 0.5
        titleTextView.layer.borderColor = applicationThemeColor().cgColor
        
        descriptiontextView.layer.borderWidth = 0.5
        descriptiontextView.layer.borderColor = applicationThemeColor().cgColor
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = applicationThemeColor().cgColor
        cancelButton.layer.cornerRadius = doneButton.frame.size.height / 2
        
        // The view is shown in form of pop up
        // Tap gesture to dismiss this view
        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingDataTitleViewController.close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
            // Clear background color will show only pop up view from view hiearchy
            view.backgroundColor = landingScreenButtonColor()
        }
        
        // Update title and description fields, if the data is already enetered
        updateUI()
    }
    
    func updateUI() {
        
        popupView.isHidden = false
        
        if CloudClient.sharedInstance().meeting?.title != nil {
            titleTextView.text = CloudClient.sharedInstance().meeting?.title!
        }
        if CloudClient.sharedInstance().meeting?.details != nil {
            descriptiontextView.text = CloudClient.sharedInstance().meeting?.details!
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
         isCancelButtonTapped = true
         dismiss(animated: true, completion: nil)
    }
   
    @IBAction func close() {
        isCancelButtonTapped = false
        dismiss(animated: true, completion:nil)
    }
}

//Transition when view is presented and dismissed based on  modal presentation style
extension MeetingDataTitleViewController: UIViewControllerTransitioningDelegate {
    
    // View controller is presented
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController??, source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationViewController(presentedViewController: presented, presenting: presenting!)
    }
    
    //View controller is dismissed
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Update the data model with user entered data
        if !isCancelButtonTapped {
            
          CloudClient.sharedInstance().meeting?.title =  self.titleTextView!.text!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 ? self.titleTextView!.text : nil
        CloudClient.sharedInstance().meeting?.details = self.descriptiontextView!.text!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 ? self.descriptiontextView!.text : nil
        }
       
        //Upate Landing view controller based on data is entered or not
        let tabbarController = dismissed.presentingViewController as! UITabBarController
        
        if let tabbarViewControllers = tabbarController.viewControllers {
           let landingnavigationController = tabbarViewControllers[0] as! UINavigationController
           let landingViewController = landingnavigationController.topViewController as! LandingViewController
           landingViewController.updateButtonsState()
        }
        return SlideOutAnimationController()

    }
}

extension MeetingDataTitleViewController: UIGestureRecognizerDelegate {
    
    // This will return the view based on touch of the user
    // If it is touch inside the presented view,
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === view)
    }
}


extension MeetingDataTitleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptiontextView.becomeFirstResponder()
        return true
    }
}
