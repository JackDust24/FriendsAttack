//
//  FriendDetailViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit

class FriendDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel! {
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
    // USE LATER
    var detailItem: AnyObject? {
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
        if self.nameLabel == nil { return } // no web view, bail out
//        if let detailContent = detailItem?.valueForKey("content") as? String{
//            self.webView.loadHTMLString(detailContent as String, baseURL:nil)
//        }
        // nameLabel.text = name
        nameLabel.text = "Test"
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
