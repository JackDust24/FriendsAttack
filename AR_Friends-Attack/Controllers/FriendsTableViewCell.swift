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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.backgroundColor = UIColor.white
        self.backgroundView = cellView
        
        backgroundColor = .clear // very important
//        layer.masksToBounds = false
//        layer.cornerRadius = 10
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        contentView.layer.shadowRadius = 2
//        contentView.layer.shadowColor = UIColor.darkGray.cgColor
//        contentView.layer.shadowOpacity = 0.2
        
    }
    
//    // do this in one of the init methods
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//
//        print("TABLE VIEW 1")
//
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        // add shadow on cell
//        backgroundColor = .clear // very important
//        layer.masksToBounds = false
//        layer.shadowOpacity = 0.23
//        layer.shadowRadius = 4
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowColor = UIColor.black.cgColor
//
//        // add corner radius on `contentView`
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 8
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    //
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    //TODO:- Work on the cell for this
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var killedLabel: UILabel!
    
    func displayContent(image: UIImage, title: String, killed: Int) {
        friendImage.image = image
        friendLabel.text = title
        killedLabel.text = String(killed)
    }

    
    override func layoutSubviews() {
        
        print("Layout Called")
        super.layoutSubviews()
        backgroundView?.frame = backgroundView?.frame.inset(by: UIEdgeInsets(top: 4, left: 2, bottom: 2, right: 2)) ?? CGRect.zero
    }
}
