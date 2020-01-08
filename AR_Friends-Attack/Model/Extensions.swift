//
//  Extensions.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 9/12/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public extension UIImage {
    
    //MARK: Images
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
    
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height

        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }

        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}

//MARK: Notifications
// For the Notifications
extension Notification.Name {
    static let kFriendAddedNotification = Notification.Name("kFriendAddedNotification")
    static let kHUDLabelNotification = Notification.Name("kHUDLabelNotification")
    static let kGameReviewNotification = Notification.Name("kGameReviewNotification")
}

//MARK: UIApplication
// Due to Key Window being depraciated.
extension UIApplication {
    // The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
