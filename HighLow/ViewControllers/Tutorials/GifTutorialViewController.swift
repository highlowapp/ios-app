//
//  TutorialViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/15/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftGifOrigin

@IBDesignable
class GifTutorialViewController: UIViewController {
    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    let containerView: UIView = UIView()
    let cleanArea: UIView = UIView()
    
    override func viewDidLayoutSubviews() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .none
        
        self.view.addSubview(cleanArea)
        
        cleanArea.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view.safeAreaLayoutGuide, 50)
        
        cleanArea.backgroundColor = .none

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
        
        self.view.addSubview(containerView)
        
        containerView.centerX(self.view).eqTop(self.view, 30).eqHeight(self.view, 0.0, 0.6).aspectRatioFromHeight(0.556)
        
        
        //containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.556).isActive = true
        imageView.showBorder(.blue, 2)
        //cleanArea.eqBottom(containerView, 20)
        
        label.font = UIFont(name: "Chalkboard SE", size: 25.0)
        label.text = "Swipe to see previous High/Lows"
        label.textColor = AppColors.primary
        label.numberOfLines = 0
        label.textAlignment = .center
        
        self.view.addSubview(label)
        
        label.topToBottom(cleanArea, 10).centerX(self.view).eqWidth(self.view, 0.0, 0.9)
    }
    
    func loadGif(named gif: String) -> GifTutorialViewController {
        imageView.loadGif(name: gif)
        return self
    }
    
    func loadData(title: String, img: UIImage) -> GifTutorialViewController {
        label.text = title
        imageView.image = img
        return self
    }
    
}
