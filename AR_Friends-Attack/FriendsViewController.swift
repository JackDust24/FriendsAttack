//
//  FriendsViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
}

class FriendsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var friends: [String] = ["Ian", "Doug", "Ploy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false

        
        // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We don't want Add Friend to do the Segue, so we block it here. Add Friend has a tag 0f 100
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        print("shouldPerformSegue")
        
        let cell = sender as! UICollectionViewCell
        
        if cell.tag == 100  {
            // your code here, like badParameters  = false, e.t.c
            return false
        }
        return true
    }
    
    // This is for View Friend Only
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
            
            let detailsForVC = FriendDetails(name: friends[cell.tag], hits: 6, games: 4, kills: 2, ranking: "Deadly")
            detailVC.detailItem = detailsForVC
            
            detailVC.name = friends[cell.tag]


        }

    }
    
// MARK: - Collection Views
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        print("Call  segue2 - ")

        // Cell.tag is for Adding a friend - so we call Add friend, else we view the Friend
        if cell?.tag == 100 {
            print("Call  segue3 - Add Friend")
            //self.performSegue(withIdentifier: "addFriend", sender: cell)
            
            let nextController = "AddFriendViewController"
            let secondViewController = storyboard?.instantiateViewController(withIdentifier: nextController)
            self.navigationController?.pushViewController(secondViewController!, animated: true)

        } else {
            print("Call  segue4 - viewFriend - nothing to do as did prepare for segue")
            
        }

    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FriendsCollectionViewCell
        
        if indexPath.row < friends.count {
            let friendName = friends[indexPath.row]
            cell.friendLabel?.text = friendName
            cell.friendImage?.image = UIImage(named: "target.scnassets/\(friendName).png")
            cell.tag = indexPath.row
            return cell
        } else {
            cell.friendLabel?.text = "Add Friend"
            cell.friendLabel?.textColor = UIColor.blue
            cell.friendImage?.image = UIImage(named: "target.scnassets/placeholder-image.png")
            cell.tag = 100 // This way we can add friend
            return cell
        }
        
        // self.collectionView?.reloadData()
    }

    
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendsTableViewCell
    //
    //        if indexPath.row < friends.count {
    //            let friendName = friends[indexPath.row]
    //            cell.friendLabel?.text = friendName
    //            cell.friendImageView?.image = UIImage(named: "target.scnassets/\(friendName).png")
    //            return cell
    //        } else {
    //            cell.friendLabel?.text = "Add Friend"
    //            cell.friendLabel?.textColor = UIColor.blue
    //            cell.friendImageView?.image = UIImage(named: "target.scnassets/placeholder-image.png")
    //            cell.tag = 100 // This way we can add friend
    //            return cell
    //        }
    //
    //    }
    //
    
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    //
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return friends.count + 1
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //        var segue: String!
    //
    //        if indexPath.row >= friends.count {
    //            print("Can add new friend")
    //            segue = "addFriend"
    //            self.performSegue(withIdentifier: segue, sender: self)
    //
    //
    //        } else {
    //            print("You selected cell #\(indexPath.row)!")
    //
    //            segue = "friendView"
    //            self.performSegue(withIdentifier: segue, sender: self)
    //
    //
    //        }
    //
    //        // self.performSegue(withIdentifier: segue, sender: self)
    //    }
    //

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
