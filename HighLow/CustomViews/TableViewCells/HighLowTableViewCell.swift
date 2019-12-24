//
//  HighLowTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/22/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HighLowTableViewCell: UITableViewCell {
    
    var profileImageView: HLImageView = HLImageView(frame: .zero)
    var nameView: UILabel = UILabel()
    var dateView: UILabel = UILabel()
    var highLowView: HighLowView = HighLowView(frame: .zero)
    var homeViewController: HomeViewController = HomeViewController()
    var highLowData: NSDictionary?
    var highlowid: String?
    
    weak var delegate: HighLowTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .white
        
        let separator = UIView()
        separator.backgroundColor = rgb(240, 240, 240)
        
        self.addSubview(separator)
        
        separator.eqTop(self).eqLeading(self).eqTrailing(self).height(25)
        
        //profileImageView
        profileImageView.layer.cornerRadius = 20
        
        self.addSubview(profileImageView)
        
        profileImageView.topToBottom(separator, 20).centerX(self).width(40).height(40)
        
        //nameView
        nameView.font = .systemFont(ofSize: 15)
        nameView.textAlignment = .center
        
        self.addSubview(nameView)
        
        nameView.topToBottom(profileImageView, 5).centerX(self)
        
        //postedOnView
        dateView.font = .systemFont(ofSize: 13)
        dateView.textColor = .lightGray
        dateView.textAlignment = .center
        dateView.text = "Posted on"
        
        self.addSubview(dateView)
        
        dateView.topToBottom(nameView, 5).centerX(self)
        
        //highLowView
        highLowView.includesLikeFlag = false
        
        self.isUserInteractionEnabled = false
        
        self.addSubview(highLowView)
        
        highLowView.topToBottom(dateView, 10).centerX(self).eqWidth(self, 0.0, 0.9)
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = rgb(240, 240, 240)
        
        self.addSubview(bottomSeparator)
        
        bottomSeparator.topToBottom(highLowView, 20).eqLeading(highLowView).eqTrailing(highLowView).height(2)
    
        self.bottomAnchor.constraint(equalTo: bottomSeparator.bottomAnchor).isActive = true
        
        self.isUserInteractionEnabled = true
    }

    
    func loadData(profileImage: String?, name: String?, highlow: HighLow) {
        //Profile image
        if profileImage != nil {
            var url = profileImage!
            if !url.starts(with: "http") {
                url = "https://storage.googleapis.com/highlowfiles/" + url
            }
            profileImageView.loadImageFromURL(url)
        }
        
        //Name
        if name != nil {
            nameView.text = name!
        }
        
        //_date
        let _date = highlow.date!
        
        dateView.text = "Posted on " + dateStrToRegularDate(dateStr: _date)
        
        
        //Store the ID
        highlowid = highlow.highlowid!
        
        
        //HighLow
        highLowView.updateContent(highlow.asJson())
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        /*
        let homeViewController = HomeViewController()
        homeViewController.highlowid = highlowid
        
        homeViewController.title = "View High/Low"
        
        delegate?.openHomeViewController(homeViewController: homeViewController)
 */
    }

}


protocol HighLowTableViewCellDelegate: AnyObject {
    
    func openHomeViewController(homeViewController: HomeViewController)
    
}
