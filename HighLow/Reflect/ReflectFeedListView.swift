//
//  ReflectFeedListView.swift
//  HighLow
//
//  Created by Caleb Hester on 6/27/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit
import Gridicons

class ReflectFeedListView: WKWebView, UITextFieldDelegate {
    
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
            let url = Bundle.main.url(forResource: "feedview", withExtension: "html")!
            self.loadFileURL(url, allowingReadAccessTo: url)
            hasLoaded = true
        }
    }
    
    func loadFeed(_ feedData: [NSDictionary], _ viewer: NSDictionary, completion: @escaping () -> Void = {}) {
        do {
            let feedJson = jsonFromFeedData(feedData)
            
            let feedString = try JSONSerialization.data(withJSONObject: feedJson, options: .prettyPrinted)
            let jsonStr = NSString(data: feedString, encoding: String.Encoding.utf8.rawValue)! as String
            
            let viewerString = try JSONSerialization.data(withJSONObject: viewer, options: .prettyPrinted)
            let viewerJson = NSString(data: viewerString, encoding: String.Encoding.utf8.rawValue)! as String
            
            self.evaluateJavaScript("setViewingUser(\(viewerJson)); setFeedData(\(jsonStr), true)", completionHandler: { blah, blah2 in
                completion()
            })
        } catch {
            alert()
            completion()
        }
        
    }
    
    func loadFeed(_ feedData: [NSDictionary], completion: @escaping () -> Void = {}) {
        do {
            let feedJson = jsonFromFeedData(feedData)
            
            let feedString = try JSONSerialization.data(withJSONObject: feedJson, options: .prettyPrinted)
            let jsonStr = NSString(data: feedString, encoding: String.Encoding.utf8.rawValue)! as String
            
            self.evaluateJavaScript("setFeedData(\(jsonStr), true)", completionHandler: { blah, blah2 in
                completion()
            })
        } catch {
            alert()
            completion()
        }
        
    }
    
    func darkMode() {
        self.evaluateJavaScript("darkMode()")
    }
    
    func lightMode() {
        self.evaluateJavaScript("lightMode()")
    }
    
    func jsonFromFeedData(_ feedData: [NSDictionary]) -> [NSDictionary] {
        var feedJson: [NSDictionary] = []
        
        for item in feedData {
            if let type = item.value(forKey: "type") as? String {
                if type == "activity" {
                    var feedItem: [String: Any] = [:]
                    for key in item.allKeys {
                        if let keyString = key as? String {
                            if keyString == "activity", let activity = item.value(forKey: keyString) as? ActivityResource {
                                feedItem["activity"] = activity.asDict()
                            } else
                            if keyString == "user", let user = item.value(forKey: keyString) as? UserResource {
                                feedItem["user"] = user.asJson()
                            } else {
                                feedItem[keyString] = item.value(forKey: keyString)
                            }
                        }
                    }
                    
                    feedJson.append(feedItem as NSDictionary)
                } else {
                    feedJson.append(item)
                }
            }
        
        }
        
        return feedJson
    }
    
    
}
