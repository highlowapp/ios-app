//
//  NewPendingRequestCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 12/5/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class NewPendingRequestCollectionViewCell: CardCollectionViewCell {
    weak var delegate: NewPendingRequestCollectionViewCellDelegate?
    
    var user: UserResource? {
        didSet {
            user?.registerReceiver(self, onDataUpdate: onUserUpdate(_:_:))
        }
    }
    
    let profileImageView: HLRoundImageView = HLRoundImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contView.addSubviews([self.profileImageView, self.nameLabel])
        
        self.profileImageView.eqTop(self.contView, 20).height(40).aspectRatioFromHeight(1).eqLeading(self.contView, 20)
        self.nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        self.nameLabel.leadingToTrailing(self.profileImageView, 10).centerY(self.profileImageView)
        self.nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contView.trailingAnchor, constant: -20).isActive = true
        
        let accept = UIButton()
        accept.backgroundColor = .green
        accept.layer.cornerRadius = 5
        accept.setTitle("Accept", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        accept.addTarget(self, action: #selector(acceptFriendship), for: .touchUpInside)
        
        let reject = UIButton()
        reject.backgroundColor = .red
        reject.layer.cornerRadius = 5
        reject.setTitle("Reject", for: .normal)
        reject.setTitleColor(.white, for: .normal)
        reject.addTarget(self, action: #selector(rejectFriendship), for: .touchUpInside)
        
        self.contView.addSubviews([accept, reject])
        
        accept.eqLeading(self.contView, 20).topToBottom(self.profileImageView, 10).width(100).height(35)
        reject.leadingToTrailing(accept, 10).eqTop(accept).width(100).height(35)
        
        self.contView.bottomAnchor.constraint(equalTo: accept.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc func acceptFriendship() {
        guard let user = self.user else { return }
        UserService.shared.acceptFriend(uid: user.uid ?? "", onSuccess: { json in
            self.delegate?.decidedPendingRequest()
        }, onError: { error in
            alert()
        })
    }
    
    @objc func rejectFriendship() {
        guard let user = self.user else { return }
        UserService.shared.rejectFriend(uid: user.uid ?? "", onSuccess: { json in
            self.delegate?.decidedPendingRequest()
        }, onError: { error in
            alert()
        })
    }
    
    func onUserUpdate(_ sender: NewPendingRequestCollectionViewCell, _ user: User) {
        self.profileImageView.loadImageFromURL( user.getProfileImage() )
        self.nameLabel.text = user.fullName()
    }
    /*
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            layoutIfNeeded()
            layoutAttributes.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
    }*/
}

protocol NewPendingRequestCollectionViewCellDelegate: AnyObject {
    func decidedPendingRequest()
}
