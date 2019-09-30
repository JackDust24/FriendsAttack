//
//  Extensions.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 9/12/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    
    // This rounds the image, but
    //TODO - We may remove this
    func roundedImage() -> UIImage {
        
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = imageView.frame.width / 2
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
}

