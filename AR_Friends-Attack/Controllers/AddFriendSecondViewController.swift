//
//  AddFriendSecondViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 12/8/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class AddFriendSecondViewController: UIViewController, UITextFieldDelegate {
    
    var imageFromMasterScreen: UIImage?
    var nameOfImage: String?
    var managedContext: NSManagedObjectContext!
    @IBOutlet weak var nameTextField: UITextField!
    
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

        // Do we want to force unwrap this could be a nil
        friendImage.image = imageFromMasterScreen!
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            print("You edit myTextField")
            nameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func done(_ sender: Any) {
        print("Contents of text field - \(nameTextField.text ?? " ")")
        dismiss(animated: true, completion: nil)
    }
    
//
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("DID END TEXT")
    }
    
    @IBAction func Save(_ sender: Any) {
        if nameTextField.text == nil {
            print("We need a name and to issue Action Alert.")
            return
        }
        updateNameFromTextField()
        updateContext()
        testSampleCode()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateNameFromTextField() {
        guard let name = nameTextField.text else {
            print("Text Field didn't have a name in it.")
            return
        }
        nameOfImage = name
    }

    
    func updateContext() {
        
        let context = managedContext
        // Convert Image - TODO
        let image = imageFromMasterScreen
        let photoData = UIImagePNGRepresentation(image!)!
        let photoDataValue = NSData(data: photoData) as Data
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: context!)
        let newFriend = NSManagedObject(entity: entity!, insertInto: context)
        newFriend.setValue(nameOfImage, forKey: "name")
        newFriend.setValue(photoDataValue, forKey: "friendImage")
        newFriend.setValue(true, forKey: "active")
        try! managedContext.save()
    }
    

    
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
                print("testSampleCode")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

}


