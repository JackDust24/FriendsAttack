//
//  FriendDetailViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

// Details for the Friend
struct FriendDetails {
    
    var name: String
    var image: UIImage
    var killed: Int
}

class FriendDetailViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var killedLabel: UILabel!
    
    
    @IBOutlet weak var exitBtn: UIButton!
    
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
    
    //MARK:- The struct details
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
    
    //MARK:- Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        
        addCornerRadiusToButton(button: self.exitBtn)
        
    }
    
    func configureView() {
     
        // Update the user interface for the detail item.
        if self.killedLabel == nil { return } // no web view, bail out
        
        print("Detail item - \(String(describing: detailItem))")
        nameLabel.text = detailItem?.name
        killedLabel.text = "\(detailItem?.killed ?? 0)"
        friendImage.image = detailItem?.image

    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(true)
        
        print("View Will Appear - true")

    }
    
    @IBAction func exit(_ sender: Any) {
        //TODO- Add Code for Exit
        self.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
