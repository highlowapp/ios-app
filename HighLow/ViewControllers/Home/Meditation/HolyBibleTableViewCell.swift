//
//  HolyBibleTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/21/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class HolyBibleTableViewCell: UITableViewCell {
    
    let currentScripture: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let icon = UIImageView(image: UIImage(named: "HolyBible"))
        self.contentView.addSubview(icon)
        icon.eqTop(self.contentView, 10).eqLeading(self.contentView).width(50).aspectRatioFromWidth(1)
        
        let title = UILabel()
        title.text = "KJV Bible"
        title.font = .preferredFont(forTextStyle: .title2)
        currentScripture.text = "Choose Verse"
        currentScripture.font = .preferredFont(forTextStyle: .footnote)
        currentScripture.textColor = .lightGray
        
        self.contentView.addSubview(title)
        self.contentView.addSubview(currentScripture)
        
        title.eqTop(self.contentView, 10).leadingToTrailing(icon, 5).eqTrailing(self.contentView)
        currentScripture.topToBottom(title, 5).eqLeading(title).eqTrailing(self.contentView)
        
        self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: icon.bottomAnchor, constant: 5).isActive = true
        self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: currentScripture.bottomAnchor, constant: 5).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFocusUpdate(notification:)), name: .meditationFocusChanged, object: nil)
    }
    
    @objc func onFocusUpdate(notification: NSNotification) {
        if let userInfo = notification.userInfo, let reference = userInfo["reference"] {
            self.currentScripture.text = reference as? String ?? "Choose Verse"
        }
    }

}
