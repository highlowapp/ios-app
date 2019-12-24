//
//  StreakView.swift
//  HighLow
//
//  Created by Caleb Hester on 7/18/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class StreakView: UIView {
    
    var streakNumLabel: UILabel = UILabel()
    let streakIconView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    
    private func setup() {
        
        //Set image for streakIconView
        streakIconView.image = UIImage(named: "streak")
        
        
        //Typography
        streakNumLabel.text = "0"
        streakNumLabel.textColor = .white
        streakNumLabel.font = UIFont.systemFont(ofSize: 30)
        
        //Add the subviews
        self.addSubview(streakNumLabel)
        self.addSubview(streakIconView)
        
        //Constraints        
        streakIconView.eqTrailing(self).width(45).height(45)
        streakNumLabel.leadingToTrailing(streakIconView, -3).centerY(streakIconView)
        
        self.sizeToFit()
        
    }
    

}
