//
//  AddFriendSecondViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 12/8/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit

class AddFriendSecondViewController: UIViewController {
    
    var imageFromMasterScreen: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var friendImage: UIImageView!  {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if self.friendImage == nil || imageFromMasterScreen == nil { return } // no web view, bail out
        //        if let detailContent = detailItem?.valueForKey("content") as? String{
        //            self.webView.loadHTMLString(detailContent as String, baseURL:nil)
        //        }
        // Update the details with the struct
        
        // Do we want to force unwrap this could be a nil
        friendImage.image = imageFromMasterScreen!
        // friendImage.image = UIImage(named: "target.scnassets/\(detailItem?.name ?? "Friend").png")
        
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


