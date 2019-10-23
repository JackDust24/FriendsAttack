//
//  ScoreViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 16/5/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class ScoreViewController: UIViewController {
    
    //MARK:- Properties


    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendScoreLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var exitBtn: UIButton!
    
    @IBOutlet weak var friendImage: UIImageView!
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    //MARK:- Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        addCornerRadiusToButton(button: self.exitBtn)
        // We don't use an optional here as there will always be a value even if zero
        let killsAndPoints = GameStateManager.sharedInstance().returnKillsAndPoints()
        let tKills = killsAndPoints.0
        let tPoints = killsAndPoints.1
        
        killsLabel.text = String(tKills)
        pointsLabel.text = String(tPoints)
        
        var mostKilledFriend = "No-one killed yet"
        var mostKilledFriendKills = 0
        var tempFriendImage = UIImage()

        // Get the core data info to find the highest score.
        // Fetch friends
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            //3
            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                print("Loading up results data \(result.value(forKey: "name") ?? "no name")")
                
                let name = result.value(forKey: "name") as! String
                let killsResult = result.value(forKey: "killed") as! Int
                
                // If this result is higher then the highest becomes the first record that has that total
                if killsResult > mostKilledFriendKills {
                    
                    // Set the paramaters
                    mostKilledFriendKills = killsResult
                    mostKilledFriend = name
                    
                    let imageData = result.value(forKey: "friendImage") ?? nil
                    
                    if let imageAvailable = imageData {
                        // Image exists
                        print("Image exists")
                        tempFriendImage = UIImage(data: imageAvailable as! Data)!
                    }
                    
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Now we can populate the most killed details, but only if there is a record.
        friendLabel.text = mostKilledFriend

        // If no record, then we hide the score label
        if mostKilledFriendKills == 0 {
            friendScoreLabel.isHidden = true
            friendImage.isHidden = true
            
        } else {
            let textForLabel = "Killed \(mostKilledFriendKills) times"
            friendScoreLabel.text = textForLabel
            friendImage.image = tempFriendImage
        }
    }
    
    func configureView() {
        if managedContext == nil {
            print("Context is nil")
            return
        }
    }

    //TODO:- Add code for Reset
    //TODO:- Add code to share on FB
    //TODO:- Add code to populate most killed friend
    
    @IBAction func exitPressed(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)

    }
    

}
