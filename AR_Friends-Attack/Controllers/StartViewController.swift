//
//  StartViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//
// This Controller is the Home Screen

import UIKit
import CoreData
import AVKit

class StartViewController: UIViewController {
    
//MARK: Properties

    // Core Data Properties
    var managedContext: NSManagedObjectContext!
    var friendsCount = 0
    var defaultData = false // If no data added by user we add default data
    // IB Outlets
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var friendsBtn: UIButton!
    @IBOutlet weak var scoresBtn: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    // Properties for Message Labels
    var iteration: Int = 0
    var helperMsgArray: Array<String> = []
    // Work Item for Despatch Timer
    private var helperMsgRequestWorkItem: DispatchWorkItem?
    
    let videoURL = "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4"
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load up initial items from Defaults
        GameStateManager.sharedInstance().initialGameLoad()
        // Call a bool to see if App Starting, if so then we can display Help Messages. If game already loaded up. No need to show the messages
        let checkIfAppStarting = GameStateManager.sharedInstance().checkIfAppStarting()
        if checkIfAppStarting {
            // If App just starting we can display the helper messages
            helperMsgArray = getArrayOfHelpMessages()
            // We minus one, as we are filtering an array
            let messageCount = helperMsgArray.count - 1
            // Now we call the updateHelperLabel method
            updateHelperLabel(intMax: messageCount)
        }
        
        // Set up secondary views and buttons
        displayForSecondView(view: self.secondView)
        addCornerRadiusToButton(button: playBtn)
        addCornerRadiusToButton(button: friendsBtn)
        addCornerRadiusToButton(button: scoresBtn)
        
        // Set up Notification Label (this is for when we add a friend or reporting on game results)
        // Start by setting the label to Alpha zero
        self.notificationLabel.alpha = 0.0
        
        // Set Notification for when we add a Friend from FriendVC
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationLabel(_:)), name: .kFriendAddedNotification, object: nil)
        // Set Notification for when we exit game and update this controller
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationLabel(_:)), name: .kGameReviewNotification, object: nil)
       
        // Ask if user wants to watch video. We only ask one time.
        if !UserDefaults.standard.bool(forKey:"hasBeenLaunched") {
            // show your only-one-time view
            print("hasBeenLaunched")
            askUserIfWantToWatchTutorial()
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        // We put the following in here in case we load up this controller again
        // In Core Data get some totals
        let fetch: NSFetchRequest<Friend> = Friend.fetchRequest()
       
        let count = try! managedContext.count(for: fetch)
        friendsCount = count
        
        // Check if any data stored, if not save default data
        insertDefaultFriendsData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // We don't wan the Dispatch Timer to keep running
        helperMsgRequestWorkItem?.cancel()
    }
    
//MARK: Notification Labels
    func updateHelperLabel(intMax: Int) {
        
        // Set up the Dispatch Work Item
        helperMsgRequestWorkItem = DispatchWorkItem { [weak self] in
            // 1. Set up the index, so we can call the array
            let index = self!.iteration
            // 2. Collect the text
            let helperText = self!.helperMsgArray[index]
            // 3. Use the Label animation
            self?.fadeInAndOutLabel(text: helperText)
            // 4. Now increase this Work Item to then send back through the loop
            self?.iteration = self?.iteration == intMax ? 0 : (self!.iteration + 1)
            // 5. With Recurssion we call this method again/
            self?.updateHelperLabel(intMax: intMax)
         }
        
        // 6. Add the Work Item to the Dispatch Queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: helperMsgRequestWorkItem!)

    }
    
    @objc func updateNotificationLabel(_ notification: Notification) {
        
        var notficationText = ""
        
        // Notification if Added a Friend
        if let nameAdded = notification.userInfo!["FriendAdded"] as? String {
            
            notficationText = String(format:
            NSLocalizedString("ADDED FRIEND LABEL",
            comment: "Notification text"),
            nameAdded)

        }
        // Notification When Finished a Game
        if let gameKills = notification.userInfo!["GameReview"] as? Int {
            
            // Different texts for different scenarios
            if gameKills == 0 {
                notficationText = String(format:
                NSLocalizedString("KILLED NO FRIENDS LABEL",
                comment: "Notification text"),
                gameKills)

            } else if gameKills == 1 {
                notficationText = String(format:
                NSLocalizedString("KILLED ONE FRIEND LABEL",
                comment: "Notification text"),
                gameKills)

            } else if gameKills == friendsCount {
                notficationText = NSLocalizedString("You Killed All Your Friends. You're A Winner!", comment: "Notification text")
            } else {
                notficationText = String(format:
                NSLocalizedString("KILLED SOME FRIENDS LABEL",
                comment: "Notification text"),
                gameKills)

            }
        }
        // Run through the Label animation
        fadeInAndOutLabel(text: notficationText)
        
    }
    
    func fadeInAndOutLabel(text: String) {
        
        // Animate the text labels in and out
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // First we make sure it is faded out
            self.notificationLabel.alpha = 0.0
        }, completion: {
            (finished: Bool) -> Void in
            // The set the text
            self.notificationLabel.text = text

            // Then fade in
            UIView.animate(withDuration: 4.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.notificationLabel.alpha = 1.0
            }, completion: {
                (finished: Bool) -> Void in
                
                // Then fade back out
                UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.notificationLabel.alpha = 0.0
                }, completion: nil)
            })
        })
    }
    
