//
//  FriendDetailViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

struct FriendDetails {
    
    var name: String
    var killed: Int
}

class FriendDetailViewController: UIViewController {

    @IBOutlet weak var killedLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!

   
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
        
        if self.killedLabel == nil { return } // no web view, bail out
//        if let detailContent = detailItem?.valueForKey("content") as? String{
//            self.webView.loadHTMLString(detailContent as String, baseURL:nil)
//        }
        // Update the details with the struct
        
        print("Detail item - \(String(describing: detailItem))")
        nameLabel.text = detailItem?.name
        killedLabel.text = "\(detailItem?.killed ?? 0)"

        friendImage.image = UIImage(named: "target.scnassets/\(detailItem?.name ?? "Friend").png")

    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(true)
        print("View Will Appear - true")
        testSampleCode()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testSampleCode() {
        
        if managedContext == nil {
            return
        }
        
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {
            //3
            let results = try managedContext.fetch(request)
            // Fetch List Records
            for result in results {
                print(result.value(forKey: "name") ?? "no name")
                print("Friend")
            }
            
            // populate(friend: results.first!)
            print("")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
