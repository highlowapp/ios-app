//
//  AboutSection.swift
//  HighLow
//
//  Created by Caleb Hester on 9/28/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

class AboutSection {

    var options: [AboutOption] = []
    var title: String = "Untitled Section"
    
    init(title: String, options: [AboutOption]) {
        self.options = options
        self.title = title
    }

}
