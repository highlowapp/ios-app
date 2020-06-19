//
//  LikeView.swift
//  HighLow
//
//  Created by Caleb Hester on 7/8/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class LikeView: UIView {
    
    var hasBeenTapped: Bool = false
    
    weak var delegate: LikeViewDelegate?
    
    var numLikesView: UILabel = UILabel()
    let likeIconView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    static func like(highlowid: String, callback: @escaping (_ error: String?) -> Void ) {

        authenticatedRequest(url: "/highlow/like/" + highlowid, method: .post, parameters: [:], onFinish: { json in
            if let error = json["error"] as? String {
                callback(error)
            }
            else {
                
                var userInfo: [String: Any] = [
                    "highlowid": highlowid,
                    "liked": 1
                ]
                
                if let total_likes = json["total_likes"] as? Int {
                    userInfo["total_likes"] = total_likes
                }
                
                NotificationCenter.default.post(name: Notification.Name("highLowUpdate"), object: nil, userInfo: [
                    "highlowid": highlowid,
                    "liked": 1
                ])
                
                
                callback(nil)
            }
        }, onError: { error in
            callback(error)
        })
        
    }
    
    static func unlike(highlowid: String, callback: @escaping (_ error: String?) -> Void ) {
        
        authenticatedRequest(url: "/highlow/unlike/" + highlowid, method: .post, parameters: [:], onFinish: { json in
            
            if let error = json["error"] as? String {
                callback(error)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name("highLowUpdate"), object: nil, userInfo: [
                    "highlowid": highlowid,
                    "liked": 0
                ])
                
                callback(nil)
            }
            
        }, onError: { error in
            callback(error)
        })
        
    }
    
    
    
    private func setup() {
        
        //Set image for likeIconView
        likeIconView.image = UIImage(named: "like-outline")
        if hasBeenTapped {
            likeIconView.image = UIImage(named: "like-filled")
        }
        
        //Typography
        numLikesView.text = "0"
        numLikesView.textColor = AppColors.primary
        numLikesView.font = UIFont.systemFont(ofSize: 20)
        
        //Add the subviews
        self.addSubview(numLikesView)
        self.addSubview(likeIconView)
        
        //Constraints
        likeIconView.eqTrailing(self).width(30).height(30).eqTop(self)
        numLikesView.trailingToLeading(likeIconView, -5).centerY(likeIconView)
        self.eqLeading(numLikesView).eqBottom(likeIconView)
        
        
        
        //Gesture recognizer
        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapper)
        
    }
    
    func updateImage() {
        likeIconView.image = UIImage(named: "like-outline")
        if hasBeenTapped {
            likeIconView.image = UIImage(named: "like-filled")
        }
    }
    
    func reverse() {
        hasBeenTapped = !hasBeenTapped
        updateImage()
    }
    
    func isLiked() {
        hasBeenTapped = true
        updateImage()
    }
    
    func isNotLiked() {
        hasBeenTapped = false
        updateImage()
    }
    
    @objc func handleTap() {        
        hasBeenTapped = !hasBeenTapped
        updateImage()
        
        if hasBeenTapped {
            delegate?.didLike(sender: self)
        }
        
        else {
            delegate?.didUnLike(sender: self)
        }
        
    }
}


protocol LikeViewDelegate: AnyObject {
    func didLike(sender: LikeView)
    func didUnLike(sender: LikeView)
}
