//
//  Responses.swift
//  HighLow
//
//  Created by Caleb Hester on 12/5/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

struct FriendsResponse {
    var friends: [UserResource]
    var pendingRequests: [UserResource]
    var isCurrentUser: Bool
}
