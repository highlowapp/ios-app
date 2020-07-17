//
//  DiaryCollectionViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 7/8/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    
    private var shadowLayer: CAShapeLayer!
    
    var indexPath: IndexPath?
    let thumbnail: UIImageView = UIImageView()
    let title: UILabel = UILabel()
    var activity: ActivityResource?
    
    weak var delegate: DiaryCollectionViewCellDelegate?
    
    let thumbnails = [
        "diary": "DiaryThumbnail"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let container = UIView()
        container.clipsToBounds = true
        self.contentView.addSubview(container)
        container.eqLeading(contentView).eqTrailing(contentView).eqTop(contentView).eqBottom(contentView)
        
        let thumbArea = UIView()
        thumbArea.addSubview(thumbnail)
        container.addSubview(thumbArea)
        
        let titleArea = UIView()
        titleArea.addSubview(title)
        
        let separator = UIView()
        separator.backgroundColor = rgb(240, 240, 240)
        container.addSubview(separator)
        
        container.addSubview(titleArea)
        
        thumbArea.eqTop(container).eqLeading(container).eqTrailing(container)
        thumbnail.centerX(thumbArea).centerY(thumbArea)
        
        let more = UIImageView(image: UIImage(named: "more"))
        more.isUserInteractionEnabled = true
        
        thumbArea.addSubview(more)
        more.eqTop(thumbArea, 5).eqTrailing(thumbArea, -5).width(30).height(30)
        more.contentMode = .center
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(moreOptions(_:)))
        more.addGestureRecognizer(tapper)
        
        titleArea.eqLeading(container).eqTrailing(container).eqBottom(container).height(50)
        
        separator.bottomToTop(titleArea).height(2).eqLeading(container).eqTrailing(container)
        
        thumbArea.bottomToTop(separator)
        
        title.centerY(titleArea).eqLeading(titleArea, 15).eqTrailing(titleArea, -15)
        
        title.font = .systemFont(ofSize: 15)
        title.numberOfLines = 1
        title.textColor = .black
        
        thumbArea.backgroundColor = rgb(240, 240, 240)
        titleArea.backgroundColor = .white
        
        container.layer.cornerRadius = 10
        
        container.showBorder(rgb(240, 240, 240), 2)
        
        /*
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOpacity = 0.3
        self.contentView.layer.shadowRadius = 5
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        */
    }
    
    func configure(indexPath: IndexPath, activity: ActivityResource) {
        self.indexPath = indexPath
        self.activity = activity
        
        activity.registerReceiver(self, onDataUpdate: self.onActivityUpdate(_:_:))
    }
    
    func onActivityUpdate(_ owner: DiaryCollectionViewCell, _ activity: Activity) {
        print("Hi")
        self.title.text = activity.title
        self.thumbnail.image = UIImage(named: thumbnails[activity.type!] ?? "Untitled")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    
    
    @objc func moreOptions(_ sender: UIView) {
        let _alert = UIAlertController(title: "Options", message: "Choose an action", preferredStyle: .actionSheet)
        _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        _alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.activity?.delete(onSuccess: { activity in
                self.delegate?.didDelete(sender: self)
            }, onError: { error in
                alert("An error occurred", "Please try again")
            })
        }))
        
        _alert.popoverPresentationController?.sourceView = sender
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(_alert, animated: true)
        }
    }
    
}

protocol DiaryCollectionViewCellDelegate: AnyObject {
    func didDelete(sender: DiaryCollectionViewCell)
}
