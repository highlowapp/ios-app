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
    
    var activityCache: [String: Resource<Activity>] = [:]
    
    func getActivity(activityId: String, onSuccess: @escaping (_ activity: Resource<Activity>) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let activity = activityCache[activityId] {
            onSuccess(activity)
        } else {
            ActivityService.shared.getActivity(activity_id: activityId, onSuccess: { activity in
                self.activityCache[activityId] = Resource<Activity>(activity)
                onSuccess(self.activityCache[activityId]!)
            }, onError: onError)
        }
    }
    
    func saveActivity(_ activity: Activity) -> Resource<Activity> {
        activityCache[activity.activityId!] = Resource<Activity>(activity)
        return activityCache[activity.activityId!]!
    }
}
