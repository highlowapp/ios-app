//
//  Pill.swift
//  HighLow
//
//  Created by Caleb Hester on 7/16/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class Pill: UIView {

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
    }
    
}
