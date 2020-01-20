//
//  InfoViewController.swift
//  FriendsAttack
//
//  Created by JasonMac on 27/11/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    // Set properties for changing the Game Level
    @IBOutlet weak var gameLevelField: UITextField!
    
    // Picker View Data for changing the gtame elvel difficulty
    let thePicker = UIPickerView()
    let myPickerData = GameStateManager.sharedInstance().gameLevels
    let currentGameLevel = GameStateManager.sharedInstance().currentGameLevel.rawValue

    @IBOutlet weak var developerLabel: UITextView!
    @IBOutlet weak var thanksLabel: UITextView!
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text field as the picker view
        gameLevelField.inputView = thePicker
        // Get the current Game level        
        updateTextViews()
        
        // Add delegae to self
        thePicker.delegate = self
     }
    
    func updateTextViews() {
        // Game Level
        var currentlevel = ""
        
        if currentGameLevel == "Easy" {
            currentlevel = NSLocalizedString("Easy", comment: "Game Level")
            
        } else if currentGameLevel == "Medium" {
            currentlevel = NSLocalizedString("Medium", comment: "Game Level")
        } else  if currentGameLevel == "Hard" {
            currentlevel = NSLocalizedString("Hard", comment: "Game Level")
        } else {
            currentlevel = NSLocalizedString("Medium", comment: "Game Level")
        }
        
        gameLevelField.text = String(format:
        NSLocalizedString("CURRENT GAME LEVEL LABEL",
        comment: "Initial Game Level"),
        currentlevel)
        
        developerLabel.text =
        NSLocalizedString("If you have any comments, please contact the developer at admin@lifetravelcoffee.com",
        comment: "Contact me comment")
        
        thanksLabel.text =
        NSLocalizedString("Special thanks to:\n\nFreepik for his profile icons at https://www.flaticon.com/authors/freepikand JustInVoke at https://freesound.org/s/446121/.",
               comment: "Thanks comment")
        
        
    }

    // MARK: UIPickerView Delegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
     return myPickerData[row]
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gameLevelField.text = myPickerData[row]
           
    }
    
    // We want to add this, so that the user can dismiss the picker
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
   
    //MARK: Outlets etc
    @IBAction func exit(_ sender: Any) {
        // Check if the textfield changed, if so save this to the game level settings
        if gameLevelField.text != currentGameLevel {
            // print("Text field for game level has changed")
            // Change the game level settings before exiting
            // We cab add something blank in case there is a problem as it won't corrupt the properties at all
            GameStateManager.sharedInstance().changeLevel(newLevel: gameLevelField.text ?? "")
        }
        
        self.navigationController?.popViewController(animated: true)
    }

}
