//
//  Activity.swift
//  HighLow
//
//  Created by Caleb Hester on 7/13/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation


class Activity: DataObject {
    var activityId: String?
    var uid: String?
    var type: Int?
    var timestamp: String?
    var data: NSDictionary?
    var date: String?
    var flagged: Bool? = false
    var comments: [ActivityComment]?
        
    init(data: NSDictionary) {
        activityId = data["activity_id"] as? String
        uid = data["uid"] as? String
        type = data["type"] as? Int
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
    }
}


