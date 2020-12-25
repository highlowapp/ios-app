//
//  NewPendingRequestCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 12/5/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: CardCollectionViewCell {
    
    var user: UserResource? {
        didSet {
            user?.registerReceiver(self, onDataUpdate: onUserUpdate(_:_:))
        }
    }
    
    let profileImageView: HLRoundImageView = HLRoundImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    
    override func updateColors() {
        super.updateColors()
        nameLabel.textColor = getColor("BlackText")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let container = UIView()
        self.contView.addSubview(container)
        
        container.addSubviews([self.profileImageView, self.nameLabel])
        
        self.profileImageView.eqTop(container).height(50).aspectRatioFromHeight(1).centerX(container)
        self.nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        self.nameLabel.topToBottom(self.profileImageView, 10).centerX(self.profileImageView)
        
        container.centerX(self.contView).centerY(self.contView).eqBottom(self.nameLabel)
        //self.contView.eqBottom(self.nameLabel, 20)
    }
    
    func onUserUpdate(_ sender: FriendCollectionViewCell, _ user: User) {
        self.profileImageView.loadImageFromURL( user.getProfileImage() )
        self.nameLabel.text = user.fullName()
    }
    
    /*
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            layoutIfNeeded()
            layoutAttributes.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
    }
 */
}

