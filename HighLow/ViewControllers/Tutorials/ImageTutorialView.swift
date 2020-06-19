//
//  ImageTutorialView.swift
//  HighLow
//
//  Created by Caleb Hester on 4/3/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ImageTutorialView: UIView {

    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.addSubview(imageView)
        
        imageView.eqTop(self).eqWidth(self, 0, 0.7).centerX(self)
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.14).isActive = true
        
        self.addSubview(label)
        
        label.topToBottom(imageView, 10).centerX(self).eqWidth(self, 0.0, 0.9)
        
        label.numberOfLines = 0
        label.textColor = AppColors.primary
        label.font = UIFont(name: "Chalkboard SE", size: 25.0)
        label.textAlignment = .center
    }
    
    
    public func withImage(named img: String) -> ImageTutorialView {
        imageView.image = UIImage(named: img)
        return self
    }
    
    public func with(title: String, image: String, button: Bool = false) -> ImageTutorialView {
        imageView.image = UIImage(named: image)
        label.text = title
        
        if button {
            let btn = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 45))
            btn.title = "Get Started!"
            
            self.addSubview(btn)
            
            btn.topToBottom(label, 20).eqWidth(self, 0.0, 0.6).height(45).centerX(self)
            
            btn.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
            self.eqBottom(btn)
        } else {
            self.eqBottom(label)
        }
        
        return self
    }
    
    @objc func skipTutorial() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasReceivedTutorial")
        switchToAuth()
    }


}
