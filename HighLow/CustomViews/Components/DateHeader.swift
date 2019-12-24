//
//  DateHeader.swift
//  HighLow
//
//  Created by Caleb Hester on 9/24/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import JTAppleCalendar

@IBDesignable
class DateHeader: JTACMonthReusableView {

    var monthTitle: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.addSubview(monthTitle)
        
        monthTitle.centerX(self).centerY(self)
        
        monthTitle.font = .systemFont(ofSize: 23)
        
        monthTitle.textColor = .black
        
        monthTitle.text = "Month Title"
    }

}
