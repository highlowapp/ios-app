//
//  ShowAllCommentsViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/15/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class ShowAllCommentsViewCell: UITableViewCell {
    
    weak var delegate: ShowAllCommentsViewCellDelegate?
    
    var label: UIButton = UIButton()
    
    var active: Bool = true
    
    var state: Bool = false
    
    var section: String?
    
    var index: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateColors() {
        self.backgroundColor = getColor("White2Black")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
        
        label.setTitleColor(AppColors.primary, for: .normal)
        label.titleLabel?.font = UIFont(name: "Chalkboard SE", size: 20)!
        
        if state {
            label.setTitle("Show less comments", for: .normal)
        } else {
            label.setTitle("Show all comments", for: .normal)
        }
        
        self.addSubview(label)
                
        label.centerX(self).eqTop(self, 5)
        
        self.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        
        label.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    @objc func toggle() {
        if active {
            state = !state
            if state {
                label.setTitle("Show less comments", for: .normal)
                delegate?.showAll(sender: self)
            } else {
                label.setTitle("Show all comments", for: .normal)
                delegate?.collapse(sender: self)
            }
        } else {
            delegate?.showAll(sender: self)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func setState(_ value: Bool) {
        state = value
        
        if state {
            label.setTitle("Show less comments", for: .normal)
        } else {
            label.setTitle("Show all comments", for: .normal)
        }
    }

}


protocol ShowAllCommentsViewCellDelegate: AnyObject {
    func showAll(sender: ShowAllCommentsViewCell)
    func collapse(sender: ShowAllCommentsViewCell)
}
