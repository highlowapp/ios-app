//
//  ActivityComment.swift
//  HighLow
//
//  Created by Caleb Hester on 8/14/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation

class ActivityComment {
    
    var _timestamp: String?
    var commentid: String?
    var uid: String?
    var message: String?
    var firstname: String?
    var lastname: String?
    var profileimage: String?
    
    init(_ data: NSDictionary) {
        _timestamp = data["timestamp"] as? String
        commentid = data["commentid"] as? String
        uid = data["uid"] as? String
        message = data["message"] as? String
        firstname = data["firstname"] as? String
        lastname = data["lastname"] as? String
        profileimage = data["profileimage"] as? String
    }
    
    func asJson() -> NSDictionary {
        let json: NSDictionary = [
            "_timestamp": _timestamp ?? "0",
            "commentid": commentid ?? "",
            "uid": uid ?? "",
            "message": message ?? "",
            "firstname": firstname ?? "",
            "lastname": lastname ?? "",
            "profileimage": profileimage ?? ""
        ]
        return json
    }
}
