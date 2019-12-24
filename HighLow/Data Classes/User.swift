//
//  User.swift
//  HighLow
//
//  Created by Caleb Hester on 8/24/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation

class User {
    
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
        profileimage = (data["profileimage"] as! String)
        streak = data["streak"] as? Int
        bio = data["bio"] as? String
        
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
