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

class ReflectListView: WKWebView, UITextFieldDelegate {
    
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
            let url = Bundle.main.url(forResource: "webview", withExtension: "html")!
            self.loadFileURL(url, allowingReadAccessTo: url)
            hasLoaded = true
        }
    }
    
    func loadActivities(_ activities: [NSDictionary], _ user: NSDictionary, _ viewer: NSDictionary, completion: @escaping () -> Void = {}) {
        do {
            let activitiesString = try JSONSerialization.data(withJSONObject: activities, options: .prettyPrinted)
            let jsonStr = NSString(data: activitiesString, encoding: String.Encoding.utf8.rawValue)! as String
            let userString = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
            let userJson = NSString(data: userString, encoding: String.Encoding.utf8.rawValue)! as String
            
            let viewerString = try JSONSerialization.data(withJSONObject: viewer, options: .prettyPrinted)
            let viewerJson = NSString(data: viewerString, encoding: String.Encoding.utf8.rawValue)! as String
            
            self.evaluateJavaScript("setViewingUser(\(viewerJson)); setGlobalUser(\(userJson)); setActivities(\(jsonStr), true)", completionHandler: { blah, blah2 in
                print(blah2)
            })
        } catch {
            //self.load()
        }
        
    }
    
    func loadActivities(_ activities: [NSDictionary], _ user: NSDictionary, completion: @escaping () -> Void = {}) {
        do {
            let activitiesString = try JSONSerialization.data(withJSONObject: activities, options: .prettyPrinted)
            let jsonStr = NSString(data: activitiesString, encoding: String.Encoding.utf8.rawValue)! as String
            let userString = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
            let userJson = NSString(data: userString, encoding: String.Encoding.utf8.rawValue)! as String
            
            self.evaluateJavaScript("setGlobalUser(\(userJson)); setActivities(\(jsonStr), true)", completionHandler: { blah, blah2 in
                print(blah2)
            })
        } catch {
            //self.load()
        }
        
    }
    
}
