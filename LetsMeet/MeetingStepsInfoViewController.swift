//
//  MeetingStepsInfoViewController.swift
//  LetsMeet
//
//  Created by Shruti on 04/10/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

// This gives information about how to create a new meeting in step by step way
class MeetingStepsInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneTapped(sender: UIButton) {
         dismissViewControllerAnimated(true, completion: nil)
    }
}
