//
//  HighLowTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/22/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HighLowTableViewCell: UITableViewCell, HighLowViewDelegate {
    func willEditHigh(sender: HighLowView) {
    }
    
    func willEditLow(sender: HighLowView) {
    }
    
    func didFinishUpdatingContent(sender: HighLowView) {
    }
    
    func updateHighLow(with: [String : Any]) {
    }
    
    func openImageFullScreen(viewController: ImageFullScreenViewController) {
        self.delegate?.openImageFullScreen(viewController: viewController)
    }
    
    
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
    
    override func updateColors() {
        highLowView.updateColors()
        self.backgroundColor = getColor("White2Black")
        separator.backgroundColor = getColor("Separator")
        bottomSeparator.backgroundColor = getColor("Separator")
    }
    
    let separator = UIView()
    let bottomSeparator = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateColors()
                
        
        
        
        self.addSubview(separator)
        
        separator.eqTop(self).eqLeading(self).eqTrailing(self).height(25)
        
        //profileImageView
        let imageContainer = UIView()
        imageContainer.layer.cornerRadius = 20
        imageContainer.layer.shadowColor = UIColor.black.cgColor
        imageContainer.layer.shadowRadius = 1
        imageContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageContainer.layer.shadowOpacity = 0.3
        
        imageContainer.addSubview(profileImageView)
        profileImageView.eqWidth(imageContainer).eqHeight(imageContainer).centerX(imageContainer).centerY(imageContainer)
        
        profileImageView.layer.cornerRadius = 20
        
        
        self.addSubview(imageContainer)
        
        imageContainer.topToBottom(separator, 20).centerX(self).width(40).height(40)
        
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
        highLowView.delegate = self
        
        self.isUserInteractionEnabled = false
        
        self.addSubview(highLowView)
        
        highLowView.topToBottom(dateView, 10).centerX(self).eqWidth(self, 0.0, 0.9)
        
        
        
        
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
    func openImageFullScreen(viewController: ImageFullScreenViewController)
    
}
