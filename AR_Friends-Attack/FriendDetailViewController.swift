//
//  FriendDetailViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit

struct FriendDetails {
    
    var name: String
    var hits: Int
    var games: Int
    var kills: Int
    var ranking: String
}

class FriendDetailViewController: UIViewController {

    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
   
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    @IBOutlet weak var friendImage: UIImageView! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()


        // Do any additional setup after loading the view.
    }
   
    // This is a struct with all the details.
    var detailItem: FriendDetails? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var name: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if self.rankingLabel == nil { return } // no web view, bail out
//        if let detailContent = detailItem?.valueForKey("content") as? String{
//            self.webView.loadHTMLString(detailContent as String, baseURL:nil)
//        }
        // Update the details with the struct
        
        print("Detail item - \(String(describing: detailItem))")
        nameLabel.text = detailItem?.name
        killsLabel.text = "\(detailItem?.kills ?? 0)"
        hitsLabel.text = "\(detailItem?.hits ?? 0)"
        gamesLabel.text = "\(detailItem?.games ?? 0)"
        rankingLabel.text = detailItem?.ranking
        
        friendImage.image = UIImage(named: "target.scnassets/\(detailItem?.name ?? "Friend").png")

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
