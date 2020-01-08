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
    
    //MARK: Properties
    var imageFromMasterScreen: UIImage?
    var imageForGame: UIImage?
    var imageForThumbNail: UIImage?

    var nameOfImage: String?
    var managedContext: NSManagedObjectContext!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var friendImage: UIImageView!  {
        didSet {
            self.configureView()
        }
    }
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the rounded borders for the view
        displayForSecondView(view: self.secondView)
        addCornerRadiusToButton(button: self.saveBtn)
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
    }

    func configureView() {
        // Update the user interface for the detail item.
        if self.friendImage == nil || imageFromMasterScreen == nil { return } // no web view, bail out
        // We know this won't be a nil
        friendImage.image = imageFromMasterScreen!
        resizeTheImage(image: friendImage.image!)
    }
    
    //MARK:- Text Field
    // For typing in name
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            nameTextField.becomeFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Nothing to do here as of yet
    }
    
    // If text field is empty
    func updateNameFromTextField(nameToUpdate: String?) {
        guard let name = nameToUpdate else {
            return
        }
        
        nameOfImage = name
    }
    
    //MARK:- Buttons for saving and press Done

    // Done pressed by user on keyboard
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        // Check if nil or contains whitespace
        if nameTextField.text == "" {
            showMessage(messageType: "blank")
            return
        }
        // We check to see if name is already in the database.
        // We can unwrap it as it would have not got this far otherwise
        let duplicateNameCheck = seeIfNameAlreadyExists(name: nameTextField.text!)
        if duplicateNameCheck {
            showMessage(messageType: "duplicate")
            return
        }
        
        // We want to remove any whitespaces
        let trimmedName = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.count <= 0 {
            showMessage(messageType: "blank")
            return
        }
        
        if trimmedName.count > 13 {
            print("Over Limit")
            showMessage(messageType: "overlimit")
            return
        }
        
        // Update the Text Field and Context
        updateNameFromTextField(nameToUpdate: trimmedName)
        updateContext()
        // Send notification to StartVIewController to update that we have added a friend
        let dic = ["FriendAdded":nameTextField.text!]
        NotificationCenter.default.post(name: .kGameReviewNotification, object: nil, userInfo: dic)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func seeIfNameAlreadyExists(name: String) -> Bool {
        
        if managedContext == nil {
            return false
        }
        
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            let results = try managedContext.fetch(request)
            // Fetch List Records
            for result in results {
                print(result.value(forKey: "name") ?? "no name")
                let nameInDB = (result.value(forKey: "name") as! String)
                if nameInDB == name {
                    return true // Name already exists so we must get them to add a new one
                }
            }
            
        } catch let error as NSError {
            //TODO: - Core Data Error Hnadling Handling
            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")

        }
        return false
    }
    
    //MARK: Images and Messages
    func resizeTheImage(image: UIImage) {
        // For the coreData saving the size of the immage
        imageForGame = image.resizedImageWithinRect(rectSize: CGSize(width: 50, height: 50))
        imageForThumbNail = image.resizedImageWithinRect(rectSize: CGSize(width: 25, height: 25))
    }
    
    func showMessage(messageType: String) {
        
        var alertNameMissing = UIAlertController()
        if messageType == "blank" {
            alertNameMissing = UIAlertController(title: NSLocalizedString("Missing Name", comment: "Alert Title"),
                                                     message: NSLocalizedString("Please Add a Name", comment: "Message Alert"), preferredStyle: .alert)
            alertNameMissing.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { action in
                self.nameTextField.becomeFirstResponder()
            }))
        }
        
        if messageType == "duplicate" {
            alertNameMissing = UIAlertController(title: NSLocalizedString("Duplicate Name", comment: "Alert Title"),
                                                     message: NSLocalizedString("Name Already Exists", comment: "Message Alert"), preferredStyle: .alert)
            alertNameMissing.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { action in
                self.nameTextField.becomeFirstResponder()
                self.nameTextField.text = ""
            }))
        }
        
        if messageType == "overlimit" {
            alertNameMissing = UIAlertController(title: NSLocalizedString("Name Is Too Long", comment: "Alert Title"),
                                                     message: NSLocalizedString("Please Limit To 13 Characters", comment: "Message Title"), preferredStyle: .alert)
            alertNameMissing.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { action in
                self.nameTextField.becomeFirstResponder()
                self.nameTextField.text = ""
            }))
        }
        present(alertNameMissing, animated: true)
    }
    
    //MARK: Update Core Data
    func updateContext() {
        
        let context = managedContext
        let image2 = imageForGame
        let photoData2 = image2!.pngData()!
        let photoDataValue2 = NSData(data: photoData2) as Data
        
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: context!)
        let newFriend = NSManagedObject(entity: entity!, insertInto: context)
        newFriend.setValue(nameOfImage, forKey: "name")
        newFriend.setValue(photoDataValue2, forKey: "friendImage")
        newFriend.setValue(true, forKey: "active")
        newFriend.setValue(0, forKey: "killed")

        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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


