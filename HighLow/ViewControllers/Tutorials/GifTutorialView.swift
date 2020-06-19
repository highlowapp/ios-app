//
//  GifTutorialView.swift
//  HighLow
//
//  Created by Caleb Hester on 4/3/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class GifTutorialView: UIView {

    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    let containerView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.backgroundColor = .none

        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowOpacity = 1
        containerView.clipsToBounds = false
        
        
        containerView.addSubview(imageView)
        containerView.layer.cornerRadius = 7
        imageView.layer.cornerRadius = 7
        
        imageView.centerX(containerView).centerY(containerView).eqWidth(containerView).eqHeight(containerView)
        
        imageView.clipsToBounds = true
        
        self.addSubview(containerView)
        
        containerView.centerX(self).eqTop(self, 30).eqHeight(self, 0.0, 0.6).aspectRatioFromHeight(0.556)
        
        
        //containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.556).isActive = true
        imageView.showBorder(.blue, 2)
        //cleanArea.eqBottom(containerView, 20)
        
        label.font = UIFont(name: "Chalkboard SE", size: 25.0)
        label.text = "Swipe to see previous High/Lows"
        label.textColor = AppColors.primary
        label.numberOfLines = 0
        label.textAlignment = .center
        
        self.addSubview(label)
        
        label.topToBottom(containerView, 10).centerX(self).eqWidth(self, 0.0, 0.9)
    }
    
    
    func loadGif(named gif: String) -> GifTutorialView {
        imageView.loadGif(name: gif)
        return self
    }
    
    func loadData(title: String, img: UIImage) -> GifTutorialView {
        label.text = title
        imageView.image = img
        return self
    }

}
