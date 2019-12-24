//
//  InterestTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 12/20/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class InterestTableViewCell: UITableViewCell {
    
    var name: String = ""
    var id: String = ""
    let button: UIButton = UIButton()
    
    weak var delegate: InterestTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
                
        button.setTitle("Add", for: .normal)
        button.setTitleColor(AppColors.primary, for: .normal)
        
        button.addTarget(self, action: #selector(willAdd), for: .touchUpInside)
        
        self.textLabel?.text = name
        
        self.contentView.addSubview(button)
        
        button.eqTop(contentView)
              .height(50)
              .eqWidth(contentView, 0.0, 0.2)
              .eqTrailing(contentView)
        
        self.contentView.bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "interest")
        
        self.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.awakeFromNib()
    }
    
    func loadInterest(_ interest: [String: String]) {
        name = interest["name"] ?? ""
        id = interest["interest_id"] ?? ""
        
        textLabel?.text = name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func willAdd() {
        self.button.isHidden = true
        self.delegate?.willAdd(id: id, name: name)
    }

}

protocol InterestTableViewCellDelegate: AnyObject {
    func willAdd(id: String, name: String)
}
