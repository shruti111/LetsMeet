//
//  ThemeManager.swift
//  LetsMeet
//
//  Created by Shruti on 27/09/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation
import UIKit

// Sets Application theme colors and font

// MARK:- Application Colors
func applicationThemeColor() -> UIColor {
    return UIColor(red: 255/255, green: 97/255, blue: 60/255, alpha: 1)
}

func themeColorforTabbar() -> UIColor {
    return  UIColor(red: 255/266, green: 102/266, blue: 102/266, alpha: 1.0)
}

func landingScreenFilledButtonColor() -> UIColor {
    return UIColor(red: 255/255, green: 97/255, blue: 60/255, alpha: 0.8)
}
func landingScreenButtonColor() -> UIColor {
   return UIColor.clear
}

func landingScreenFilledButtonTintColor() -> UIColor {
    return UIColor.white
}

func dateTimeLabelBackgroundColor() -> UIColor {
    return UIColor(red: 202 / 255, green: 202 / 255, blue: 207 / 255, alpha: 0.8)
}

func collectionViewBorderGreyColor() -> UIColor {
    return UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1.0)
}

func emptyDatamessageColor() -> UIColor {
    return UIColor.red
}

//MARK:- Application Font

func messageLabelFont() -> UIFont {
    if let palatinoFont = UIFont(name: "Palatino-Italic" , size: 20) {
        return palatinoFont
    } else {
        return UIFont.systemFont(ofSize: 20)
    }
}

func tableViewCellSmallLabelFont() -> UIFont {
    if let avenirFont = UIFont(name: "AvenirNext-Medium", size: 14) {
        return avenirFont
    } else {
        return UIFont.systemFont(ofSize: 14)
    }
}

func tableViewCellLabelFont() -> UIFont {
    if let avenirFont = UIFont(name: "AvenirNext-Medium", size: 15) {
        return avenirFont
    } else {
        return UIFont.systemFont(ofSize: 15)
    }
}

func tableViewCellLabelMediumFont() -> UIFont {
    if let avenirFont = UIFont(name: "AvenirNext-Medium", size: 16) {
        return avenirFont
    } else {
        return UIFont.systemFont(ofSize: 16)
    }
}

func tableViewCellLabelMediumLocationFont() -> UIFont {
    if let avenirFont = UIFont(name: "AvenirNext-Medium", size: 17) {
        return avenirFont
    } else {
        return UIFont.systemFont(ofSize: 17)
    }
}


func tableViewCellLabelBigFont() -> UIFont {
    if let avenirFont = UIFont(name: "AvenirNext-Medium", size: 22) {
        return avenirFont
    } else {
        return UIFont.systemFont(ofSize: 22)
    }
}



// Navigation bar title Font   -    Application color, Avenir - Next Demi Bold  17.0
// Create Screen  headers     - Dark grey color, Avenir - Next Demi Bold  17.0
// Creare Screen - Bar button -  Application color, Font - System 15
//Create Screen - text field - Black color, Avenir Next Medum 15
//Error label - 128,0,0 , System 12
//Table View Selection - Default
//Table View cell - Text
