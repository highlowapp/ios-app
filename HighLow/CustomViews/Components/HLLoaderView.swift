//
//  HLLoaderView.swift
//  HighLow
//
//  Created by Caleb Hester on 6/15/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HLLoaderView: UIView {
    
    var loader = UIImageView()
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var activityIndicator = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.backgroundColor = rgba(255, 255, 255, 0.9)
        /*
        let img = UIImage(named: "logo-light-triangles")
        
        loader = UIImageView(image: img)
        loader.clipsToBounds = true
        loader.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        self.addSubview(loader)
        
        loader.centerX(self).centerY(self)
        
        widthConstraint = loader.widthAnchor.constraint(equalToConstant: 0)
        heightConstraint = loader.heightAnchor.constraint(equalToConstant: 0 )
        
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
         */
                
        activityIndicator.color = AppColors.primary
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        
        self.addSubview(activityIndicator)
        
        activityIndicator.centerX(self).centerY(self)
        
    }
    
    func startLoading() {
        /*UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.widthConstraint?.constant = 150
            self.heightConstraint?.constant = 150
            self.loader.layoutIfNeeded()
        }, completion: nil)*/
        
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        //self.loader.layer.removeAllAnimations()
        activityIndicator.stopAnimating()
    }
    
}


