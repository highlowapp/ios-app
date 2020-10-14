//
//  User.swift
//  HighLow
//
//  Created by Caleb Hester on 8/24/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation

class User: DataObject {
    
    var firstname: String?
    var lastname: String?
    var uid: String?
    var email: String?
    var profileimage: String?
    var streak: Int?
    var bio: String?
    
    init(data: NSDictionary) {
        
        //Load the data
        firstname = data["firstname"] as? String
        lastname = data["lastname"] as? String
        uid = data["uid"] as? String
        profileimage = (data["profileimage"] as? String)
        streak = data["streak"] as? Int
        bio = data["bio"] as? String
        
    }
    
    func fullName() -> String? {
        guard let first = firstname, let last = lastname else {
            return nil
        }
        return first + " " + last
    }
    
    func updateData(with data: User) {
        firstname = data.firstname ?? firstname
        lastname = data.lastname ?? lastname
        uid = data.uid ?? uid
        email = data.email ?? email
        profileimage = data.profileimage ?? profileimage
        streak = data.streak ?? streak
        bio = data.bio ?? bio
    }
    
    func asJson() -> NSDictionary {
        
        let json: NSDictionary = [
            "firstname": firstname ?? "",
            "lastname": lastname ?? "",
            "uid": uid ?? "",
            "profileimage": profileimage ?? "",
            "streak": streak ?? 0,
            "bio": bio ?? ""
        ]
        
        return json
        
    }
        
}
