//
//  AnnouncementTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 6/25/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class AnnouncementTableViewCell: CardTableViewCell {
    
    let messageLabel = UILabel()
    var url: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let chevron = UIImageView(image: UIImage(named: "RightArrow"))
        
        contView.backgroundColor = AppColors.secondary
        contView.addSubview(messageLabel)
        contView.addSubview(chevron)
        
        chevron.eqTrailing(contView, -15).centerY(contView).width(20).aspectRatioFromWidth(1)
        
        
        messageLabel.eqLeading(contView, 15).eqTop(contView, 15).eqTrailing(chevron, -5)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 17)
        
        contView.eqBottom(messageLabel, 15)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(openLink))
        contView.addGestureRecognizer(tapper)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func openLink() {
        openURL(url)
    }

}
