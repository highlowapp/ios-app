//
//  FriendTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/26/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {
    
    let profileImageView: HLImageView = HLImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    var uid: String = ""
    let addButton: UIButton = UIButton()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
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
        self.backgroundColor = getColor("White2Black")
        //Profile Image
        profileImageView.layer.cornerRadius = 17.5
        
        self.contentView.addSubview(profileImageView)
        
        profileImageView.eqLeading(contentView, 10).eqTop(contentView, 5).width(35).height(35)
        
        self.contentView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        
        //Name label
        nameLabel.font = .systemFont(ofSize: 20)
        nameLabel.textColor = getColor("BlackText")
        
        self.contentView.addSubview(nameLabel)
        
        nameLabel.centerY(profileImageView).leadingToTrailing(profileImageView, 10)
        
        //Add button
        addButton.setTitleColor(AppColors.primary, for: .normal)
        addButton.setTitle("Add", for: .normal)
        
        self.contentView.addSubview(addButton)
        
        addButton.eqTrailing(contentView, -20).centerY(nameLabel)
        
        addButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        
        self.addSubview(activityIndicator)
        activityIndicator.eqTrailing(contentView)
        
        activityIndicator.hidesWhenStopped = true
    }
    
    
    @objc func addFriend() {
        
        
        activityIndicator.startAnimating()
        addButton.isHidden = true
        
        
        authenticatedRequest(url: "/user/" + self.uid + "/request_friend", method: .post, parameters: [:], onFinish: { json in
            
            self.activityIndicator.stopAnimating()
            
            
            if json["status"] != nil {
                self.addButton.removeFromSuperview()
            } else {
                self.addButton.isHidden = false
            }
            
        }, onError: { error in
            
            self.activityIndicator.stopAnimating()
            self.addButton.isHidden = false
            
        })
        
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
