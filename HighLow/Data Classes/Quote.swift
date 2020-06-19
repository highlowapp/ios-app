//
//  Quote.swift
//  HighLow
//
//  Created by Caleb Hester on 1/25/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class Quote {
    private var author: String = ""
    private var quote: String = ""
    
    init(author: String, quote: String) {
        self.author = author
        self.quote = quote
    }
    
    func getAuthor() -> String {
        return author
    }
    
    func getQuote() -> String {
        return quote
    }
}
