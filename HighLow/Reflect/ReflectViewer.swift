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
    
    var contentScrollHeight: CGFloat = 0.0
    var hasLoaded: Bool = false

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
        if !hasLoaded {
            let url = Bundle.main.url(forResource: "view", withExtension: "html")!
            self.loadFileURL(url, allowingReadAccessTo: url)
            hasLoaded = true
        }
    }
    
    func loadBlocks(_ blocks: [NSDictionary], completion: @escaping () -> Void = {}) {
        do {
            let blocksString = try JSONSerialization.data(withJSONObject: blocks, options: .prettyPrinted)
            let jsonStr = NSString(data: blocksString, encoding: String.Encoding.utf8.rawValue)! as String
            self.evaluateJavaScript("setBlocks(\(jsonStr))", completionHandler: { blah, blah2 in
                self.evaluateJavaScript("document.body.scrollHeight") { result, error in
                    guard error == nil else {
                        completion()
                        return
                    }
                    
                    self.contentScrollHeight = result as! CGFloat
                    completion()
                }
            })
        } catch {
            //self.load()
        }
        
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: self.scrollView.contentSize.width, height: self.contentScrollHeight)
        }
    }
}
