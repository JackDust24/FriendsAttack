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
    
    var hasPhotoBeenTaken = false // So that we can swap between Save and Add image
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savePhotoButton.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(true)
        
        // If photo has been taken, we can ask user if they wish to take again
        if hasPhotoBeenTaken {
//            addPhotoButton.titleLabel?.text = "Change Photo"
            addPhotoButton.setTitle("Change Photo", for: .normal)
            addPhotoButton.titleLabel?.font = UIFont.init(name: "Helvetica", size:18)
            savePhotoButton.isHidden = false
            addPhotoButton.contentMode = .scaleToFill
        }
        
        testSampleCode()
        // Do any additional setup after loading the view.
    }
    
    
    //TODO: - We can remove this soon
    func testSampleCode() {

        if managedContext == nil {
            return
            
        }
        
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {

            let results = try managedContext.fetch(request)
            
            // Fetch List Records
            for result in results {
                
                print(result.value(forKey: "name") ?? "no name")
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    // Get Image
    @IBAction func addPhoto(_ sender: Any) {
        presentImagePicker()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageToPass = imageView.image {
            if let destinationViewController = segue.destination as? AddFriendSecondViewController {
                destinationViewController.imageFromMasterScreen = imageToPass
                destinationViewController.managedContext = managedContext
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("didFinishPickingMediaWithInfo")

        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            let roundedImage = img.roundedImage()
            imageView.image = roundedImage
            
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageView.image = img
        }
        
        hasPhotoBeenTaken = true
        dismiss(animated: true, completion: nil)
        
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
