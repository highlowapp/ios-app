//
//  CardTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 6/24/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    let contView: UIView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .none
        
        self.contentView.backgroundColor = .none
        
        self.contentView.addSubview(contView)
        
        contView.eqLeading(self.contentView, 20).eqTop(self.contentView, 10).centerX(self.contentView).eqTrailing(self.contentView, -20).eqBottom(self.contentView, -20)
        
        contView.layer.cornerRadius = 15
        
        contView.backgroundColor = .white
        contView.layer.shadowColor = UIColor.black.cgColor
        contView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contView.layer.shadowOpacity = 0.1
        contView.layer.shadowRadius = 10
        
    }
}
