//
//  DiaryTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 9/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit

class DiaryTableViewCell: CardTableViewCell {
    
    var user: UserResource?
    var activity: ActivityResource?
    
    var indexPath: IndexPath = IndexPath()
    
    weak var delegate: DiaryTableViewCellDelegate?
    
    let profileImage: HLRoundImageView = HLRoundImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    
    let activityView: ReflectViewer = ReflectViewer()
    
    var activityViewHeightConstraint: NSLayoutConstraint?
            
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }
    
    func setHeight(_ height: CGFloat) {
        self.activityView.contentScrollHeight = height
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.textAlignment = .center
        
        self.contView.addSubviews([profileImage, nameLabel, activityView])
        profileImage.eqTop(self.contView, 20).centerX(self.contView).width(30).aspectRatioFromWidth(1)
        nameLabel.topToBottom(profileImage, 10).eqLeading(self.contView, 10).eqTrailing(self.contView, -10)
        activityView.topToBottom(nameLabel, 10).eqLeading(self.contView, 5).eqTrailing(self.contView, -5)
        
        self.contView.bottomAnchor.constraint(equalTo: activityView.bottomAnchor, constant: 10).isActive = true
        
        activityView.navigationDelegate = self
        activityView.scrollView.isScrollEnabled = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUser(_ user: UserResource?) {
        guard let user = user else { return }
        self.user = user
        if let imageUrl = self.user?.profileimage {
            self.profileImage.loadImageFromURL(imageUrl)
        }
        self.nameLabel.text = user.fullName
    }
    
    func setActivity(_ activity: ActivityResource?) {
        guard let activity = activity else { return }
        
        self.activity = activity
        
        activity.registerReceiver(self, onDataUpdate: onActivityUpdate(_:_:))
    }
    
    func onActivityUpdate(_ owner: DiaryTableViewCell, _ activity: Activity) {
        //loadActivityBlocks()
    }
    
    func loadActivityBlocks() {
        guard let activity = activity else { return }
        
        guard let data = activity.data else { return }
        guard let blocks = data.value(forKey: "blocks") as? [NSDictionary] else { return }
        activityView.loadBlocks(blocks, completion: {
            self.activityView.invalidateIntrinsicContentSize()
            self.delegate?.diaryTableViewCell(self, didUpdateHeight: self.activityView.intrinsicContentSize.height, atRow: self.indexPath.row)
        })
    }
    
    func reloadActivity() {
        guard let activity = activity else { return }
        
        guard let data = activity.data else { return }
        
        self.activity = activity
        self.activityView.invalidateIntrinsicContentSize()
    }

}

extension DiaryTableViewCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {        
        loadActivityBlocks()
    }
}

protocol DiaryTableViewCellDelegate: AnyObject {
    func diaryTableViewCell(_ cell: DiaryTableViewCell, didUpdateHeight height: CGFloat, atRow row: Int)
}
