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
   
    //MARK: Properties
    @IBOutlet weak var savePhotoButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var secondView: UIView!
    var managedContext: NSManagedObjectContext!
    var hasPhotoBeenTaken = false // So that we can swap between Save and Add image
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call the helper view so can round the borders
        displayForSecondView(view: self.secondView)
        addCornerRadiusToButton(button: self.addPhotoButton)
        addCornerRadiusToButton(button: self.savePhotoButton)
        
        savePhotoButton.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(true)
    }
    
    // This is called to change the buttton after a photo has been taken
    override func viewDidLayoutSubviews() {
        // Check if Phot oHas been taken
        if hasPhotoBeenTaken {
            self.addPhotoButton.setTitle(NSLocalizedString("Change Photo", comment: "Button Title"), for: .normal)
            self.addPhotoButton.isOpaque = true
            savePhotoButton.isHidden = false
            savePhotoButton.setNeedsFocusUpdate()
        }
    }
    
    //MARK: Outlets and Actions
    @IBAction func addPhoto(_ sender: Any) {
        presentImagePicker()
        
    }
    
    @IBAction func exit(_ sender: Any) {
        //If Photo taken, ask user if they are okay for leaving the screen. Otherwise just leave the screen.
        if hasPhotoBeenTaken {
            alertExitBeforeSave()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: Alerts
    
    // Gets called after pressing play
    func alertExitBeforeSave() {

        let actionSheet = UIAlertController(title: NSLocalizedString("Not Saved", comment: "Alert Title"), message: kDefaultExitBeforeSave, preferredStyle: .alert)

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Alert Title"), style: .default, handler: { action in
            // Can leave the screen
            self.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)

        }))

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Alert Title"), style: .cancel, handler: { action in
               // Cancel button tappped.

            self.dismiss(animated: true)
        }))
        // Present action sheet.

        if UIDevice.current.userInterfaceIdiom == .pad {

            if let currentPopoverpresentioncontroller = actionSheet.popoverPresentationController {
                currentPopoverpresentioncontroller.permittedArrowDirections = []
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: (self.view.bounds.midX), y: (self.view.bounds.midY), width: 0, height: 0)
                currentPopoverpresentioncontroller.sourceView = self.view

                self.present(actionSheet, animated: true, completion: nil)
            }
            
        } else {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    //MARK: Controllers
    
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

// MARK: - UINavigationControllerDelegate
// Set the view controller to delegate for the navvontroller and the imagepicker as we need both
extension AddFriendViewController: UINavigationControllerDelegate {
    
}

// MARK: - UIImagePickerControllerDelegate
extension AddFriendViewController: UIImagePickerControllerDelegate {
    // We set this action sheet for the user to select some options from
    func presentImagePicker() {
        
        let imagePickerActionSheet = UIAlertController(title: NSLocalizedString("Take Photo", comment: "Picker Title"),
                                                       message: nil, preferredStyle: .actionSheet)
        
        // If the device has a camera add a Camera button to imagePickerActionSheet
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Picker Title"),
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
        let libraryButton = UIAlertAction(title: NSLocalizedString("Access Photos", comment: "Picker Title"),
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            imagePicker.allowsEditing = true
                                            self.present(imagePicker, animated: true)
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Title"), style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        // *** Present your instance of UIAlertController
        // present(imagePickerActionSheet, animated: true)
        
        if UIDevice.current.userInterfaceIdiom == .pad {

            if let currentPopoverpresentioncontroller = imagePickerActionSheet.popoverPresentationController {
            currentPopoverpresentioncontroller.permittedArrowDirections = []
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                currentPopoverpresentioncontroller.sourceView = self.view

                self.present(imagePickerActionSheet, animated: true, completion: nil)
            }
            
        } else {
            self.present(imagePickerActionSheet, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
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
