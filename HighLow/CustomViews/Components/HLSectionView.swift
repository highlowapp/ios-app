//
//  HLSectionView.swift
//  HighLow
//
//  Created by Caleb Hester on 6/11/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import Aztec

class HLSectionView: UIView, HLImageViewDelegate, TextViewAttachmentDelegate {
    func textView(_ textView: TextView, attachment: NSTextAttachment, imageAt url: URL, onSuccess success: @escaping (UIImage) -> Void, onFailure failure: @escaping () -> Void) {
        
    }
    
    func textView(_ textView: TextView, urlFor imageAttachment: ImageAttachment) -> URL? {
        return nil
    }
    
    func textView(_ textView: TextView, placeholderFor attachment: NSTextAttachment) -> UIImage {
        return UIImage()
    }
    
    func textView(_ textView: TextView, deletedAttachment attachment: MediaAttachment) {
        
    }
    
    func textView(_ textView: TextView, selected attachment: NSTextAttachment, atPosition position: CGPoint) {
        
    }
    
    func textView(_ textView: TextView, deselected attachment: NSTextAttachment, atPosition position: CGPoint) {
        
    }
    
    
    func openImageFullScreen(viewController: ImageFullScreenViewController) {
        self.delegate?.openImageFullScreen(viewController: viewController)
    }
    
    weak var delegate: HLSectionViewDelegate?
    
    var addButton: UIButton = HLButton()
    
    var editable: Bool = false {
        didSet {
            setup()
        }
    }
    
    var id: Int?
    
    var image: String = ""
    var content: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func updateColors() {
        contentView.backgroundColor = getColor("White2Black")
        contentView.textColor = getColor("BlackText")
        addButton.updateColors()
    }
    
    let contentView = Aztec.TextView(defaultFont: .systemFont(ofSize: 20), defaultMissingImage: UIImage())
    
    func setup() {
        subviews.forEach({ $0.removeFromSuperview() })
        
        
        //If we don't have a High/Low
        if content == "" && image == "" {
            
            if editable {
                //Button
                addButton = HLButton(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
                addButton.setImage(UIImage(named: "plus-white"), for: .normal)
                
                addButton.bringSubviewToFront(addButton.imageView!)
                
                //Calculate edge insets
                let imageSize: CGFloat = 30.0
                
                let verticalInset = (45 - imageSize)/2
                let horizontalInset = (200 - imageSize)/2
                
                //Add as subview
                self.addSubview(addButton)
                
                addButton.contentEdgeInsets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
                
                //Constraints
                addButton.centerX(self).width(200).height(45).eqBottom(self, -10).eqTop(self)
                
                
                //Set target for button
                addButton.addTarget(self, action: #selector(notifyDelegateOfButtonPress), for: .touchUpInside)
            }
            
            else {
                //Text
                let label = UILabel()
                label.font = .systemFont(ofSize: 20)
                label.text = "No content provided"
                label.sizeToFit()
                label.textColor = .gray
                
                self.addSubview(label)
                
                label.centerX(self).eqTop(self)
                self.eqBottom(label, 10)
            }
            
            delegate?.didFinishUpdating(sender: self)
        }
        
        else {
            //Otherwise, we need a UIImageView for the image, and a TextView for the content
            let imageView = HLImageView(frame: .zero)
            
            if image != "" {
                
                //Getting the correct type
                var type = "high"
                if self.id == 1 {
                    type = "low"
                }
                            
                imageView.backgroundColor = rgb(230, 230, 230)
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 10
                imageView.contentMode = .scaleAspectFill
                imageView.doesOpenFullScreen()
                
                imageView.delegate = self
                
                let imageContainer = UIView()
                imageContainer.layer.cornerRadius = 10
                imageContainer.layer.shadowColor = UIColor.black.cgColor
                imageContainer.layer.shadowRadius = 5
                imageContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
                imageContainer.layer.shadowOpacity = 0.3
                
                imageContainer.addSubview(imageView)
                
                imageView.eqWidth(imageContainer).eqHeight(imageContainer).centerX(imageContainer).centerY(imageContainer)
                
                self.addSubview(imageContainer)
                
                /*
                //A simple ActivityIndicator
                let imageIndicator = UIActivityIndicatorView()
                imageView.addSubview(imageIndicator)
                imageIndicator.style = .gray
                
                imageIndicator.eqWidth(imageView).eqHeight(imageView).centerX(imageView).centerY(imageView)
                
                imageIndicator.startAnimating()
                imageIndicator.hidesWhenStopped = true
                */
                
                imageView.loadImageFromURL("https://storage.googleapis.com/highlowfiles/" + type + "s/" + image)
                /*
                //imageView
                ImageCache.getImage(, onSuccess: { headerImg in
                    imageView.image = headerImg
                    
                    imageIndicator.stopAnimating()
                    
                }, onError: {
                    
                })
                  */
                
                //Constraints
                imageContainer.centerX(self).eqTop(self, 10).eqWidth(self, 0.0, 0.9)
                imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor).isActive = true
                
            }
            
            
            if content != "" {
            
                contentView.registerAttachmentImageProvider(HTMLAttachmentRenderer(font: .systemFont(ofSize: 20)))
                contentView.textAttachmentDelegate = self
                contentView.setHTML(content)
                contentView.isEditable = false
                contentView.isScrollEnabled = false
                contentView.textAlignment = .left
                
                
                //Constraints
                self.addSubview(contentView)
                
                contentView.centerX(self)
                
                if image != "" {
                    contentView.topToBottom(imageView, 10).eqWidth(imageView)
                }
                
                else {
                    contentView.eqTop(self, 10).eqWidth(self, 0.0, 0.9)
                }
                
                self.eqBottom(contentView)
                
            }
            
            if content == "" {
                self.eqBottom(imageView)
            }
            
            delegate?.didFinishUpdating(sender: self)
            
            if editable {
                //And we also need an edit button
                let editButton = HLButton()
                
                editButton.colorStyle = "orange"
                editButton.setImage(UIImage(named: "edit-pencil"), for: .normal)
                editButton.layer.cornerRadius = 20
                
                self.addSubview(editButton)
                
                
                //Calculate edge insets
                let imageSize: CGFloat = 25.0
                
                let verticalInset = (40 - imageSize)/2
                let horizontalInset = (40 - imageSize)/2
                
                editButton.contentEdgeInsets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
                
                editButton.width(40).height(40).eqTop(self, -10).eqTrailing(self, -10)
                
                //Add target
                editButton.addTarget(self, action: #selector(notifyDelegateOfButtonPress), for: .touchUpInside)
            }
        }
        
    }
    
    func updateContent() {
        //Reload the content
        setup()
    }
    
    @objc func notifyDelegateOfButtonPress() {
        delegate?.addButtonPressed(sender: self)
    }
    

}


protocol HLSectionViewDelegate: AnyObject {
    func addButtonPressed(sender: HLSectionView)
    func didFinishUpdating(sender: HLSectionView)
    func openImageFullScreen(viewController: ImageFullScreenViewController)
}
