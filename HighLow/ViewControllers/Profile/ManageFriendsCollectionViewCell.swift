//
//  ManageFriendsCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 12/9/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ManageFriendsCollectionViewCell: UICollectionViewCell {
    weak var delegate: ManageFriendsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let button = UIButton()
        button.setTitle("Manage", for: .normal)
        button.setImage(UIImage(named: "add_friend"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.secondary
        button.layer.cornerRadius = 10
        
        self.contentView.addSubview(button)
        button.centerX(self.contentView).centerY(self.contentView).width(145).height(50)
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        
        self.contentView.trailingAnchor.constraint(greaterThanOrEqualTo: button.trailingAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor).isActive = true
    }
    
    @objc func onTap() {
        self.delegate?.wasTapped()
    }
}

protocol ManageFriendsCollectionViewCellDelegate: AnyObject {
    func wasTapped()
}
