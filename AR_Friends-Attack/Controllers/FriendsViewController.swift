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
    
    //MARK:- Properties
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var secondView: UIView!
    

    
    @IBOutlet weak var exitButton: UIButton!
    
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
    
    //MARK:- Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        
        addCornerRadiusToButton(button: self.exitButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .blue
        // Register the TableView Cell
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "TableViewCell")
        
        // Fetch the data
        performFetch()
        self.navigationController?.isNavigationBarHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureView() {
        if managedContext == nil {
            print("Context is nil")
            return
        }
    }
    
    //MARK:- Buttons
    @IBAction func exit(_ sender: Any) {
        //TODO- Add Code for Exit
        self.navigationController?.popToRootViewController(animated: true)
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

 
// MARK: - Tables

    //MARK:- Table Views
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create a background view
        let vw = UIView()
        vw.backgroundColor = UIColor.blue
        vw.alpha = 0.8
        
        // Get the table Wdith and then a Float position so we can set the X co-ordinate for the label for the Kills column in the table.
        let tableWidth = tableView.bounds.size.width
        let killsLabelPosition = tableWidth - 65.0
        
        // Create the name label
        let nameLabel = UILabel()
        nameLabel.text = "Friend"
        nameLabel.frame = CGRect(x: 20, y: 0, width: 100, height: 30)
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines=1
        nameLabel.textColor=UIColor.white
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        
        // Create the kills label for the kills column
        let killsLabel = UILabel()
        killsLabel.text = "Kills"
        killsLabel.frame = CGRect(x: killsLabelPosition, y: 0, width: 60, height: 30)
        killsLabel.textAlignment = .center
        killsLabel.numberOfLines=1
        killsLabel.textColor=UIColor.white
        killsLabel.font=UIFont.systemFont(ofSize: 22)
        
        // Add both labels to the view
        vw.addSubview(nameLabel)
        vw.addSubview(killsLabel)
        
        // Return the view
        return vw
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Name"
        }
        
        return "else"
    }
    
    //MARK:- Table Data
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let friends = fetchedResultsController.fetchedObjects else { return 0 }
        return friends.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Set up Cell for Table View
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! FriendsTableViewCell
        
        let friendsCount = fetchedResultsController.fetchedObjects?.count ?? 1
        print("friendCount = fetchedResultsController.object - \(friendsCount)")
        
        // Here we say add if less than the count, populate the row,
        // else we popular with ADD ROW (as we add an extra row)
        if indexPath.row < friendsCount {
            
            let friend = fetchedResultsController.object(at: indexPath)
            
            cell.displayContent(image: UIImage(data: friend.friendImage!)!, title: friend.name!, killed: Int(friend.killed))
            print("friend = fetchedResultsController.object - \(friend)")
            cell.tag = indexPath.row
            return cell
            
        } else {
            
            cell.displayContent(image: UIImage(named: "target.scnassets/placeholder-image.png")!, title: "Add Friend", killed: 0)
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
            let nextController = "FriendDetailViewController"
            let secondViewController = storyboard?.instantiateViewController(withIdentifier: nextController)  as! FriendDetailViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
            secondViewController.managedContext = managedContext
            let friend = fetchedResultsController.object(at: indexPath)
            
            let detailsForVC = FriendDetails(name: friend.name ?? "", image: UIImage(data: friend.friendImage!)!, killed: Int(friend.killed))
            secondViewController.detailItem = detailsForVC
            secondViewController.managedContext = managedContext
            secondViewController.name = friend.name // Don't think we need this anymore
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
