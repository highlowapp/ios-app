//
//  HighLowView.swift
//  HighLow
//
//  Created by Caleb Hester on 6/11/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

@IBDesignable
class HighLowView: UIView, HLSectionViewDelegate, LikeViewDelegate, FlagViewDelegate {
    
    weak var delegate: HighLowViewDelegate?
    
    var highlowid: String?
    let highSection: HLSectionView = HLSectionView()
    let lowSection: HLSectionView = HLSectionView()
    var likeView: LikeView = LikeView()
    var flagView = FlagView()
    
    var callbackForLikeFlag: ((_ likeNum: Int?, _ liked: Int?, _ flagged: Int?) -> Void)?
    var editable: Bool = false {
        didSet {
            highSection.editable = editable
            lowSection.editable = editable
        }
    }
    
    var includesLikeFlag: Bool = true
    
    var total_likes = 0
    
    let dateLabel: UILabel = UILabel()
    var date: String? {
        didSet {
            if date != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let _date = dateFormatter.date(from: date!)
                
                if _date != nil {
                    let otherDateFormatter = DateFormatter()
                    otherDateFormatter.timeStyle = .none
                    otherDateFormatter.dateStyle = .medium
                    dateLabel.text = otherDateFormatter.string(from: _date!)
                }
            }
        }
    }
    
    var highCompleted: Bool = false
    var lowCompleted: Bool = false
    
    var data: [String:Any] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder  aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    @objc func onHighLowUpdate(notification: Notification) -> Void {
        if let data = notification.userInfo as NSDictionary? {
            if let hli = data["highlowid"] as? String {
                if hli == self.highlowid ?? "" {
                    self.updateContent( notification.userInfo! as NSDictionary )
                }
            }
        }
    }
    
    
    
    func setup() {
        
        //Notification ovserver
        NotificationCenter.default.addObserver(forName: Notification.Name("highLowUpdate"), object: nil, queue: nil, using: onHighLowUpdate)
        
        subviews.forEach({ $0.removeFromSuperview() })
        self.backgroundColor = .white
        self.accessibilityIdentifier = "highLowView"

        //High Label
        let highLabel = UILabel()
        highLabel.text = "High"
        highLabel.font = UIFont(name: "Chalkboard SE", size: 20.0)
        highLabel.accessibilityIdentifier = "highLabel"
        highLabel.textColor = .black
        
        self.addSubview(highLabel)
        
        highLabel.eqLeading(self, 20).eqTop(self, 20)
        
        //High Section
        highSection.accessibilityIdentifier = "highSection"
        
        //High section gets id of 0
        highSection.id = 0
        
        //Set high section delegate
        highSection.delegate = self
        
        self.addSubview(highSection)
        
        highSection.centerX(self).eqWidth(self).topToBottom(highLabel)
        
        
        //Separating logo
        let logo = UIImageView()
        
        logo.image = UIImage(named: "logo-light-triangles")
        logo.accessibilityIdentifier = "logo"
        
        self.addSubview(logo)
        
        logo.topToBottom(highSection).centerX(self).width(40).height(40)
        
        
        //Low label
        let lowLabel = UILabel()
        lowLabel.text = "Low"
        lowLabel.font = UIFont(name: "Chalkboard SE", size: 20.0)
        lowLabel.accessibilityIdentifier = "lowLabel"
        lowLabel.textColor = .black
            
        self.addSubview(lowLabel)
        
        lowLabel.eqLeading(self, 20).topToBottom(logo)
        
        //Low Section
        lowSection.accessibilityIdentifier = "lowSection"
        
        //Low section gets id of 1
        lowSection.id = 1
        
        //Set low section delegate
        lowSection.delegate = self
        
        self.addSubview(lowSection)
        
        lowSection.centerX(self).eqWidth(self).topToBottom(lowLabel)
        
        if includesLikeFlag {
            //Like and flag section
            let likeFlag = UIStackView()
            likeFlag.accessibilityIdentifier = "likeFlag"
            
            self.addSubview(likeFlag)
            
            likeFlag.axis = .horizontal
            
            flagView = FlagView()
            flagView.delegate = self
            likeFlag.addArrangedSubview(flagView)
            
            dateLabel.textColor = .lightGray
            dateLabel.font = UIFont.systemFont(ofSize: 15)
            dateLabel.textAlignment = .center
            
            
            
            likeFlag.addArrangedSubview(dateLabel)
            
            
            if date != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let _date = dateFormatter.date(from: date!)
                
                if _date != nil {
                    let otherDateFormatter = DateFormatter()
                    otherDateFormatter.timeStyle = .none
                    otherDateFormatter.dateStyle = .medium
                    dateLabel.text = otherDateFormatter.string(from: _date!)
                }
            }
            
            
            likeView = LikeView()
            likeView.delegate = self
            likeFlag.addArrangedSubview(likeView)
            
            likeView.eqTop(flagView)
            
            
            likeFlag.topToBottom(lowSection, 30).eqWidth(self, -40).centerX(self).height(50)
            
            likeFlag.alignment = .center
            likeFlag.distribution = .equalCentering
            
            self.eqBottom(likeFlag, 20)
        } else {
            self.eqBottom(lowSection, 20)
        }
        
        self.sizeToFit()
        self.layoutIfNeeded()
        
        self.isUserInteractionEnabled = true
        
    }
    
    override func didMoveToSuperview() {
        setup()
    }
    
    func addButtonPressed(sender: HLSectionView) {
        //Is it a high or a low?
        if sender.id == 0 {
            //willEditHigh
            delegate?.willEditHigh(sender: self)
        }
        
        else if sender.id == 1 {
            //willEditLow
            delegate?.willEditLow(sender: self)
        }
    }
    
    func didFinishUpdating(sender: HLSectionView) {
        
        if sender.id == 0 {
            highCompleted = true
        }
        
        if sender.id == 1 {
            lowCompleted = true
        }
        
        self.sizeToFit()
        self.layoutIfNeeded()
        
        
        
        
        if highCompleted && lowCompleted {
            delegate?.didFinishUpdatingContent(sender: self)
        }
        
        
        
    }
    
    func setLikeFlag(liked: Int?, totalLikes: Int?, flagged: Int?) {
        if liked != nil {
            if liked == 1 {
                likeView.isLiked()
            }
            else if liked == 0 {
                likeView.isNotLiked()
            }
        }
        
        if flagged != nil {
            if flagged == 1 {
                flagView.isFlagged()
            }
            else if flagged == 0 {
                flagView.isNotFlagged()
            }
        }
        
        if totalLikes != nil {
            likeView.numLikesView.text = String(totalLikes!)
        }
        
    }
    
    func updateContent(_ content: NSDictionary) {
        //Here we update the content of the HighLowSectionViews
        if let highImage = content["high_image"] as? String {
            highSection.image = highImage
        }
        if let high = content["high"] as? String {
            highSection.content = high
        }
        if let lowImage = content["low_image"] as? String {
            lowSection.image = lowImage
        }
        if let low = content["low"] as? String {
            lowSection.content = low
        }
        
        highCompleted = false
        lowCompleted = false
                
        highSection.updateContent()
        lowSection.updateContent()
        
        //likeView.numLikesView.text = String(content["total_likes"] as? Int ?? 0)
        
        if let liked = content["liked"] as? Int {
            if liked == 1 {
                likeView.isLiked()
            } else {
                likeView.isNotLiked()
            }
        }
        
        if let flagged = content["flagged"] as? Int {
            if flagged == 1 {
                flagView.isFlagged()
            } else {
                flagView.isNotFlagged()
            }
        }
    }

}


protocol HighLowViewDelegate: AnyObject {
    func willEditHigh(sender: HighLowView)
    func willEditLow(sender: HighLowView)
    func didFinishUpdatingContent(sender: HighLowView)
    func updateHighLow(with: [String: Any])
}





//LikeView delegate methods
extension HighLowView {
    
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
                    //self.callbackForLikeFlag?((prevLikes ?? 0) + 1, 1, nil)
                    self.delegate?.updateHighLow(with: [
                        "liked": 1,
                        "total_likes": (prevLikes ?? 0) + 1
                    ])
                    
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
                    //self.callbackForLikeFlag?((prevLikes ?? 1) - 1, 0, nil)
                    
                    self.delegate?.updateHighLow(with: [
                        "liked": 0,
                        "total_likes": (prevLikes ?? 1) - 1
                    ])
                }
                
            })
        } else {
            alert("An error occurred", "Please try again")
            sender.reverse()
        }
    }
}



//FlagView delegate methods
extension HighLowView {
    
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
                    
                    else {
                        self.delegate?.updateHighLow(with: [
                            "flagged": 1
                        ])
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
                    } else {
                        self.delegate?.updateHighLow(with: [
                            "flagged": 0
                        ])
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


