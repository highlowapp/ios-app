//
//  AddOptionCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/10/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class AddOptionCell: UICollectionViewCell {
    var addOption: AddOption?
    
    let title: UILabel = UILabel()
    let image: UIImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let container = UIView()
        
        self.contentView.addSubview(container)
        container.addSubview(image)
        container.addSubview(title)
        
        image.contentMode = .scaleAspectFit
        
        container.centerX(self.contentView).centerY(self.contentView).eqWidth(self.contentView)
        
        image.centerX(container).eqTop(container).width(50).height(50)
        title.topToBottom(image, 15).centerX(container).eqWidth(container, -20)
        
        container.eqBottom(title)
        
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 17)
        title.textColor = .gray
    }
    
    func setAddOption(_ addOption: AddOption) {
        self.addOption = addOption
        title.text = addOption.title
        image.image = UIImage(named: addOption.image)
    }
}

struct AddOption {
    let image: String
    let title: String
    let action: Selector
}
