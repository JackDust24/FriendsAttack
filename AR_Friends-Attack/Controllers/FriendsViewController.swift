//
//  FriendsViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Properties
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    
    var maxFriendsReached = false
        
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
    
    deinit {
        fetchedResultsController.delegate = nil
        tableView = nil
    }
    
    //MARK:- Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("ViewDidLoad")
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        // addCornerRadiusToButton(button: self.exitButton)
        addCornerRadiusToButton(button: self.resetBtn)
        
        messageLabel.text = String(format:
        NSLocalizedString("ADD MAX FRIENDS LABEL",
        comment: "Label to inform users how many friends to add"),
        kMaxFriends)


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
            // print("Context is nil")
            return
        }
    }
    
    //MARK:- Buttons
    @IBAction func exit(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK:- Private methods to perform Fetch for the contents
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // print("Perform fetch error")
            abortApp(abortType: "Data")
        }
    }

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
        nameLabel.text = NSLocalizedString("Friend", comment: "Label")
        nameLabel.frame = CGRect(x: 20, y: 0, width: 100, height: 30)
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines=1
        nameLabel.textColor=UIColor.white
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        
        // Create the kills label for the kills column
        let killsLabel = UILabel()
        killsLabel.text = NSLocalizedString("Kills", comment: "Label")
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
        // print("FriendsCount - \(friends.count)")
        
        // If reached it's max peak, cannot add any more.
        if friends.count == kMaxFriends {
            // print("Max friends - \(friends.count)")
            maxFriendsReached = true
            return friends.count + 1
        }
        maxFriendsReached = false
        
        //tableView.reloadData()
        // Otherwise we add the option to add another
        return friends.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: FriendsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? FriendsTableViewCell

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "TableViewCell") as? FriendsTableViewCell
        }
        
        let friendsCount = fetchedResultsController.fetchedObjects?.count ?? 1
        
        // Here we say add if less than the count, populate the row,
        // else we popular with ADD ROW (as we add an extra row)
        if indexPath.row < friendsCount {
            let friend = fetchedResultsController.object(at: indexPath)
            cell.displayContent(image: UIImage(data: friend.friendImage!)!, title: friend.name!, killed: Int(friend.killed), addFriend: false)
            cell.tag = indexPath.row
            return cell
        
        } else {
            // If max reached cannot add more
            if maxFriendsReached {
                // print("Max friends reached")
                cell.displayContent(image: UIImage(named: "target.scnassets/\(kDefaultFriendAdd).png")!, title: NSLocalizedString("Max Friends Reached", comment: "Table View Lebel"), killed: 0, addFriend: true)
                cell.isUserInteractionEnabled = false
                cell.tag = 200 // Cannot add friend
                return cell
            }
            // Otherwise can add friend
            // print("Can Add row")
            cell.isUserInteractionEnabled = true
            cell.displayContent(image: UIImage(named: "target.scnassets/\(kDefaultFriendAdd).png")!, title: NSLocalizedString("Add Friend", comment: "Table View Lebel"), killed: 0, addFriend: true)
            cell.tag = 100 // This way we can add friend
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        // Max cells reached
        if cell?.tag == 200 {
            // Will not ever be called, but we will keep anyway
            // print("Max Reached Selected")
            return
            // Can return as nothing to do here.
        }
        // Cell.tag is for Adding a friend - so we call Add friend, else we view the Friend
        if cell?.tag == 100 {
            // print("Add Friend Selected")

            let nextController = "AddFriendViewController"
            let secondViewController = storyboard?.instantiateViewController(withIdentifier: nextController)  as! AddFriendViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
            secondViewController.managedContext = managedContext
            
        }  else {
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
    
    // Here we can say if the row is Tag 100 (Add Friend) - We cannot delete it
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // If add or max friends row, we don't want it to be deleted.
        if tableView.cellForRow(at: indexPath)?.tag == 100 || tableView.cellForRow(at: indexPath)?.tag == 200 {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let friend = fetchedResultsController.object(at: indexPath)
            // handle delete (by removing the data from your array and updating the tableview)
            managedContext.delete(friend)
            do {
                try managedContext.save()

            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
                abortApp(abortType: "Data")
            }
        }
    }
        
    //MARK: Outlets and Actions
    
    @IBAction func resetPressed(_ sender: Any) {
        // Give use the option to reset all the scores, or just the friends scores
        let actionSheet = UIAlertController(title: NSLocalizedString("Reset Scores", comment: "Alert Title"), message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Clear Scores", comment: "Alert Title"), style: .default, handler: { action in
            // Clear button tappped.
            self.dismiss(animated: true)
            self.showResetConfirmation()
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Title"), style: .cancel, handler: { action in
            // Cancel button tappped.
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
        let alertNameMissing = UIAlertController(title: NSLocalizedString("Reset All Your Scores", comment: "Alert Title"),
                                                 message: NSLocalizedString("Are You Sure? This can not be undone.", comment: "Alert message"), preferredStyle: .alert)
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
        let fetchResults = fetchedResultsController.fetchedObjects
        do {
            // Get results of friends request
            if let fetchResults = fetchResults {
                // Fetch List Records
                for fetch in fetchResults {
                    let currentKilled = 0
                    fetch.setValue(Int64(currentKilled), forKey: "killed")
                }
                self.tableView.reloadData()
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // If need to abort function
    func abortApp(abortType: String) {
        // Get the type we are aborting, i.e. Core Data, retrieve it from the Helper function
        let alertSheet = abortDueToIssues(type: abortType)
        
        self.present(alertSheet, animated: true, completion: nil)

    }
}

//MARK: Delegate Table Handler
extension FriendsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            // print("Insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            // print("delete")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            perform(#selector(reloadTable), with: nil, afterDelay: 2)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            //TODO:- Check this
            //                if let cell = tableView.cellForRow(at: indexPath!)
            //                    as? ItemTableViewCell {
            //                    let item = controller.object(at: indexPath!)
            //                        as! Items
            //                    cell.configure(for: item)
            //                }
        //
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        @unknown default:
            //Nothing to do here.
            return
        }
        // print("*** RELOAD DATA")
        
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        // print("TEST 2")
        guard let friends = fetchedResultsController.fetchedObjects else {
            // print("No fetched Objects")
            return
            
        }
        // We do not want to continue as only the default row left
        if friends.count == 0 {
            // print("No fetched Objects1")

            return
        }
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
             print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
             print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            //Nothing to do here
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @objc func reloadTable() {
        self.tableView.reloadData()
    }
}
