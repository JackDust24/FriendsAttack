//
//  HelperFunctions.swift
//  FriendsAttack
//
//  Created by JasonMac on 16/10/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//
// Any Helper Functions I need

import Foundation
import UIKit
import SceneKit

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

// This is for GameController on how far the range is for position appearance
func createRangeOfArrays(start: Int, end: Int) -> Array<Int> {
    
    // print(start)
    // print(end)
    let arr = Array(start...end)
    return arr
}

// This is for returning sound effectcs
func returnAudioSound(type: String) -> SCNAudioSource? {
    
    if type == "explosion" {
        return SCNAudioSource(fileNamed: "explosion.mp4") ?? nil
        
    } else if type == "shoot" {
        return SCNAudioSource(fileNamed: "shoot.mp4") ?? nil
    }
    
    return nil
}

// For list of Help messages that appear on the StartViewController
func getArrayOfHelpMessages() -> Array<String> {
    
    let array = [kHelperMsg0, kHelperMsg1, kHelperMsg2, kHelperMsg3, kHelperMsg4, kHelperMsg5]
    
    return array

}

// For Core Data Alerts if there is a problem with Core Data on the App
func abortDueToIssues(type: String) -> UIAlertController {
       
    if type == "Data" {
        let alertCoreDataProblem = UIAlertController(title: NSLocalizedString("Problem Loading Data", comment: "Alert Title"),
                                                    message: NSLocalizedString("Apologies for the inconvenience. There was a problem loading your saved data. Try removing the App and re-installing it.", comment: "Alert Message"), preferredStyle: .alert)
           alertCoreDataProblem.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive, handler: nil))

           // present(alertNameMissing, animated: true)
        
        return alertCoreDataProblem
        
    }
    
    // Default is Session error
    let alertSessionProblem = UIAlertController(title: NSLocalizedString("Problem Loading Session", comment: "Alert Title"),
                                                message: NSLocalizedString("Apologies for the inconvenience. There was a problem loading the session. Please close the app and open again.", comment: "Alert Message"), preferredStyle: .alert)
       alertSessionProblem.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive, handler: nil))

       // present(alertNameMissing, animated: true)
    
    return alertSessionProblem
    

}

