//
//  UserManager.swift
//  HighLow
//
//  Created by Caleb Hester on 6/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var usersCache: [String: UserResource] = [:]
    
    func getUser(uid: String? = nil, onSuccess: @escaping (_ user: UserResource) -> Void, onError: @escaping (_ error: String) -> Void) {
        let _uid = uid ?? AuthService.shared.uid
        if _uid == nil {
            AuthService.shared.logOut()
        }
        
        if let user = usersCache[_uid!] {
            onSuccess(user)
        } else {
            
            UserService.shared.getUser(uid: _uid!, onSuccess: { user in
                self.usersCache[_uid!] = UserResource(user)
                onSuccess(self.usersCache[_uid!]!)
            }, onError: onError)
            
        }
    }
    
    func getCurrentUser(onSuccess: @escaping (_ user: UserResource) -> Void, onError: @escaping (_ error: String) -> Void) {
        let _uid = AuthService.shared.uid
        getUser(onSuccess: onSuccess, onError: onError)
    }
    
    @discardableResult func saveUser(user: User) -> UserResource {
        usersCache[user.uid!] = UserResource(user)
        return usersCache[user.uid!]!
    }
}
