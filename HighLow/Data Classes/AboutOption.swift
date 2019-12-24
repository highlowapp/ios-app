//
//  AboutOption.swift
//  HighLow
//
//  Created by Caleb Hester on 9/28/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation

class AboutOption {
    
    var label: String = ""
    var action: Selector?
    var type: String
    var url: String?
    
    init(label: String, action: Selector, type: String) {
        self.label = label
        self.action = action
        self.type = type
    }
    init(label: String, action: Selector, type: String, url: String) {
        self.label = label
        self.action = action
        self.type = type
        self.url = url
    }
    
    
}
