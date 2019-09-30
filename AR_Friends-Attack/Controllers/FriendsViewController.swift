//
//  FriendsViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class FriendsViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! // DELETE
    @IBOutlet var tableView: UITableView!
    
    // Default Names in the friend list (we can get rid of these later)
    //TODO:- Set proper default array
    var friends: [String] = ["Ian", "Doug", "Ploy"]
    
    lazy var fetchedResultsController: NSFetchedResultsController<Friend> = {
        let fetchRequest = NSFetchRequest<Friend>()
        let entity = Friend.entity()
        fetchRequest.entity = entity
        let sortMonth = NSSortDescriptor(key: "name", ascending: false) // Because we want Start Month first
        fetchRequest.sortDescriptors = [sortMonth]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: "Friends")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the data
        performFetch()
        self.navigationController?.isNavigationBarHidden = true

    }
    
    func configureView() {
        print("Check if context set")
        if managedContext == nil {
            print("Context is nil")
            return
        }
    }
    
    
    // MARK:- Private methods to perform Fetch for the contents
    func performFetch() {
        do {
            print("Perform fetch")
            try fetchedResultsController.performFetch()
            
        } catch {
            // fatalCoreDataError(error)
            print("Perform fetch error")
            
        }
    }

    //MARK:- Segues
    // This is if we want to Add new Friend ONLY
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        print("shouldPerformSegue")
        
        let cell = sender as! UICollectionViewCell
        
        // This will be for addFriend
        if cell.tag == 100  {
            // your code here, like badParameters  = false, e.t.c
            return false
        }
        return true
    }
    
    // This is for View Friend Only Option
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        print("Prepare for segue")
        guard let cell = sender as! UICollectionViewCell? else {
            print("Cell not the sender")
            return
        }
        
        // Though the previous method checks for this, this is to make it more secure.
        if cell.tag == 100 {
            print("We will not send by Segue")
            return // This is not for Add Friend which is being dealt with by Did Select
        }

        if segue.identifier == "viewFriend" {
            print("CHECK - viewFriend - name")
            let detailVC = segue.destination as! FriendDetailViewController
            guard cell.tag <= friends.count else {
                print("Tag out of range - error")
                return
            }
            
            let detailsForVC = FriendDetails(name: friends[cell.tag], killed: 2)
            detailVC.detailItem = detailsForVC
            detailVC.managedContext = managedContext
            detailVC.name = friends[cell.tag]
        }
        
        //TODO- CHeck why we are calling this?
        testSampleCode()

    }
    
 
// MARK: - Collection Views
    //TODO:- Delete these
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
//
//        // Cell.tag is for Adding a friend - so we call Add friend, else we view the Friend
//        if cell?.tag == 100 {
//            print("CollectionView - Add Friend")
//            let nextController = "AddFriendViewController"
//            let secondViewController = storyboard?.instantiateViewController(withIdentifier: nextController)  as! AddFriendViewController
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//             secondViewController.managedContext = managedContext
//        } else {
//            print("Call  segue4 - viewFriend - nothing to do as did prepare for segue")
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
//        return quotes.count + 1
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FriendsCollectionViewCell
//
//        // If default set, then show the label
//        let friendsCount = fetchedResultsController.fetchedObjects?.count ?? 1
//
//        print("friendCount = fetchedResultsController.object - \(friendsCount)")
//
//        if indexPath.row < friendsCount {
//            let friend = fetchedResultsController.object(at: indexPath)
//
//            print("friend = fetchedResultsController.object - \(friend)")
//            cell.friendLabel?.text = friend.name
//            cell.friendImage?.image = UIImage(data: friend.friendImage!)
//            cell.tag = indexPath.row
//            return cell
//
//        } else {
//            cell.friendLabel?.text = "Add Friend"
//            cell.friendLabel?.textColor = UIColor.blue
//            cell.friendImage?.image = UIImage(named: "target.scnassets/placeholder-image.png")
//            cell.tag = 100 // This way we can add friend
//            return cell
//
//        }
//    }
    
    //MARK:- Table Views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("QUOTES")
        guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
        return quotes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //TODO- Set up TableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! FriendsTableViewCell
        
        // If default set, then show the label
        let friendsCount = fetchedResultsController.fetchedObjects?.count ?? 1
        
        print("friendCount = fetchedResultsController.object - \(friendsCount)")
        
        // Here we say add if less than the count, populate the row,
        // else we popular with ADD ROW (as we add an extra row)
        if indexPath.row < friendsCount {
            
            let friend = fetchedResultsController.object(at: indexPath)
            print("friend = fetchedResultsController.object - \(friend)")
            cell.friendLabel?.text = friend.name
            cell.friendImage?.image = UIImage(data: friend.friendImage!)
            cell.tag = indexPath.row
            return cell
            
        } else {
            
            cell.friendLabel?.text = "Add Friend"
            cell.friendLabel?.textColor = UIColor.blue
            cell.friendImage?.image = UIImage(named: "target.scnassets/placeholder-image.png")
            cell.tag = 100 // This way we can add friend
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        
        // Cell.tag is for Adding a friend - so we call Add friend, else we view the Friend
        if cell?.tag == 100 {
            
            print("CollectionView - Add Friend")
            let nextController = "AddFriendViewController"
            let secondViewController = storyboard?.instantiateViewController(withIdentifier: nextController)  as! AddFriendViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
            secondViewController.managedContext = managedContext
            
        } else {
            print("Call segue4 - viewFriend - nothing to do as did prepare for segue")
        }
    }
    
    //MARK:- Buttons
    @IBAction func exit(_ sender: Any) {
        //TODO- Add Code for Exit
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- Misc
    func testSampleCode() {
        
        if managedContext == nil {
            print("NO CONTEXT YET")
            return
        }
        
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {
            //3
            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                print(result.value(forKey: "name") ?? "no name")
                print("Record - \(result)")
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
