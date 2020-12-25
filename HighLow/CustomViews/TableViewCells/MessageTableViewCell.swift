//
//  MessageTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 11/9/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    var message: String = "Your High/Lows will show up here"
    
    let messageLabel: UILabel = UILabel()
    
    func setMessage(_ msg: String) {
        self.message = msg
        messageLabel.text = msg
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont(name: "Chalkboard SE", size: 20)
            
        self.contentView.addSubview(messageLabel)
        
        messageLabel.centerX(contentView).eqTop(contentView, 20).eqWidth(contentView, 0.0, 0.9)
        
        contentView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class MessageCollectionViewCell: UICollectionViewCell {
    
    var message: String = "Your High/Lows will show up here"
    
    let messageLabel: UILabel = UILabel()
    
    func setMessage(_ msg: String) {
        self.message = msg
        messageLabel.text = msg
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
            
        self.contentView.addSubview(messageLabel)
        
        messageLabel.centerX(contentView).eqTop(contentView, 20).eqWidth(contentView, 0.0, 0.9)
        
        contentView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
    }

}
