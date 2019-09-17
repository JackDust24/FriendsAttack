//
//  FriendsCollectionViewCall.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 30/7/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import Foundation
import UIKit

//TODO- Delete this file
class FriendsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var friendImage: UIImageView!
    @IBOutlet var friendLabel: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        friendImage.image = image
        friendLabel.text = title
    }
}

