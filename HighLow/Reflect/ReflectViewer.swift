//
//  ReflectViewer.swift
//  HighLow
//
//  Created by Caleb Hester on 6/27/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit
import Gridicons

class ReflectViewer: WKWebView, UITextFieldDelegate {

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    
    
    func load() {
        let url = Bundle.main.url(forResource: "view", withExtension: "html")!
        self.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    func loadBlocks(_ blocks: NSDictionary) {
        do {
            let blocksString = try JSONSerialization.data(withJSONObject: blocks, options: .prettyPrinted)
            self.load()
            self.evaluateJavaScript("setBlocks(\(blocksString))")
        } catch {
            self.load()
        }
        
    }
    
}

