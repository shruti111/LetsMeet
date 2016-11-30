//
//  NestedlocationCategoryCollectionViewCell.swift
//  LetsMeet
//
//  Created by Shruti  on 29/07/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit

class NestedlocationCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    // Cancel download task when collection view cell is reused
    var taskToCancelifCellIsReused: URLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set collection view with rounded corner
        self.layer.cornerRadius = 5
        self.layer.borderColor = collectionViewBorderGreyColor().cgColor
        self.layer.borderWidth = 1.0
        
    }

}
