//
//  HLImageView.swift
//  HighLow
//
//  Created by Caleb Hester on 7/9/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HLImageView: UIImageView {
    
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var url: String?
    var opensFullScreen: Bool = false
    
    weak var delegate: HLImageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    private func setup() {
        
        self.backgroundColor = rgb(230, 230, 230)
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        
        self.addSubview(indicator)
        
        indicator.centerX(self).centerY(self).eqWidth(self).eqHeight(self)
        
        indicator.style = .gray
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
    }
    
    @objc func openFullScreen() {
        let fullScreenViewController = ImageFullScreenViewController()
        fullScreenViewController.loadImage(url: self.url ?? "")
        self.delegate?.openImageFullScreen(viewController: fullScreenViewController)
    }
    
    func doesOpenFullScreen() {
        opensFullScreen = true
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(openFullScreen))
        self.addGestureRecognizer(tapper)
        self.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        indicator.layer.cornerRadius = self.layer.cornerRadius
        indicator.layer.borderColor = self.layer.borderColor
        indicator.layer.borderWidth = self.layer.borderWidth
    }
    
    func loadImageFromURL(_ url: String) {
        
        self.url = url
        
        ImageCache.getImage(url, onSuccess: { image in
            
            self.indicator.stopAnimating()
            self.image = image
            
        }, onError: {
            
            
            
        })
        
    }
}


protocol HLImageViewDelegate: AnyObject {
    func openImageFullScreen(viewController: ImageFullScreenViewController)
}
