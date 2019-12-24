//
//  FriendTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/26/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    let profileImageView: HLImageView = HLImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    var uid: String = ""
    weak var delegate: FriendTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        //Arrow
        self.accessoryType = .disclosureIndicator
        
        //Profile Image
        profileImageView.layer.cornerRadius = 17.5
        
        self.contentView.addSubview(profileImageView)
        
        profileImageView.eqLeading(contentView, 10).eqTop(contentView, 5).width(35).height(35)
        
        self.contentView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        
        //Name label
        nameLabel.font = .systemFont(ofSize: 20)
        nameLabel.textColor = .darkText
        
        self.contentView.addSubview(nameLabel)
        
        nameLabel.centerY(profileImageView).leadingToTrailing(profileImageView, 10)
        
    }
    
    func loadUser(_ user: User) {
        
        //Load image
        var url = user.profileimage!
        if !url.starts(with: "http") {
            url = "https://storage.googleapis.com/highlowfiles/" + url
        }
        profileImageView.loadImageFromURL(url)
        
        //Load name
        nameLabel.text = user.firstname! + " " + user.lastname!
        
        //Load uid
        uid = user.uid!
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


protocol FriendTableViewCellDelegate: AnyObject {
    func openProfile(uid: String)
}
