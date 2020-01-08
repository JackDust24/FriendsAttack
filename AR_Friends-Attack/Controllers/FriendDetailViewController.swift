//
//  FriendDetailViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

//MARK:- Struct
// Details for the Friend
struct FriendDetails {
    var name: String
    var image: UIImage
    var killed: Int
}

class FriendDetailViewController: UIViewController {
    
    //MARK:- Properties
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var killedLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            self.configureView()
        }
    }
    
    @IBOutlet weak var friendImage: UIImageView! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    //MARK:- The struct details
    var detailItem: FriendDetails? {
        didSet {
            self.configureView()
        }
    }
    
    var name: String? {
        didSet {
            self.configureView()
        }
    }
    
    //MARK:- Views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        // addCornerRadiusToButton(button: self.exitButton)
        addCornerRadiusToButton(button: self.resetBtn)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if self.killedLabel == nil { return } // no web view, bail out
        print("Detail item - \(String(describing: detailItem))")
        nameLabel.text = detailItem?.name
        killedLabel.text = "\(detailItem?.killed ?? 0)"
        friendImage.image = detailItem?.image
    }
    
    //MARK:- Actions and Outlets
    @IBAction func exit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Rest the scores
    @IBAction func resetPressed(_ sender: Any) {
        // Give use the option to reset all the scores, or just the friends scores
          let actionSheet = UIAlertController(title: NSLocalizedString("Reset Score", comment: "Alert title"), message: nil, preferredStyle: .actionSheet)
          
          actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Clear Score", comment: "Alert title"), style: .default, handler: { action in
              self.dismiss(animated: true)
            self.showResetConfirmation()

          }))
          
          actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Title"), style: .cancel, handler: { action in
              self.dismiss(animated: true) {
              }
          }))
          // Present action sheet.
          
        if UIDevice.current.userInterfaceIdiom == .pad {

            if let currentPopoverpresentioncontroller = actionSheet.popoverPresentationController {
                currentPopoverpresentioncontroller.permittedArrowDirections = []
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                currentPopoverpresentioncontroller.sourceView = self.view

                self.present(actionSheet, animated: true, completion: nil)
            }
            
        } else {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func showResetConfirmation() {
           
        let alertNameMissing = UIAlertController(title: NSLocalizedString("Reset Kill Score", comment: "Alert title"),
                                                    message: NSLocalizedString("Are You Sure? This can not be undone", comment: "Alert message"), preferredStyle: .alert)
        alertNameMissing.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Alert Title"), style: .destructive, handler: { action in
               self.clearScores()
           }))
        alertNameMissing.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Title"), style: .cancel))
           
        if UIDevice.current.userInterfaceIdiom == .pad {

            if let currentPopoverpresentioncontroller = alertNameMissing.popoverPresentationController {
                currentPopoverpresentioncontroller.permittedArrowDirections = []
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                currentPopoverpresentioncontroller.sourceView = self.view
                self.present(alertNameMissing, animated: true, completion: nil)
            }
            
        } else {
            self.present(alertNameMissing, animated: true, completion: nil)
        }
            
    }
       
    func clearScores() {
        let fetchRequest = NSFetchRequest<Friend>()
        let entity = Friend.entity()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "name = %@", detailItem!.name)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as [NSManagedObject] {
                let currentKilled = 0
                data.setValue(Int64(currentKilled), forKey: "killed")
                killedLabel.text = "\(currentKilled)"
            }
          
            try managedContext.save()
                              
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")
        }
    }
    
    // If need to abort function
    func abortApp(abortType: String) {
        // Get the type we are aborting, i.e. Core Data, retrieve it from the Helper function
        let alertSheet = abortDueToIssues(type: abortType)
        
        self.present(alertSheet, animated: true, completion: nil)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
