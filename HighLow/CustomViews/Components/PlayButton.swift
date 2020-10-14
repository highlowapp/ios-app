//
//  PlayButton.swift
//  HighLow
//
//  Created by Caleb Hester on 8/3/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class PlayButton: UIButton {
    
    var isPlaying: Bool = false
    var isDisabled: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    var img: UIImageView = UIImageView(image: UIImage(named: "Play"))
    
    private func setup() {
        self.showBorder(AppColors.secondary, 2)
        self.aspectRatioFromWidth(1)
        self.addSubview(img)
        img.contentMode = .scaleAspectFit
        img.centerX(self).centerY(self).eqWidth(self, 0, 0.6).aspectRatioFromWidth(1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
    }

    func togglePlaying() {
        isPlaying = !isPlaying
        
        if isPlaying {
            img.image = UIImage(named: "Pause")
        } else {
            img.image = UIImage(named: "Play")
        }
    }
    
    func disable() {
        isDisabled = true
        self.layer.borderColor = self.layer.borderColor?.copy(alpha: 0.5)
        img.alpha = 0.5
    }
    
    func enable() {
        isDisabled = false
        self.layer.borderColor = self.layer.borderColor?.copy(alpha: 1)
        img.alpha = 1
    }
}
