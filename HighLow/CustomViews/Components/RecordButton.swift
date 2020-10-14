//
//  RecordButton.swift
//  HighLow
//
//  Created by Caleb Hester on 8/3/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

enum RecordButtonState {
    case stopped
    case recording
    case paused
}

class RecordButton: UIButton {
    
    var recordingState: RecordButtonState = .stopped
    
    var isDisabled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    let circle: Pill = Pill()
    let square: UIView = UIView()
    let resumeLabel: UILabel = UILabel()
    var circleTransform: CGAffineTransform?
    
    private func setup() {
        self.showBorder(AppColors.primary, 2)
        self.aspectRatioFromWidth(1)
        self.addSubviews([circle, square, resumeLabel])
        self.clipsToBounds = true
        self.isUserInteractionEnabled =  true
        circle.isUserInteractionEnabled = false
        square.isUserInteractionEnabled = false
        
        circle.backgroundColor = AppColors.primary
        square.backgroundColor = AppColors.primary
        
        resumeLabel.text = "Resume"
        resumeLabel.textColor = AppColors.primary
        resumeLabel.font = .systemFont(ofSize: 10)
        resumeLabel.textAlignment = .center
        
        circle.aspectRatioFromWidth(1).centerX(self).centerY(self).eqWidth(self, -7)
        square.aspectRatioFromWidth(1).centerX(self).centerY(self).eqWidth(self, 0, 0.55)
        resumeLabel.eqWidth(self).eqHeight(self).centerX(self).centerY(self)
        
        square.layer.cornerRadius = 7
        
        circle.isHidden = false
        square.isHidden = false
        resumeLabel.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func startRecording() {
        circle.isHidden = false
        square.isHidden = false
        resumeLabel.isHidden = true
        recordingState = .recording
        UIView.animate(withDuration: 0.4) {
            let scaled = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.circle.transform = scaled
        }
    }

    func resumeRecording() {
        circle.isHidden = false
        square.isHidden = false
        resumeLabel.isHidden = true
        recordingState = .recording
        UIView.animate(withDuration: 0.4) {
            let scaled = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.circle.transform = scaled
        }
    }
    
    func stopRecording() {
        circle.isHidden = false
        square.isHidden = false
        resumeLabel.isHidden = true
        recordingState = .stopped
        UIView.animate(withDuration: 0.4) {
            let scaled = CGAffineTransform.identity
            self.circle.transform = scaled
        }
    }
    
    func pauseRecording() {
        recordingState = .paused
        circle.isHidden = true
        square.isHidden = true
        resumeLabel.isHidden = false
    }
    
    func disable() {
        isDisabled = true
        self.layer.borderColor = self.layer.borderColor?.copy(alpha: 0.5)
        circle.backgroundColor = circle.backgroundColor?.withAlphaComponent(0.5)
        square.backgroundColor = square.backgroundColor?.withAlphaComponent(0)
    }
    
    func enable() {
        isDisabled = false
        self.layer.borderColor = self.layer.borderColor?.copy(alpha: 1)
        circle.backgroundColor = circle.backgroundColor?.withAlphaComponent(1)
        square.backgroundColor = square.backgroundColor?.withAlphaComponent(1)
    }
}
