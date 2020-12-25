//
//  SharingPolicyCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/23/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

struct SharingPolicyOption {
    let image: UIImage
    let title: String
    let policyDescription: String
    let categoryTitle: String
}

class SharingPolicyCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    let back = UIView()
    
    override func updateColors() {
        label.textColor = getColor("BlackText")
        back.backgroundColor = getColor("Separator")
    }
    
    override func awakeFromNib() {
        imageView.contentMode = .scaleAspectFit
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(label)
        
        imageView.centerX(self.contentView).eqTop(self.contentView, 10).eqWidth(self.contentView, 0, 0.6).aspectRatioFromWidth(1)
        label.eqLeading(self.contentView).eqTrailing(self.contentView).topToBottom(imageView, 5)
        
        
        back.backgroundColor = rgb(240, 240, 240)
        back.layer.cornerRadius = 10
        
        self.selectedBackgroundView = back
        
        self.contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        
        updateColors()
    }
    
    func loadSharingPolicyOption(_ option: SharingPolicyOption) {
        self.imageView.image = option.image
        self.label.text = option.title
    }
    
    func wasSelected() {
        /*
        self.contentView.backgroundColor = rgb(240, 240, 240)
        self.contentView.layer.cornerRadius = 10*/
    }
    
    func wasDeselected() {
        //self.contentView.backgroundColor = .white
    }
}
