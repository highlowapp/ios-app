//
//  DateCell.swift
//  HighLow
//
//  Created by Caleb Hester on 9/20/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import JTAppleCalendar
import UIKit

class DateCell: JTACDayCell {
    var dateLabel: UILabel! = UILabel()
    var bubble: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        self.addSubview(bubble)
        bubble.addSubview(dateLabel)
        
        bubble.layer.cornerRadius = 17.5
            
        bubble.centerX(self).centerY(self).width(35).height(35)
        dateLabel.centerX(bubble).centerY(bubble)
        
        dateLabel.textAlignment = .center
       
    }
    
    var isFulfilled: Bool = false {
        didSet {
            if isFulfilled {
                self.bubble.backgroundColor = AppColors.primary
                self.dateLabel.textColor = .white
            } else {
                self.bubble.backgroundColor = .white
                self.dateLabel.textColor = .black
            }
        }
    }
}