//MARK: Controllers and outlets
    
    @IBAction func playPressed(_ sender: Any) {
            
        // If using Default Data call alert to see if user wants to use or not.
        if defaultData {
            defaultDataAlerts()

        } else {
            self.performSegue(withIdentifier: "playGame", sender: self) //executing the segue on cancel

        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // If the user selects the View Screen or Scoresthen it goes there,
        // otherwise it's the Game Controller
        if segue.identifier == "viewFriends" {
            let friendsViewController = segue.destination as! FriendsViewController
            friendsViewController.managedContext = managedContext
        } else if segue.identifier == "showScores" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.managedContext = managedContext
            
        } else if segue.identifier == "showInfo" {
            // Nothing to show here as done automatically.
        } else if segue.identifier == "playGame" {
            // Create an alert
            print("Show Segue")
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if identifier == "playGame" {
            print("Perform Segue")
            let gameController = "GameController"
            let pushGameController = storyboard?.instantiateViewController(withIdentifier: gameController)  as! GameController
            self.navigationController?.pushViewController(pushGameController, animated: true)
            pushGameController.managedContext = managedContext
        }

    }
    
    
    //MARK: Alerts
    
    func askUserIfWantToWatchTutorial() {
        
        let actionSheet = UIAlertController(title: NSLocalizedString("Watch Tutorial?", comment: "Alert Title"), message: kDefaultFriendsMsg, preferredStyle: .alert)
                     
              actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Alert message"), style: .default, handler: { action in
                  
                  self.dismiss(animated: true)
                  self.playVideo()
              }))
                 
              actionSheet.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: "Alert message"), style: .cancel, handler: { action in
                     // Cancel button tappped.

                  self.dismiss(animated: true)
              }))
              // Present action sheet.

        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
   
    // We ask the user if they are happy that we are using default data.
    // Gets called after pressing play
    func defaultDataAlerts() {

        let actionSheet = UIAlertController(title: NSLocalizedString("No Friends Added", comment: "Alert message"), message: kDefaultFriendsMsg, preferredStyle: .alert)
               
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Alert message"), style: .default, handler: { action in
            
            self.dismiss(animated: true)
            self.performSegue(withIdentifier: "playGame", sender: action) //executing the segue on cancel
        }))
           
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Add Friends", comment: "Alert message"), style: .cancel, handler: { action in
               // Cancel button tappped.

            self.dismiss(animated: true)
        }))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    // Load up the Core Data
    func insertDefaultFriendsData() {
        
        if friendsCount > 0 {
            defaultData = false
            // SampleData already already in Core Data
            return
            
        } else {
            // Insert sample data
            defaultData = true
            // Set up the game with sample data - Get Constants Loaded
            let dataArray = [kDefaultFriend0, kDefaultFriend1, kDefaultFriend2, kDefaultFriend3, kDefaultFriend4, kDefaultFriend5]
            
            for index in dataArray {
                let entity = NSEntityDescription.entity(
                    forEntityName: "Friend",
                    in: managedContext)!
                let friend = Friend(entity: entity,
                                    insertInto: managedContext)
                friend.name = index
                let image = UIImage(named: "target.scnassets/\(index).png")
                let roundedImage = image?.roundedImage()
                let photoData = roundedImage!.pngData()!
                friend.friendImage = NSData(data: photoData) as Data
                friend.killed = 0
                friend.active = true
            }
            try! managedContext.save()
        }
    }
    
    //MARK:- Video Tutorial
    func playVideo() {
        
        guard let path = Bundle.main.path(forResource: "Game_Tutorial", ofType:"m4v") else {
            debugPrint("video.m4v not found")
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let vc = AVPlayerViewController()
        vc.player = player
    
        present(vc, animated: true) {
            vc.player?.play()
            vc.player?.volume = 0.0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
