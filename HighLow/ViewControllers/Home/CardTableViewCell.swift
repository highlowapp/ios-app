//
//  CardTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 6/24/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    let contView: UIView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .none
        
        self.contentView.backgroundColor = .none
        
        self.contentView.addSubview(contView)
        
        
        contView.eqWidth(self.contentView, 0, 0.9).eqTop(self.contentView, 10).centerX(self.contentView)
        
        contView.layer.cornerRadius = 15
        
        contView.backgroundColor = .white
        contView.layer.shadowColor = UIColor.black.cgColor
        contView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contView.layer.shadowOpacity = 0.1
        contView.layer.shadowRadius = 10
        
        self.contentView.bottomAnchor.constraint(equalTo: contView.bottomAnchor, constant: 10).isActive = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
