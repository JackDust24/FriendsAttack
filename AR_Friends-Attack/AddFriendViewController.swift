//
//  AddFriendViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 4/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import CoreData

class AddFriendViewController: UIViewController {
   
    @IBOutlet weak var savePhotoButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var managedContext: NSManagedObjectContext!
    var hasPhotoBeenTaken = false // So that we can change the buttons that appear
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("View Did Appear - true")
        
        savePhotoButton.isHidden = true
        
       // delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(true)
        print("View Will Appear - true")
        
        if hasPhotoBeenTaken {
            addPhotoButton.titleLabel?.text = "Choose Other Photo"
            savePhotoButton.isHidden = false
            addPhotoButton.contentMode = .scaleToFill
        }
        
        testSampleCode()
        // Do any additional setup after loading the view.
    }
    
    
    
    func testSampleCode() {
        print("TSC")

        
        if managedContext == nil {
            print("NO CONTEXT YET")
            
            return
        }
        print("ALL HERE")

        
        //2
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {
            //3
            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                
                print(result.value(forKey: "name") ?? "no name")
                print("Add Friend")
            }
            
            //4
            // populate(friend: results.first!)
            print("")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    @IBAction func addPhoto(_ sender: Any) {
        
        presentImagePicker()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageToPass = imageView.image {
            if let destinationViewController = segue.destination as? AddFriendSecondViewController {
                destinationViewController.imageFromMasterScreen = imageToPass
                destinationViewController.managedContext = managedContext
            }
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

// Set the view controller to delegate for the navvontroller and the imagepicker as we need both
// MARK: - UINavigationControllerDelegate
extension AddFriendViewController: UINavigationControllerDelegate {
    
}


// MARK: - UIImagePickerControllerDelegate
extension AddFriendViewController: UIImagePickerControllerDelegate {
    // We set this action sheet for the user to select some options from
    func presentImagePicker() {
        
        let imagePickerActionSheet = UIAlertController(title: "Take Photo",
                                                       message: nil, preferredStyle: .actionSheet)
        
        // If the device has a camera add a Camera button to imagePickerActionSheet
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                imagePicker.allowsEditing = true
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // Add a Choose Existing button for picking from the photo library
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            imagePicker.allowsEditing = true
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        // *** Present your instance of UIAlertController
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            hasPhotoBeenTaken = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}

