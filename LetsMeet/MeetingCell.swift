//
//  MeetingCell.swift
//  LetsMeet
//
//  Created by Shruti on 26/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class MeetingCell: UITableViewCell {

    @IBOutlet weak var meetingLocationImage: UIImageView!
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var meetingTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.meetingLocationImage.layer.cornerRadius = 5
        self.meetingLocationImage.clipsToBounds = true
    }
    
    // Cancel download task when collection view cell is reused
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }

}
