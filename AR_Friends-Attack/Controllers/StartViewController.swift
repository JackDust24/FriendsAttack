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

class StartViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sample data which we can remove at the end
        //TODO:- We will need default data, so need to set this to get context if empty
        insertSampleData()
        
        // Fetch friends
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            //3
            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                print("Loading up sample data \(result.value(forKey: "name") ?? "no name")")
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the user selects the View Screen or Scoresthen it goes there,
        // otherwise it's the Game Controller
        
        if segue.identifier == "viewFriends" {
            print("prepare - View")
            let secondViewController = segue.destination as! FriendsViewController
            secondViewController.managedContext = managedContext
        } else if segue.identifier == "showScores" {
            print("prepare - View for Score Controller")
//            let secondViewController = segue.destination as! ScoreViewController
//            secondViewController.managedContext = managedContext
        } else  {
            let secondViewController = segue.destination as! GameController
            
            secondViewController.managedContext = managedContext
            
        }
    }
    
    // MARK: - Core Data
    // Load up the Core Data
    // Insert sample data
    func insertSampleData() {
        
        let fetch: NSFetchRequest<Friend> = Friend.fetchRequest()
        // fetch.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // SampleData already already in Core Data
            return
        } else {
            // Set up the game with sample data
            //TODO- Properly change this
            let dataArray = ["Harsh", "Doug", "Ian", "Scotto", "Ploy"]
            
            for index in dataArray {
                let entity = NSEntityDescription.entity(
                    forEntityName: "Friend",
                    in: managedContext)!
                let friend = Friend(entity: entity,
                                    insertInto: managedContext)
                friend.name = index
                let image = UIImage(named: "target.scnassets/\(index).png")
                let photoData = UIImagePNGRepresentation(image!)!
                friend.friendImage = NSData(data: photoData) as Data
                friend.active = true
            }
            try! managedContext.save()
        }
    }
}
