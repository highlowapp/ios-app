//
//  FlagView.swift
//  HighLow
//
//  Created by Caleb Hester on 7/8/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class FlagView: UIImageView {
    
    var hasBeenTapped: Bool = false
    weak var delegate: FlagViewDelegate?

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

    private func setup() {
        
        self.image = UIImage(named: "flag-outline")
        if hasBeenTapped {
            self.image = UIImage(named: "flag-filled")
        }
        
        self.width(30).height(30)
        
        //Tap recognizer
        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.isUserInteractionEnabled = true
        
        self.addGestureRecognizer(tapper)
        
    }
    
    func isFlagged() {
        hasBeenTapped = true
        updateImage()
    }
    
    func isNotFlagged() {
        hasBeenTapped = false
        updateImage()
    }
    
    
    
    
    static func flag(highlowid: String, callback: @escaping (_ error: String?) -> Void) {
        
        authenticatedRequest(url: "https://api.gethighlow.com/highlow/flag/" + highlowid, method: .post, parameters: [:], onFinish: { json in
            
            if let error = json["error"] as? String {
                callback(error)
            } else {
                NotificationCenter.default.post(name: Notification.Name("highLowUpdate"), object: nil, userInfo: [
                    "highlowid": highlowid,
                    "flagged": 1
                ])
                
                callback(nil)
            }
            
        }, onError: { error in
            callback(error)
        })
        
    }
    
    static func unflag(highlowid: String, callback: @escaping (_ error: String?) -> Void) {
        
        authenticatedRequest(url: "https://api.gethighlow.com/highlow/unflag/" + highlowid, method: .post, parameters: [:], onFinish: { json in
            
            if let error = json["error"] as? String {
                callback(error)
            } else {
                NotificationCenter.default.post(name: Notification.Name("highLowUpdate"), object: nil, userInfo: [
                    "highlowid": highlowid,
                    "flagged": 0
                ])
                
                callback(nil)
            }
            
        }, onError: { error in
            callback(error)
        })
        
    }
    
    
    
    
    func updateImage() {
        self.image = UIImage(named: "flag-outline")
        if hasBeenTapped {
            self.image = UIImage(named: "flag-filled")
        }
    }
    
    func reverse() {
        hasBeenTapped = !hasBeenTapped
        updateImage()
    }
    
    
    @objc func handleTap() {
        //Make request to flag highlow
        hasBeenTapped = !hasBeenTapped
        updateImage()
        
        if hasBeenTapped {
            delegate?.didFlag(sender: self)
        }
        else {
            delegate?.didUnflag(sender: self)
        }
    }
}

protocol FlagViewDelegate: AnyObject {
    func didFlag(sender: FlagView)
    func didUnflag(sender: FlagView)
}
