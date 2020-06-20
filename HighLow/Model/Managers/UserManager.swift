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
    
    var usersCache: [String: Resource<User>] = [:]
    
    func getUser(uid: String? = nil, onSuccess: @escaping (_ user: Resource<User>) -> Void, onError: @escaping (_ error: String) -> Void) {
        let _uid = uid ?? AuthService.shared.uid
        if _uid == nil {
            AuthService.shared.logOut()
        }
        
        if let user = usersCache[_uid!] {
            onSuccess(user)
        } else {
            
            UserService.shared.getUser(uid: _uid!, onSuccess: { user in
                self.usersCache[_uid!] = Resource<User>(user)
                onSuccess(self.usersCache[_uid!]!)
            }, onError: onError)
            
        }
    }
    
    func saveUser(user: User) -> Resource<User> {
        usersCache[user.uid!] = Resource<User>(user)
        return usersCache[user.uid!]!
    }
}
