//
//  ParentlocationCateporyTableViewCell.swift
//  LetsMeet
//
//  Created by Shruti  on 29/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class ParentlocationCategoryTableViewCell: UITableViewCell {

@IBOutlet weak var parentCategoryIcon: UIImageView!

@IBOutlet weak var parentCategoryName:UILabel!
    
    // Cancel download task when collection view cell is reused
    var taskToCancelifCellIsReused: URLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
   
    }
