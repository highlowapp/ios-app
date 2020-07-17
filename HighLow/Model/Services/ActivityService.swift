//
//  ActivityService.swift
//  HighLow
//
//  Created by Caleb Hester on 6/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ActivityService {
    static let shared = ActivityService()
    
    private init() {}
    
    func getActivity(activity_id: String, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id, method: .get, params: nil, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }
    
    func updateActivity(activity_id: String, data: NSDictionary, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        do {
        let serializedData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonStr = NSString(data: serializedData, encoding: String.Encoding.utf8.rawValue)! as String
        let params = [
            "data": jsonStr
        ]
            APIService.shared.authenticatedRequest("/user/activities/" + activity_id, method: .post, params: params, onSuccess: { json in
                onSuccess(Activity(data: json))
            }, onError: onError)
        } catch {
            onError(error.localizedDescription)
        }
    }
    
    func deleteActivity(activity_id: String, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id, method: .delete, params: nil, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }
    
    func getForUser(uid: String, page: Int, onSuccess: @escaping (_ activities: [Activity]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "page": page
        ]
        APIService.shared.authenticatedRequest("/user/" + uid + "/activities", method: .get, params: params, onSuccess: { json in
            let activitiesJson = json.value(forKey: "activities") as! [NSDictionary]
            let activities = activitiesJson.map { item in
                return Activity(data: item)
            }
            onSuccess(activities)
        }, onError: onError)
    }
    
    func createActivity(type: String, data: NSDictionary, onSuccess: @escaping (_ activity: ActivityResource) -> Void, onError: @escaping (_ error: String) -> Void) {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let today = Date()
            
            let dateStr = dateFormatter.string(from: today)
            
            let serializedData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let jsonStr = NSString(data: serializedData, encoding: String.Encoding.utf8.rawValue)! as String
            
            let params: [String: Any] = [
                "type": type,
                "data": jsonStr,
                "date": dateStr
            ]
            
            APIService.shared.authenticatedRequest("/user/activities", method: .post, params: params, onSuccess: { json in
                let activity = ActivityManager.shared.saveActivity(Activity(data: json))
                onSuccess(activity)
            }, onError: onError)
        } catch {
            onError(error.localizedDescription)
        }
    }
    
    func getSharingPolicy(activity_id: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id + "/sharing", method: .get, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func setSharingPolicy(activity_id: String, category: String, uids: [String]? = nil, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        var params: [String: Any] = [
            "category": category
        ]
        if uids != nil {
            params["uids"] = uids!
        }
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id + "/sharing", method: .post, params: params, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }
    
    func comment(activity_id: String, message: String, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "message": message
        ]
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id + "/comment", method: .post, params: params, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }
    
    func editComment(commentid: String, message: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "message": message
        ]
        APIService.shared.authenticatedRequest("/comments/" + commentid, method: .post, params: params, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func deleteComment(commentid: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/comments/" + commentid, method: .delete, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func getActivityChart(uid: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/" + uid + "/activities/chart", method: .get, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func flagActivity(activity_id: String, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id + "/flag", method: .post, params: nil, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }
    
    func unFlagActivity(activity_id: String, onSuccess: @escaping (_ activity: Activity) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/activities/" + activity_id + "/flag", method: .delete, params: nil, onSuccess: { json in
            onSuccess(Activity(data: json))
        }, onError: onError)
    }

    func addImage(img: UIImage, onSuccess: @escaping (_ url: String) -> Void, onError: @escaping (_ error: String) -> Void, onProgressUpdate: @escaping Request.ProgressHandler) {
        APIService.shared.authenticatedRequest("/user/activities/addImage", method: .post, params: [:], file: img, onSuccess: { json in
            let url = json["url"] as! String
            onSuccess(url)
        }, onError: onError, onProgressUpdate: onProgressUpdate)
    }
    
    func getDiaryEntries(page: Int, onSuccess: @escaping (_ activities: [Activity]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "page": page
        ]
        APIService.shared.authenticatedRequest("/user/diaryEntries", method: .get, params: params, onSuccess: { json in
            let activitiesJson = json.value(forKey: "activities") as! [NSDictionary]
            print(activitiesJson)
            let activities = activitiesJson.map { item in
                return Activity(data: item)
            }
            onSuccess(activities)
        }, onError: onError)
    }
}
