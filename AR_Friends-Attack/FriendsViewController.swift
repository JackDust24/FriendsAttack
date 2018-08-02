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
        
        // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        print("Prepare for segue")
//
//        if segue.identifier == "friendView" {
//            if let indexPath = collectionView.indexPath(for: collectionView) {
//                let detailVC = segue.destination as! FriendDetailViewController
//                detailVC.name = friends[indexPath.row]
//            }
//        }
//
//    }
    
//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//
//
//        if identifier == "friendView" {
//
//            if let indexPath = tableView.indexPathForSelectedRow{
//                let selectedRow = indexPath.row
//                let detailVC = FriendDetailViewController()
//                detailVC.park = self.parksArray[selectedRow]
//            }
//
//            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//            let secondViewController = storyboard.instantiateViewController(withIdentifier: "FriendDetailViewController") as! FriendDetailViewController
//            //let friendName = friends[indexPath.row]
//
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//            // secondViewController.name = friendName
//        }
//    }

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
    

    // MARK: - Collection Views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FriendsCollectionViewCall
        
        if indexPath.row < friends.count {
            let friendName = friends[indexPath.row]
            cell.friendLabel?.text = friendName
            cell.friendImage?.image = UIImage(named: "target.scnassets/\(friendName).png")
            return cell
        } else {
            cell.friendLabel?.text = "Add Friend"
            cell.friendLabel?.textColor = UIColor.blue
            cell.friendImage?.image = UIImage(named: "target.scnassets/placeholder-image.png")
            cell.tag = 100 // This way we can add friend
            return cell
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
