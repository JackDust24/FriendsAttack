//
//  StartViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class StartViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sample data which we can remove at the end
        insertSampleData()
        
        // Fetch friends
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            //3
            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                print(result.value(forKey: "name") ?? "no name")
                print(result)
            }
            // populate(friend: results.first!)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segue
//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//        
//        var secondController = ""
//        // Go to view friends
//        print("performSegue")
//
//        if identifier == "viewFriends" {
//            print("performSegue - View")
//
//            secondController = "FriendsViewController"
//            let secondViewController = storyboard?.instantiateViewController(withIdentifier: secondController) as! FriendsViewController
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//            secondViewController.managedContext = managedContext
//
//           
//        } else {
//            secondController = "ViewController"
//            let secondViewController = storyboard?.instantiateViewController(withIdentifier: secondController) as! ViewController
//            secondViewController.managedContext = managedContext
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("prepare")
        
        if segue.identifier == "viewFriends" {
            print("prepare - View")
            let secondViewController = segue.destination as! FriendsViewController
            secondViewController.managedContext = managedContext
        } else  {
            let secondViewController = segue.destination as! ViewController
            
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
        }

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
