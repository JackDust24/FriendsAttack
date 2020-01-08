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
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var friendImage: UIImageView!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
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
        addCornerRadiusToButton(button: self.shareButton)
        // We don't use an optional here as there will always be a value even if zero
        let killsAndPoints = GameStateManager.sharedInstance().returnKillsAndPoints()
        let tKills = killsAndPoints.0
        let tPoints = killsAndPoints.1
        
        killsLabel.text = String(tKills)
        pointsLabel.text = String(tPoints)
        
        var mostKilledFriend = NSLocalizedString("Nobody Killed Yet", comment: "Score Info")
        var mostKilledFriendKills = 0
        var tempFriendImage = UIImage()

        // Get the core data info to find the highest score.
        // Fetch friends
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            let results = try managedContext.fetch(request)
            for result in results {
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
                        tempFriendImage = UIImage(data: imageAvailable as! Data)!
                    } else {
                        // Put default image up
                        tempFriendImage = UIImage(named: "target.scnassets/\(kDefaultFriendAdd).png")!
                    }
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")
        }
        
        // Now we can populate the most killed details, but only if there is a record.
        friendLabel.text = mostKilledFriend
        // If no record, then we hide the score label
        if mostKilledFriendKills == 0 {
            friendScoreLabel.isHidden = true
            friendImage.isHidden = true
        } else {
            var textForLabel = ""
            // In case there is only 1 kill
            if mostKilledFriendKills == 1 {
                textForLabel = String(format:
                NSLocalizedString("KILLED ONE TIME LABEL",
                comment: "Score Label"),
                mostKilledFriendKills)
            } else {
                textForLabel = String(format:
                NSLocalizedString("KILLED MANY TIMES LABEL",
                comment: "Score Label"),
                mostKilledFriendKills)
            }
            friendScoreLabel.text = textForLabel
            friendImage.image = tempFriendImage
        }
    }
    
    //MARK:- Other Views

    func configureView() {
        if managedContext == nil {
            return
        }
    }
    
    // When we share on FB etc, this will save as an image
    func saveViewAsImage() -> UIImage? {
        let screen = UIScreen.main
        var image: UIImage?
        // Due to keyWIndow being decaprocated we use this workaround.
        let myKeyWindow: UIWindow? = UIApplication.shared.keyWindowInConnectedScenes
        if let window = myKeyWindow {
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0)
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image!
        }
        return image

    }
    
//MARK:- Outlets
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // 1. We want to hide the buttons and change the text first
        self.shareButton.isHidden = true
        self.backButton.isHidden = true
        self.headerLabel.adjustsFontSizeToFitWidth = true
        self.headerLabel.font.withSize(22.0)
        self.headerLabel.text = NSLocalizedString("FriendsAttack Scores", comment: "Header Label")
        self.view.setNeedsDisplay()
        
        // 2. Get image
        let image = saveViewAsImage()
        
        // 3. Check if image is not nil
        if let imageCreated = image {
            var activityItems: [AnyObject]?
            let postText = NSLocalizedString("This Is My Score On FriendsAttack.", comment: "Post message")
            activityItems = [postText as AnyObject, imageCreated]
            let activityController = UIActivityViewController(activityItems: activityItems!, applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
            
            // If iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.popoverPresentationController?.sourceView = self.view
                activityController.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
            }
            
            activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                // Put the normal values back
                self.putValuesBack()
            }
        }
    }
    
    // Set this after we have shared to social media
    func putValuesBack() {
        self.shareButton.isHidden = false
        self.backButton.isHidden = false
        self.headerLabel.text = NSLocalizedString("Scores", comment: "Header Label")
        self.headerLabel.font.withSize(34.0)
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: Helper Functions
    // If need to abort function
    func abortApp(abortType: String) {
        // Get the type we are aborting, i.e. Core Data, retrieve it from the Helper function
        let alertSheet = abortDueToIssues(type: abortType)
        
        self.present(alertSheet, animated: true, completion: nil)

    }

}
