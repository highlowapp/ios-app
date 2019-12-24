//
//  HighLow.swift
//  HighLow
//
//  Created by Caleb Hester on 7/13/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation


class HighLow {
    var highlowid: String?
    var high: String?
    var low: String?
    var highImage: String?
    var lowImage: String?
    var timestamp: String?
    var total_likes: Int?
    var comments: [Comment] = []
    var date: String?
    var uid: String?
    var liked: Int?
    var flagged: Int?
    
    weak var delegate: HighLowDelegate?
    
    static var empty: HighLow {
        get {
            return HighLow(data: [
                "highlowid": "",
                "uid": "",
                "high": "",
                "low": "",
                "high_image": "",
                "low_image": "",
                "_timestamp": "",
                "total_likes": 0,
                "_date": "",
                "comments": [],
                "liked": 0,
                "flagged": 0
            ])
        }
    }
    
    init(highlowid: String) {
        self.highlowid = highlowid
    }
    
    init(data: NSDictionary) {
        
        self.highlowid = data["highlowid"] as? String
        self.uid = data["uid"] as? String
        self.high = data["high"] as? String ?? ""
        self.low = data["low"] as? String ?? ""
        self.highImage = data["high_image"] as? String ?? ""
        self.lowImage = data["low_image"] as?  String ?? ""
        self.timestamp = data["_timestamp"] as? String
        self.total_likes = data["total_likes"] as? Int
        self.date = data["_date"] as? String
        
        if let liked = data["liked"] as? Int {
            self.liked = liked
        }
        
        if let flagged = data["flagged"] as? Int {
            self.flagged = flagged
        }
        
        let comments = data["comments"] as! [NSDictionary]
        
        for i in comments {
            self.comments.append( Comment(i) )
        }
        
        self.delegate?.didFinishLoadingComments(sender: self)
        /*
        self.getComments(callback: { (comments) in
            self.delegate?.didFinishLoadingComments(sender: self)
        })*/
        
    }
    
    func update(with: [String: Any]) {
        
        for i in with {
            switch (i.key) {
            case "high":
                self.high = i.value as? String
                break;
            case "low":
                self.low = i.value as? String
                break;
            case "high_image":
                self.highImage = i.value as? String
                break;
            case "low_image":
                self.lowImage = i.value as? String
                break;
            case "timestamp":
                self.timestamp = i.value as? String
                break;
            case "total_likes":
                self.total_likes = i.value as? Int
                break;
            case "_date":
                self.date = i.value as? String
                break;
            case "uid":
                self.uid = i.value as? String
                break;
            case "flagged":
                self.flagged = i.value as? Int
                break;
            case "liked":
                self.liked = i.value as? Int
                break;
            default:
                break;
            }
        }
        
    }
    
    func loadData(callback: @escaping (NSDictionary) -> Void) {
        
        if let hli = highlowid {
        
            authenticatedRequest(url: "https://api.gethighlow.com/highlow/" + hli , method: .get, parameters: [:], onFinish: { json in
                
                if (json["error"] as? String) != nil {
                    
                } else {
                    self.high = json["high"] as? String ?? ""
                    self.low = json["low"] as? String ?? ""
                    self.highImage = json["high_image"] as? String ?? ""
                    self.lowImage = json["low_image"] as? String ?? ""
                    self.timestamp = json["timestamp"] as? String
                    self.total_likes = json["total_likes"] as? Int
                    self.date = json["_date"] as? String
                    self.uid = json["uid"] as? String
                    
                    if json["liked"] != nil {
                        self.liked = json["liked"] as? Int
                    }
                    
                    if json["flagged"] != nil {
                        self.flagged = json["flagged"] as? Int
                    }
                    
                    
                    let comments = json["comments"] as! [NSDictionary]
                    
                    for i in comments {
                        self.comments.append( Comment(i) )
                    }
                    
                    self.delegate?.didFinishLoadingComments(sender: self)

                    /*self.getComments(callback: { (comments) in
                        self.delegate?.didFinishLoadingComments(sender: self)
                    })*/
                }
                
                callback(json)
                
            }) { error in
                
                let json: [String: String] = [
                    "error": error
                ]
                
                callback(json as NSDictionary)
                
            }
            
        }
        
    }
    
    func getComments(callback: @escaping([Comment]) -> Void) {
        if let hli = self.highlowid {
            authenticatedRequest(url: "https://api.gethighlow.com/highlow/get_comments/" + hli, method: .get, parameters: [:], onFinish: { json in
                
                if json["error"] != nil {
                    //There was an error
                }
                else if let _comments = json["comments"] as? [[String: Any]] {
                    
                    for i in _comments {
                        
                        let comment = Comment(i as NSDictionary)
                        
                        self.comments.append(comment)
                        
                    }
                    
                    callback(self.comments)
                    
                }
                
            }, onError: { error in
                
               
                
            });
        }
        
        else {
            //An error occurred
        }
    }
    
    
    func asJson() -> NSDictionary {
        
        var dict: [String: Any] = [
            "highlowid": self.highlowid ?? "",
            "high": self.high ?? "",
            "low": self.low ?? "",
            "high_image": self.highImage ?? "",
            "low_image": self.lowImage ?? "",
            "_timestamp": self.timestamp ?? "",
            "total_likes": self.total_likes ?? 0,
            "_date": self.date ?? "",
            "uid": self.uid ?? "",
            "liked": self.liked ?? 0,
            "flagged": self.flagged ?? 0
        ]
        
        var commentsArr: [NSDictionary] = []
        
        for i in comments {
            commentsArr.append(i.asJson())
        }
        
        dict["comments"] = commentsArr
        
        return dict as NSDictionary
    }
    
    func loadJson(_ data: NSDictionary) {
        self.highlowid = data["highlowid"] as? String
        self.high = data["high"] as? String ?? ""
        self.low = data["low"] as? String ?? ""
        self.highImage = data["high_image"] as? String ?? ""
        self.lowImage = data["low_image"] as? String ?? ""
        self.timestamp = data["_timestamp"] as? String
        self.total_likes = data["total_likes"] as? Int
        self.date = data["_date"] as? String
        self.uid = data["uid"] as? String
        
        if data["liked"] != nil {
            self.liked = data["liked"] as? Int
        }
        
        if data["flagged"] != nil {
            self.flagged = data["flagged"] as? Int
        }
        
        let comments = data["comments"] as! [NSDictionary]
        
        for i in comments {
            self.comments.append( Comment(i) )
        }
        
        self.delegate?.didFinishLoadingComments(sender: self)

        /*
        self.getComments(callback: { (comments) in
            self.delegate?.didFinishLoadingComments(sender: self)
        })*/
    }
}


protocol HighLowDelegate: AnyObject {
    
    func didFinishLoadingComments(sender: HighLow)
    
}
