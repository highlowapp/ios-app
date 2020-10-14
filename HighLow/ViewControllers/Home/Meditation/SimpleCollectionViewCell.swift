//
//  SimpleCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 9/1/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class SimpleCollectionViewCell: UICollectionViewCell {
    let label: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(label)
        
        label.eqLeading(self.contentView, 10).eqTop(self.contentView).eqBottom(self.contentView)
        
        label.textAlignment = .center
        
        self.contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
    }
}
