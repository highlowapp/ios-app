//
//  ActivityResource.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class ActivityResource: Resource<Activity> {
    func update(data: NSDictionary, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.updateActivity(activity_id: activity.activityId!, data: data, onSuccess: { newActivity in
            activity.data = data
            self.set(item: activity)
        }, onError: onError)
    }
    
    func delete(onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.deleteActivity(activity_id: activity.activityId!, onSuccess: { activity in
            onSuccess(activity)
        }, onError: onError)
    }
    
    func getSharingPolicy(onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.getSharingPolicy(activity_id: activity.activityId!, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func setSharingPolicy(category: String, uids: [String]? = nil, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.setSharingPolicy(activity_id: activity.activityId!, category: category, uids: uids, onSuccess: { otherActivity in
            
        }, onError: onError)
    }
    
    func flag(onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.flagActivity(activity_id: activity.activityId!, onSuccess: { newActivity in
            activity.flagged = true
            self.set(item: activity)
        }, onError: onError)
    }
    
    func unFlag(onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.unFlagActivity(activity_id: activity.activityId!, onSuccess: { newActivity in
            activity.flagged = false
            self.set(item: activity)
        }, onError: onError)
    }
    
    func comment(message: String, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.comment(activity_id: activity.activityId!, message: message, onSuccess: { newActivity in
            activity.comments = newActivity.comments
            self.set(item: activity)
        }, onError: onError)
    }
}
