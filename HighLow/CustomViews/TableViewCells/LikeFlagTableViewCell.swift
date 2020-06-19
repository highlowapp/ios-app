//
//  LikeFlagTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/31/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import PopupDialog

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
            authenticatedRequest(url: "/highlow/" + highlowid!, method: .get, parameters: [:], onFinish: { json in
                
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
    
    override func updateColors() {
        self.backgroundColor = getColor("White2Black")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
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
                    sender.reverse()
                    switch(error) {
                    case "already-liked":
                        sender.isUserInteractionEnabled = false
                        alert("Whoops!", "It looks like you've already liked this High/Low!", handler: {
                            sender.isUserInteractionEnabled = true
                        })
                        break
                    case "not-allowed":
                        sender.isUserInteractionEnabled = false
                        alert("Whoops!", "You can't like your own High/Lows!", handler: {
                            sender.isUserInteractionEnabled = true
                        })
                        break
                    default:
                        sender.isUserInteractionEnabled = false
                        alert("An error occurred", "Please try again", handler: {
                            sender.isUserInteractionEnabled = true
                        })
                        break
                    }
                    
                }
                else {
                    //Update the number of likes
                    var prevLikes = Int(sender.numLikesView.text ?? "0")
                    if prevLikes ?? 0 < 0 {
                        prevLikes = 0
                    }
                    sender.numLikesView.text = String((prevLikes ?? 0) + 1)
                    
                }
            })
        }
        else {
            sender.reverse()
            sender.isUserInteractionEnabled = false
            alert("An error occurred", "Please try again", handler: {
                sender.isUserInteractionEnabled = true
            })
        }
    }
    
    func didUnLike(sender: LikeView) {
        if let hli = highlowid {
            LikeView.unlike(highlowid: hli, callback: { error in
                
                if error != nil {
                    sender.reverse()
                    sender.isUserInteractionEnabled = false
                    alert("An error occurred", "Please try again", handler: {
                        sender.isUserInteractionEnabled = true
                    })
                }
                else {
                    
                    //Update the number of likes
                    var prevLikes = Int(sender.numLikesView.text ?? "0")
                    if prevLikes ?? 1 < 1 {
                        prevLikes = 1
                    }
                    sender.numLikesView.text = String((prevLikes ?? 1) - 1)
                    
                }
                
            })
        } else {
            sender.reverse()
            sender.isUserInteractionEnabled = false
            alert("An error occurred", "Please try again", handler: {
                sender.isUserInteractionEnabled = true
            })
        }
    }
    
    func didFlag(sender: FlagView) {
        //Confirm they want to flag the High/Low
        let popup = PopupDialog(title: "Confirm Flag?", message: "Are you sure you want to flag this High/Low?", image: UIImage(named: "FlagWarning"))
        popup.addButtons([
            DestructiveButton(title: "Confirm") {
                
                if let hli = self.highlowid {

                    FlagView.flag(highlowid: hli, callback: { error in
                        
                        if error != nil {
                            sender.reverse()
                            sender.isUserInteractionEnabled = false
                            alert("An error occurred", "Please try again", handler: {
                                sender.isUserInteractionEnabled = true
                            })
                        }
                        
                    })
                    
                } else {
                    sender.reverse()
                    sender.isUserInteractionEnabled = false
                    alert("An error occurred", "Please try again", handler: {
                        sender.isUserInteractionEnabled = true
                    })
                }
                
            },
            CancelButton(title: "Cancel") {
                sender.reverse()
            }
        ])
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(popup, animated: true)
        }
        
    }
    
    func didUnflag(sender: FlagView) {
        
        //Confirm they want to flag the High/Low
        let popup = PopupDialog(title: "Confirm Unflag?", message: "Are you sure you want to unflag this High/Low?", image: UIImage(named: "FlagWarning"))
        popup.addButtons([
            DestructiveButton(title: "Confirm") {
                
                if let hli = self.highlowid {
                    
                    FlagView.unflag(highlowid: hli, callback: { error in
                        
                        if error != nil {
                            sender.reverse()
                            sender.isUserInteractionEnabled = false
                            alert("An error occurred", "Please try again", handler: {
                                sender.isUserInteractionEnabled = true
                            })
                        }
                        
                    })
                    
                } else {
                    sender.reverse()
                    sender.isUserInteractionEnabled = false
                    alert("An error occurred", "Please try again", handler: {
                        sender.isUserInteractionEnabled = true
                    })
                }
                
            },
            CancelButton(title: "Cancel") {
                sender.reverse()
            }
        ])
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(popup, animated: true)
        }
        
    }
    

}
