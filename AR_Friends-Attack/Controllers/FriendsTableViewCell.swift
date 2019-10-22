//
//  FriendsTableViewCell.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 17/9/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var killedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set up view so that it is curved for each cell
        backgroundColor = .clear // very important
        cellView.backgroundColor = UIColor.lightGray
        self.backgroundView = cellView
        
//        backgroundColor = .clear // very important
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        contentView.layer.shadowRadius = 2
//        contentView.layer.shadowColor = UIColor.darkGray.cgColor
//        contentView.layer.shadowOpacity = 0.2
        
    }
    
    // We call this from the tableview
    func displayContent(image: UIImage, title: String, killed: Int) {
        friendImage.image = image
        friendLabel.text = title
        killedLabel.text = String(killed)
    }

    // For adding spaces between each row
    override func layoutSubviews() {
        
        print("Layout Called")
        super.layoutSubviews()
        backgroundView?.frame = backgroundView?.frame.inset(by: UIEdgeInsets(top: 4, left: 2, bottom: 2, right: 2)) ?? CGRect.zero
    }
}
