//
//  LikeFlagTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/31/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class LikeFlagTableViewCell: UITableViewCell, LikeViewDelegate, FlagViewDelegate {

    var highlowid: String?
    var likeView: LikeView = LikeView()
    var flagView: FlagView = FlagView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        awakeFromNib()
    }
    
    func loadFromHighLow(highlow: HighLow) {
        likeView.numLikesView.text = String(highlow.total_likes!)
        if let liked = highlow.liked {
            if liked == 1 {
                likeView.isLiked()
            } else {
                likeView.isNotLiked()
            }
        }
        if let flagged = highlow.flagged {
            if flagged == 1 {
                flagView.isFlagged()
            } else {
                flagView.isNotFlagged()
            }
        }
    }
    
    func updateState(_ likeNum: Int?, _ liked: Int?, _ flagged: Int? ) {
    }
    
    func getTotalLikes() {
        if highlowid != nil {
            authenticatedRequest(url: "https://api.gethighlow.com/highlow/" + highlowid!, method: .get, parameters: [:], onFinish: { json in
                
                if let total_likes = json["total_likes"] as? Int {
                    self.likeView.numLikesView.text = String(total_likes)
                }
                
                if let liked = json["liked"] as? Int {
                    if liked == 1 {
                        self.likeView.isLiked()
                    } else {
                        self.likeView.isNotLiked()
                    }
                }
                
            }, onError: { error in
                
            })
        }
    }
    
    func loadFromHighLowUpdateNotification(notification: Notification) {
        let userInfoDict = notification.userInfo as! [String: Any]
        
        if let liked = userInfoDict["liked"] as? Int {
            if liked == 1 {
                likeView.isLiked()
            } else if liked == 0 {
                likeView.isNotLiked()
            }
        }
        
        if let flagged = userInfoDict["flagged"] as? Int {
            if flagged == 1 {
                flagView.isFlagged()
            } else if flagged == 0 {
                flagView.isNotFlagged()
            }
        }
        
        if let total_likes = userInfoDict["total_likes"] as? Int {
            likeView.numLikesView.text = String(total_likes)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .white
        
        NotificationCenter.default.addObserver(forName: Notification.Name("highLowUpdate"), object: nil, queue: nil, using: loadFromHighLowUpdateNotification)
        
        self.addSubview(likeView)
        self.addSubview(flagView)
        
        likeView.eqTrailing(self, -20).eqTop(self, 20)
        flagView.eqTop(likeView).eqLeading(self, 20)
        
        likeView.delegate = self
        flagView.delegate = self
        
        self.bottomAnchor.constraint(equalTo: likeView.bottomAnchor, constant: 20).isActive = true
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func didLike(sender: LikeView) {
        if let hli = highlowid {
            LikeView.like(highlowid: hli, callback: { error in
                if error != nil {
                    
                    switch(error) {
                    case "already-liked":
                        alert("Whoops!", "It looks like you've already liked this High/Low!")
                        break
                    case "not-allowed":
                        alert("Whoops!", "You can't like your own High/Lows!")
                        break
                    default:
                        alert("An error occurred", "Please try again")
                        break
                    }
                    sender.reverse()
                    
                }
                else {
                    //Update the number of likes
                    let prevLikes = Int(sender.numLikesView.text ?? "0")
                    sender.numLikesView.text = String((prevLikes ?? 0) + 1)
                    
                }
            })
        }
        else {
            alert("An error occurred", "Please try again")
            sender.reverse()
        }
    }
    
    func didUnLike(sender: LikeView) {
        if let hli = highlowid {
            LikeView.unlike(highlowid: hli, callback: { error in
                
                if error != nil {
                    alert("An error occurred", "Please try again")
                    sender.reverse()
                }
                else {
                    
                    //Update the number of likes
                    let prevLikes = Int(sender.numLikesView.text ?? "0")
                    sender.numLikesView.text = String((prevLikes ?? 1) - 1)
                    
                }
                
            })
        } else {
            alert("An error occurred", "Please try again")
            sender.reverse()
        }
    }
    
    func didFlag(sender: FlagView) {
        //Confirm they want to flag the High/Low
        let alertViewController = UIAlertController(title: "Confirm flag?", message: "Are you sure you want to flag this High/Low?", preferredStyle: .actionSheet)
        
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            sender.reverse()
        }))
        alertViewController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            
            if let hli = self.highlowid {
                
                FlagView.flag(highlowid: hli, callback: { error in
                    
                    if error != nil {
                        alert("An error occurred", "Please try again")
                        sender.reverse()
                    }
                    
                })
                
            } else {
                alert("An error occurred", "Please try again")
                sender.reverse()
            }
            
        }))
        
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            alertViewController.popoverPresentationController?.sourceView = sender
            alertViewController.popoverPresentationController?.sourceRect = sender.frame
            topController.present(alertViewController, animated: true)
        }
        
    }
    
    func didUnflag(sender: FlagView) {
        
        //Confirm they want to flag the High/Low
        let alertViewController = UIAlertController(title: "Confirm unflag?", message: "Are you sure you want to unflag this High/Low?", preferredStyle: .actionSheet)
        
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            sender.reverse()
        }))
        alertViewController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            
            if let hli = self.highlowid {
                
                FlagView.unflag(highlowid: hli, callback: { error in
                    
                    if error != nil {
                        alert("An error occurred", "Please try again")
                        sender.reverse()
                    }
                    
                })
                
            } else {
                alert("An error occurred", "Please try again")
                sender.reverse()
            }
            
        }))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            alertViewController.popoverPresentationController?.sourceView = sender
            alertViewController.popoverPresentationController?.sourceRect = sender.frame
            topController.present(alertViewController, animated: true)
        }
        
    }
    

}
