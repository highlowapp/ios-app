//
//  ActivityResource.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class ActivityResource: Resource<Activity> {
    var activityId: String? {
        get {
            return getItem().activityId
        }
    }
    
    var uid: String? {
        get {
            return getItem().uid
        }
    }
    
    var type: String? {
        get {
            return getItem().type
        }
    }
    
    var title: String? {
        get {
            return getItem().title
        }
    }
    
    var timestamp: String? {
        get {
            return getItem().timestamp
        }
    }
    
    var data: NSDictionary? {
        get {
            return getItem().data
        }
    }
    
    var date: String? {
        get {
            return getItem().date
        }
    }
    
    var flagged: Bool? {
        get {
            return getItem().flagged
        }
    }
    
    var comments: [ActivityComment]? {
        get {
            return getItem().comments
        }
    }
    
    func asDict() -> NSDictionary {
        return getItem().asDict()
    }
    
    func update(data: NSDictionary, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        activity.data = data
        activity.updateTitle()
        
        ActivityService.shared.updateActivity(activity_id: activity.activityId!, data: activity.data!, onSuccess: { newActivity in
            self.set(item: newActivity)
            onSuccess()
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
    
    func setSharingPolicy(category: String, uids: [String]? = nil, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String) -> Void) {
        let activity = getItem()
        ActivityService.shared.setSharingPolicy(activity_id: activity.activityId!, category: category, uids: uids, onSuccess: { otherActivity in
            ActivityManager.shared.saveActivity(otherActivity)
            onSuccess()
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
