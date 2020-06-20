//
//  UserResource.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class UserResource: Resource<User> {
    
    func setProfile(firstname: String, lastname: String, email: String, bio: String, profileimage: UIImage, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void, onProgressUpdate: @escaping Request.ProgressHandler) {
        let user = getItem()
        
        UserService.shared.setProfile(firstname: firstname, lastname: lastname, email: email, bio: bio, profileimage: profileimage, onSuccess: { json in
            user.firstname = firstname
            user.lastname = lastname
            user.email = email
            user.bio = bio
            
            self.set(item: user)
            
            onSuccess(json)
        }, onError: onError, onProgressUpdate: onProgressUpdate)
    }
    
    func getFriends(onSuccess: @escaping (_ friends: [UserResource]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        UserService.shared.getFriendsForUser(uid: user.uid, onSuccess: { users in
            let userResources = users.map { user in
                return UserManager.shared.saveUser(user: user) as! UserResource
            }
            onSuccess(userResources)
        }, onError: onError)
    }
    
    func requestFriendship(onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        UserService.shared.requestFriend(uid: user.uid!, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func acceptFriendship(onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        UserService.shared.acceptFriend(uid: user.uid!, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func unFriend(onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        UserService.shared.unFriend(uid: user.uid!, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func getPendingFriendships(onSuccess: @escaping (_ pendingFriendships: [UserResource]) -> Void, onError: @escaping (_ error: String) -> Void) {
        UserService.shared.getPendingFriendships(onSuccess: { pendingFriendships in
            let userResources = pendingFriendships.map { user in
                return UserManager.shared.saveUser(user: user) as! UserResource
            }
            onSuccess(userResources)
        }, onError: onError)
    }
    
    func getActivities(page: Int, onSuccess: @escaping (_ activities: [ActivityResource]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        ActivityService.shared.getForUser(uid: user.uid!, page: page, onSuccess: { activities in
            let activityResources = activities.map { activity in
                return ActivityManager.shared.saveActivity(activity) as! ActivityResource
            }
            onSuccess(activityResources)
        }, onError: onError)
    }
    
    func searchUsers(search: String, onSuccess: @escaping (_ users: [UserResource]) -> Void, onError: @escaping (_ error: String) -> Void) {
        UserService.shared.searchUsers(search: search, onSuccess: { users in
            let userResources = users.map { user in
                return UserManager.shared.saveUser(user: user) as! UserResource
            }
            onSuccess(userResources)
        }, onError: onError)
    }
    
    func getActivityChart(onSuccess: @escaping (_ chart: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let user = getItem()
        ActivityService.shared.getActivityChart(uid: user.uid!, onSuccess: onSuccess, onError: onError)
    }
    
    //  FEED  //
}
