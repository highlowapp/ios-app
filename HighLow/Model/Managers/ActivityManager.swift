//
//  ActivityManager.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class ActivityManager {
    static let shared = ActivityManager()
    
    private init() {}
    
    var activityCache: [String: ActivityResource] = [:]
    
    func getActivity(activityId: String, onSuccess: @escaping (_ activity: ActivityResource) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let activity = activityCache[activityId] {
            onSuccess(activity)
        } else {
            ActivityService.shared.getActivity(activity_id: activityId, onSuccess: { activity in
                self.activityCache[activityId] = ActivityResource(activity)
                onSuccess(self.activityCache[activityId]!)
            }, onError: onError)
        }
    }
    
    @discardableResult func saveActivity(_ activity: Activity) -> ActivityResource {
        activityCache[activity.activityId!] = ActivityResource(activity)
        return activityCache[activity.activityId!]!
    }
}
