//
//  FriendsTableViewCell.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 17/9/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//
// For viewing Friends

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    //MARK:- Properties
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var killedLabel: UILabel!
    
    //MARK:- Setup and Views
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up view so that it is curved for each cell
        backgroundColor = .clear // very important
        cellView.backgroundColor = UIColor.lightGray
        self.backgroundView = cellView
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
        
    }
    
    // We call this from the tableview in FriendsViewController
    func displayContent(image: UIImage, title: String, killed: Int, addFriend: Bool) {
        
        if addFriend {
            killedLabel.text = ""
            // friendLabel.font.withSize(44)
            friendLabel.textColor = UIColor.red
            // killedLabel.alpha = 0.0
            self.friendLabel.adjustsFontSizeToFitWidth = true
            //self.cellView.bringSubviewToFront(friendLabel)
            
        } else {
            killedLabel.text = String(killed)
            friendLabel.textColor = UIColor.black
        }
        friendImage.image = image
        friendLabel.text = title
    }

    // For adding spaces between each row
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = backgroundView?.frame.inset(by: UIEdgeInsets(top: 4, left: 2, bottom: 2, right: 2)) ?? CGRect.zero
    }
    
    deinit {
        self.backgroundView = nil
    }
}
