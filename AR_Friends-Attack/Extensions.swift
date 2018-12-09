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

