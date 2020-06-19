//
//  PendingFriendRequestTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/29/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class PendingFriendRequestTableViewCell: UITableViewCell {

    let profileImageView: HLImageView = HLImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    var uid: String = ""
    weak var delegate: PendingFriendRequestTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    override func updateColors() {
        self.backgroundColor = getColor("White2Black")
        nameLabel.textColor = getColor("BlackText")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
        //Profile Image
        profileImageView.layer.cornerRadius = 17.5
        
        self.contentView.addSubview(profileImageView)
        
        profileImageView.eqLeading(contentView, 20).eqTop(contentView, 10).width(35).height(35)
        
        //Name label
        nameLabel.font = .systemFont(ofSize: 20)
        
        
        self.contentView.addSubview(nameLabel)
        
        nameLabel.centerY(profileImageView).leadingToTrailing(profileImageView, 10)
        
        //Description
        let description = UILabel()
        description.textColor = .lightGray
        description.font = .systemFont(ofSize: 15)
        description.text = "has requested your friendship"
        
        self.contentView.addSubview(description)
        
        description.eqLeading(nameLabel).topToBottom(profileImageView, 5)
        
        //Buttons
        let accept = UIButton()
        accept.backgroundColor = .green
        accept.layer.cornerRadius = 5
        accept.setTitle("Accept", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        
        let reject = UIButton()
        reject.backgroundColor = .red
        reject.layer.cornerRadius = 5
        reject.setTitle("Reject", for: .normal)
        reject.setTitleColor(.white, for: .normal)        
        
        self.contentView.addSubview(accept)
        self.contentView.addSubview(reject)
        
        accept.eqLeading(contentView, 10).topToBottom(description, 10).width(100).height(35)
        reject.leadingToTrailing(accept, 10).eqTop(accept).eqWidth(accept).eqHeight(accept)
        
        accept.addTarget(self, action: #selector(acceptFriendship), for: .touchUpInside)
        reject.addTarget(self, action: #selector(rejectFriendship), for: .touchUpInside)
        
        self.contentView.bottomAnchor.constraint(equalTo: accept.bottomAnchor, constant: 10).isActive = true
        
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
    
    
    @objc func rejectFriendship() {
        
        let loader = HLLoaderView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loader)
        
        loader.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        loader.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        loader.startLoading()
        authenticatedRequest(url: "/user/" + uid + "/unfriend", method: .post, parameters: [:], onFinish: { json in
            loader.stopLoading()
            loader.removeFromSuperview()
            if json["status"] != nil {
                self.delegate?.requestRejected()
            }
            
        }, onError: { error in
            loader.stopLoading()
            loader.removeFromSuperview()
        })
        
    }
    
    
    @objc func acceptFriendship() {
        
        let loader = HLLoaderView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loader)
        
        loader.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        loader.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        loader.startLoading()
        authenticatedRequest(url: "/user/accept_friend/" + uid, method: .post, parameters: [:], onFinish: { json in
            loader.stopLoading()
            loader.removeFromSuperview()
            if json["status"] != nil {
                self.delegate?.requestAccepted()
            }
        }, onError: { error in
            loader.stopLoading()
            loader.removeFromSuperview()
        })
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


protocol PendingFriendRequestTableViewCellDelegate: AnyObject {
    func requestRejected()
    func requestAccepted()
}
