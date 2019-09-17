//
//  FriendsTableViewCell.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 17/9/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    //TODO:- Work on the cell for this
    @IBOutlet var friendImage: UIImageView!
    @IBOutlet var friendLabel: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        friendImage.image = image
        friendLabel.text = title
    }

}
