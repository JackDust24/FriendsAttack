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
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        
        addCornerRadiusToButton(button: self.saveBtn)
        
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
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

        // We know this won't be a nil
        friendImage.image = imageFromMasterScreen!
        
    }
    
    //MARK:- Text Field
    // For typing in name
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameTextField {
            print("You edit myTextField")
            nameTextField.becomeFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("DID END TEXT")
    }
    
    func updateNameFromTextField() {
        guard let name = nameTextField.text else {
            print("Text Field didn't have a name in it.")
            return
        }
        nameOfImage = name
    }
    
    //MARK:- Buttons for saving and press Done
    //TODO:- Need to 1. Use has option for Save or Return, 2. Store the name, 3. Save the details

    // For finishing - this needs to change for the save.
    @IBAction func done(_ sender: Any) {
        
        print("Contents of text field - \(nameTextField.text ?? "")")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        print("PRESSED SAVE")
        print("\(String(describing: nameTextField.text))")
        
        if nameTextField.text == "" {
            print("nameTextField.text == nil")

            showMessage()
            
            return
        }
        
        updateNameFromTextField()
        updateContext()
        //TODO: - We can remove this of saving the Sample COde
        testSampleCode()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showMessage() {
        
        let alertNameMissing = UIAlertController(title: "Missing Name",
                                                       message: "Please add a name", preferredStyle: .alert)
        
        alertNameMissing.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
            self.nameTextField.becomeFirstResponder()
        }))
        
        // If the device has a camera add a Camera button to imagePickerActionSheet
//        let okButton = UIAlertAction(title: "Ok", style: .default)
//        alertNameMissing.addAction(okButton)
        
        // *** Present your instance of UIAlertController
        present(alertNameMissing, animated: true)
    }
    
    func updateContext() {
        
        let context = managedContext
        // Convert Image - TODO
        let image = imageFromMasterScreen
        let photoData = image!.pngData()!
        let photoDataValue = NSData(data: photoData) as Data
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: context!)
        let newFriend = NSManagedObject(entity: entity!, insertInto: context)
        newFriend.setValue(nameOfImage, forKey: "name")
        newFriend.setValue(photoDataValue, forKey: "friendImage")
        newFriend.setValue(true, forKey: "active")
        newFriend.setValue(0, forKey: "killed")
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


