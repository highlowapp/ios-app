//
//  Activity.swift
//  HighLow
//
//  Created by Caleb Hester on 7/13/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

class Activity: DataObject {
    var activityId: String?
    var uid: String?
    var type: String?
    var title: String?
    var timestamp: String?
    var data: NSDictionary?
    var date: String?
    var flagged: Bool? = false
    var comments: [ActivityComment]?
        
    init(data: NSDictionary) {
        activityId = data["activity_id"] as? String
        uid = data["uid"] as? String
        title = data["title"] as? String
        type = data["type"] as? String
        timestamp = data["timestamp"] as? String
        self.data = data["data"] as? NSDictionary
        date = data["date"] as? String
        flagged = data["flagged"] as? Bool
        comments = (data["comments"] as! [NSDictionary]).map { item in
            return ActivityComment(item)
        }
    }
    
    func updateData(with data: Activity) {
        activityId = data.activityId ?? activityId
        uid = data.uid ?? uid
        type = data.type ?? type
        timestamp = data.timestamp ?? timestamp
        self.data = data.data ?? self.data
        self.date = data.date ?? date
        flagged = data.flagged ?? flagged
        comments = data.comments ?? comments
        title = data.title ?? title
    }
    
    func updateTitle() {
        self.title = Activity.getTitle(forActivity: self)
        if self.data != nil {
            var data = self.data as! [String: Any]
            data["title"] = self.title
            self.data = data as NSDictionary
        }
    }
    
    static func getTitle(forActivity activity: Activity) -> String {
        let data = activity.data
        
        if activity.type == "diary" {
            if let blocks = data!["blocks"] as? [NSDictionary] {
                for block in blocks {
                    if let type = block["type"] as? String {
                        if type == "img" {
                            continue
                        } else {
                            if block["editable"] as? Bool ?? false {
                                if let content = block["content"] as? String {
                                    let htmlStringData = content.data(using: .utf8)!
                                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
                                    let attributedHTMLString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
                                    let string = attributedHTMLString.string
                                    return string
                                }
                            }
                        }
                    }
                }
            }
        }
    
        return "Untitled Entry"
    }
}


