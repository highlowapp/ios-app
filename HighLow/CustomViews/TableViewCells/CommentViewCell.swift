//
//  CommentViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/9/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CommentViewCell: UITableViewCell {
    
    var uid: String? {
        didSet {
            checkUid()
        }
    }
    
    var commentid: String?
    
    weak var delegate: CommentViewCellDelegate?
    
    let profileImage: HLImageView = HLImageView(frame: CGRect.zero)
    let nameLabel: UILabel = UILabel()
    let timestampLabel: UILabel = UILabel()
    let messageLabel: UILabel = UILabel()
    
    
    
    convenience init(comment: Comment) {
        
        self.init(style: .default, reuseIdentifier: "comment")
        
        let firstname = comment.firstname!
        let lastname = comment.lastname!
        let _timestamp = comment._timestamp!
        let message = comment.message!
        let profileimage = comment.profileimage!
        
        
        
        nameLabel.text = firstname + " " + lastname
        
        let date = Date.dateFromISOString(string: _timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        timestampLabel.text = dateFormatter.string(from: date!)
        
        messageLabel.text = message
        var imageURL = profileimage
        
        if !profileimage.starts(with: "http") {
            imageURL = "https://storage.googleapis.com/highlowfiles/" + profileimage
        }
        
        self.profileImage.loadImageFromURL(imageURL)
        
        self.awakeFromNib()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Add subviews
        self.addSubview(profileImage)
        self.addSubview(nameLabel)
        self.addSubview(timestampLabel)
        self.addSubview(messageLabel)
        
        //Rounded image
        profileImage.layer.cornerRadius = 20
        
        //Timestamp
        timestampLabel.textColor = UIColor.lightGray
        timestampLabel.font = UIFont.systemFont(ofSize: 13)
        
        //Now, for the constraints
        profileImage.eqLeading(layoutMarginsGuide, 20).eqTop(self, 20).width(40).height(40)
        nameLabel.leadingToTrailing(profileImage, 10).eqTop(profileImage)
        timestampLabel.eqLeading(nameLabel).topToBottom(nameLabel, 5)
        messageLabel.eqLeading(nameLabel).topToBottom(timestampLabel, 5).eqTrailing(self, -20)
        
        messageLabel.numberOfLines = 0
        
        
        
        //And finally, we need the "said:" label
        let saidLabel = UILabel()
        saidLabel.text = "said:"
        saidLabel.textColor = UIColor.lightGray
        saidLabel.font = UIFont.systemFont(ofSize: 15)
        
        self.addSubview(saidLabel)
        
        saidLabel.eqBottom(nameLabel).leadingToTrailing(nameLabel, 3)
        
        self.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    
    @objc func edit() {
        delegate?.willEditComment(sender: self)
    }
    
    @objc func deleteComment() {
        
        if commentid != nil {
        
            authenticatedRequest(url: "https://api.gethighlow.com/comment/delete/" + commentid!, method: .post, parameters: [:], onFinish: { json in
                
                if (json["error"] as? String) != nil {
                    alert("An error occurred", "Please try again.")
                } else {
                    
                    
                    self.delegate?.hasDeletedComment(sender: self)
                    
                    
                }
                
            }, onError: { error in
                
                alert("An error occurred", "Please try again.")
                
            })
        
        } else {
            alert("An error occurred", "There was a problem when deleting the comment")
        }
    }
    
    
    static func editComment(loader: HLLoaderView, commentid: String, message: String, callback: @escaping () -> Void) {
        
        let params: [String: String] = [
            "message": message
        ]
        
        loader.startLoading()
        
        authenticatedRequest(url: "https://api.gethighlow.com/comment/update/" + commentid, method: .post, parameters: params, onFinish: { json in
            
            loader.stopLoading()
            loader.removeFromSuperview()
            
            if let error = json["error"] as? String {
                if error == "no-message" {
                    alert("Whoops!", "You have to enter a message first!")
                } else {
                    alert("An error occurred", "Please try again.")
                }
            } else {
                
                
                callback()
                
                
            }
            
        }, onError: { error in
            loader.stopLoading()
            loader.removeFromSuperview()
            alert("An error occurred", "Please try again.")
        })
        
    }
    
    func addEditOptions() {
        //If the uid is that of the current user, add a "more" button
        let menuButton = UIImageView(image: UIImage(named: "more"))
        
        self.addSubview(menuButton)
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        menuButton.topAnchor.constraint(equalTo: self.profileImage.topAnchor).isActive = true
        menuButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        menuButton.isUserInteractionEnabled = true
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.more))
        menuButton.addGestureRecognizer(tapper)
    }
    
    func checkUid() {
        
        if let uid = KeychainWrapper.standard.string(forKey: "uid") {
            if self.uid == uid {
                addEditOptions()
            }
        }
        
        else {
            authenticatedRequest(url: "https://api.gethighlow.com/user/get/uid", method: .post, parameters: [:], onFinish: { json in
                
                if (json["error"] as? String) != nil {
                    alert("An error has occurred", "Try closing the app and opening it back up.")
                } else {
                    
                    if let myUid = json["uid"] as? String {
                        
                        if myUid == self.uid {
                            
                            self.addEditOptions()
                            
                        }
                        
                    }
                    
                }
                
                
            }, onError: { error in
                
                
                
            })
        }
    }
    
    
    @objc func more() {
        
        let alertViewController = UIAlertController(title: "Action", message: "Choose an action to perform on this comment", preferredStyle: .actionSheet)
        alertViewController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            self.edit()
        }))
        alertViewController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.deleteComment()
        }))
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alertViewController, animated: true)
        }
        
    }
    
    
    
    func updateContent( imageURL: String, firstname: String, lastname: String, timestamp: String, message: String) {
        
        nameLabel.text = firstname + " " + lastname
        
        //Convert timestamp to date
        let date = Date.dateFromISOString(string: timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        timestampLabel.text = dateFormatter.string(from: date!)
        
        messageLabel.text = message
        
        //Now for the image request
    profileImage.loadImageFromURL("https://storage.googleapis.com/highlowfiles/" + imageURL)
        
    }

}







extension Date {
    static func ISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "MDT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.date(from: string)
    }
}


protocol CommentViewCellDelegate: AnyObject {
    func willEditComment(sender: CommentViewCell)
    func hasDeletedComment(sender: CommentViewCell)
}
