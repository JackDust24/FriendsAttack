//
//  HelperFunctions.swift
//  FriendsAttack
//
//  Created by JasonMac on 16/10/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import Foundation
import UIKit

// For UI Views so they can have a corner
func displayForSecondView(view: UIView) {
    
    view.layer.cornerRadius = 20
    view.clipsToBounds = true
    
}

// For UI Buttons so they can have a corner
func addCornerRadiusToButton(button: UIButton) {
    
    button.layer.cornerRadius = 20
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.black.cgColor
    button.clipsToBounds = true
    
}

