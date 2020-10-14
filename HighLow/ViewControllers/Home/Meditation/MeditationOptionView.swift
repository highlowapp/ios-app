//
//  MeditationOptionView.swift
//  HighLow
//
//  Created by Caleb Hester on 8/18/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class MeditationOptionView: UIView {
    let imageView: UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel()
    let valueLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let chevron = UIImageView(image: UIImage(named: "RightArrow"))
        self.addSubviews([imageView, nameLabel, valueLabel, chevron])
        
        chevron.eqTrailing(self, -20).centerY(self).width(20).aspectRatioFromWidth(1)
        imageView.eqLeading(self, 20).eqTop(self).width(40).aspectRatioFromWidth(1)
        nameLabel.leadingToTrailing(imageView, 20).eqTop(self).eqTrailing(self)
        valueLabel.eqLeading(nameLabel).topToBottom(nameLabel, 10).trailingToLeading(chevron)
        
        nameLabel.text = "Untitled"
        nameLabel.textColor = .white
        nameLabel.font = .preferredFont(forTextStyle: .title3)
        valueLabel.text = "None"
        valueLabel.textColor = UIColor.white.withAlphaComponent(0.57)
        valueLabel.font = .preferredFont(forTextStyle: .body)
        
        self.eqBottom(valueLabel)
    }
    
    @discardableResult
    func setImage(_ imageName: String) -> MeditationOptionView {
        self.imageView.image = UIImage(named: imageName)
        return self
    }
    
    @discardableResult
    func setTitle(_ title: String) -> MeditationOptionView {
        self.nameLabel.text = title
        return self
    }
    
    @discardableResult
    func setTarget(_ target: Any?, action: Selector?) -> MeditationOptionView {
        let tapper = UITapGestureRecognizer(target: target, action: action)
        
        self.addGestureRecognizer(tapper)
        return self
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
