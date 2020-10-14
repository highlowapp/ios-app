//
//  AudioPremiumWarningView.swift
//  HighLow
//
//  Created by Caleb Hester on 8/14/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class AudioPremiumWarningView: UIView {
    
    let timer: UILabel = UILabel()
    let secondsLeft: UILabel = UILabel()
    let upgradeButton: Pill = Pill()
    let forMoreTime: UILabel = UILabel()
    
    weak var delegate: AudioPremiumWarningViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        timer.textColor = AppColors.primary
        secondsLeft.textColor = AppColors.primary
        upgradeButton.backgroundColor = AppColors.secondary
        forMoreTime.textColor = AppColors.secondary
        
        timer.font = .preferredFont(forTextStyle: .title1)
        secondsLeft.font = .preferredFont(forTextStyle: .callout)
        forMoreTime.font = .preferredFont(forTextStyle: .callout)
        
        timer.text = "30"
        secondsLeft.text = "seconds left"
        forMoreTime.text = "for more time\n(we'll pause the recording for you)"
        
        forMoreTime.numberOfLines = 2
        
        secondsLeft.textAlignment = .center
        forMoreTime.textAlignment = .center
        timer.textAlignment = .center
        
        let upgradeLabel = UILabel()
        upgradeLabel.text = "Upgrade to Premium"
        upgradeLabel.textColor = .white
        upgradeLabel.font = .preferredFont(forTextStyle: .title3)
        upgradeLabel.textAlignment = .center
        
        self.addSubviews([timer, secondsLeft, upgradeButton, forMoreTime])
        
        timer.eqLeading(self).eqTrailing(self).eqTop(self, 20)
        secondsLeft.topToBottom(timer, 5).eqLeading(self).eqTrailing(self)
        upgradeButton.topToBottom(secondsLeft, 20).centerX(self)
        forMoreTime.topToBottom(upgradeButton, 20).eqLeading(self).eqTrailing(self)
        self.eqBottom(forMoreTime, 20)
        self.backgroundColor = rgb(240, 240, 240)
        
        upgradeButton.addSubview(upgradeLabel)
        upgradeLabel.eqLeading(upgradeButton, 15).eqTop(upgradeButton, 7)
        upgradeButton.eqTrailing(upgradeLabel, 15).eqBottom(upgradeLabel, 7)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(paywallPresenter))
        upgradeButton.addGestureRecognizer(tapper)
    }
    
    func updateTimeCode(withTimeInterval timeCode: TimeInterval) {
        timer.text = timeCode.stringFromTimeInterval()
    }

    @objc func paywallPresenter() {
        self.delegate?.audioPremiumWarningWillPresentPaywall()
    }
}


protocol AudioPremiumWarningViewDelegate: AnyObject {
    func audioPremiumWarningWillPresentPaywall()
}
