//
//  User.swift
//  HighLow
//
//  Created by Caleb Hester on 6/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    func getUser(uid: String, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/get?uid=" + uid, method: .post, params: nil, onSuccess: { json in
            let user = User(data: json)
            onSuccess(user)
        }, onError: onError)
    }
    
    func getUser(onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/get", method: .post, params: nil, onSuccess: { json in
            let user = User(data: json)
            onSuccess(user)
        }, onError: onError)
    }
    
    func setProfile(firstname: String, lastname: String, email: String, bio: String, profileimage: UIImage, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void, onProgressUpdate: @escaping Request.ProgressHandler) {
        let params = [
            "firstname": firstname,
            "lastname": lastname,
            "email": email,
            "bio": bio
        ]
        
        APIService.shared.authenticatedRequest("/user/set_profile", method: .post, params: params, file: profileimage, onSuccess: { json in
            onSuccess(json)
        }, onError: onError, onProgressUpdate: onProgressUpdate)
    }
    
    func getFeed(page: Int, onSuccess: @escaping (_ json: [NSDictionary]) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/newFeed/page/" + String(page), method: .get, params: nil, onSuccess: { json in
            let feedArr = json["feed"] as! [NSDictionary]
            var feed: [NSDictionary] = []
            for item in feedArr {
                var newItem: [String: Any] = [
                    "type": item["type"] as Any
                ]
                if item["type"] as! String == "activity" {
                    newItem["activity"] = ActivityManager.shared.saveActivity(Activity(data: item["activity"] as! NSDictionary))
                    newItem["user"] = UserManager.shared.saveUser(user: User(data: item["user"] as! NSDictionary))
                }
                
                newItem.merge(item as! [String : Any]) { a, b in
                    return a
                }
                
                feed.append(newItem as NSDictionary)
            }
            onSuccess(feed)
        }, onError: onError)
    }
    
    func getFriendsForUser(uid: String?, onSuccess: @escaping (_ friends: [User]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params: [String: Any] = [
            "uid": uid as Any
        ]
        
        APIService.shared.authenticatedRequest("/user/friends", method: .get, params: params, onSuccess: { json in
            
            let friendsJson = json.value(forKey: "friends") as! [NSDictionary]
            let friends = friendsJson.map { item in
                return User(data: item)
            }
            onSuccess(friends)
            
        }, onError: onError)
    }
    
    func unFriend(uid: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/" + uid + "/unfriend", method: .post, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func requestFriend(uid: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/" + uid + "/request_friend", method: .post, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func acceptFriend(uid: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/" + uid + "/accept_friend", method: .post, params: nil, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func searchUsers(search: String, onSuccess: @escaping (_ users: [User]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "search": search
        ]
        APIService.shared.authenticatedRequest("/user/search", method: .post, params: params, onSuccess: { json in
            let results = json.value(forKey: "users") as! [NSDictionary]
            let users = results.map { item in
                return User(data: item["user"] as! NSDictionary)
            }
            onSuccess(users)
        }, onError: onError)
    }
    
    func getPendingFriendships(onSuccess: @escaping (_ requests: [User]) -> Void, onError: @escaping (_ error: String) -> Void) {
        APIService.shared.authenticatedRequest("/user/get_pending_friendships", method: .get, params: nil, onSuccess: { json in
            let results = json.value(forKey: "requests") as! [NSDictionary]
            let users = results.map { item in
                return User(data: item)
            }
            onSuccess(users)
        }, onError: onError)
    }
}
